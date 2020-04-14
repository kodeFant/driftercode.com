import { mg, from } from './index';
import { Either, Right, Left } from 'purify-ts/Either';
import { Codec, string, GetInterface } from 'purify-ts/Codec';
import * as mailgun from 'mailgun-js';
import { EitherAsync } from 'purify-ts/EitherAsync';

export const UpdateMailProps = Codec.interface({
	toEmail: string,
	articleTitle: string,
	comment: string,
	commentId: string,
	name: string
});

export type UpdateMailProps = GetInterface<typeof UpdateMailProps>;

function confirmationEmail({ name, comment, commentId }: UpdateMailProps): string {
	return `
    <h1>Hi, ${name}</h1>
    <p>Thank you for your comment on driftercode.com</p>
    <p>To prevent spam, I need you to prove you own this email.</p>
    <a href="https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/approval/${commentId}">Click here to confirm that you wrote the following comment:</a>
    <br/>
    <p>${comment}</p>
    <br/>
    <br/>
    <h2>Deletion</h2>
    <p>My comment system is pretty minimal at this stage. If you with to delete your comment, just send a delete request to my <a href="mailto:lars.lillo@gmail.com">personal email.</a></p>
    `;
}

export function sendConfirmationMail(props: UpdateMailProps): EitherAsync<string, mailgun.messages.SendResponse> {
	const subject = 'Confirm comment on driftercode.com';
	return EitherAsync<string, UpdateMailProps>(async ({ liftEither }) => {
		const decodedMailProps = await liftEither(UpdateMailProps.decode(props));
		return decodedMailProps;
	}).chain((mailProps) =>
		EitherAsync(async ({ fromPromise }) => {
			const sendResponse = await fromPromise(sendEmail({ subject, mailProps }));
			return sendResponse;
		})
	);
}

interface SendEmail {
	subject: string;
	mailProps: UpdateMailProps;
}

async function sendEmail({ subject, mailProps }: SendEmail): Promise<Either<string, mailgun.messages.SendResponse>> {
	try {
		const msgBody = await mg.messages().send({
			from,
			subject,
			to: mailProps.toEmail,
			html: confirmationEmail(mailProps)
		}, function(error, body) {
			if (error) {
				console.log(error);
			}
			console.log('emailBody', body);
		});
		return Right(msgBody);
	} catch (e) {
		return Left(e);
	}
}
