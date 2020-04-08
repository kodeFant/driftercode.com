import { mg, from } from "./index"
import { Either, Right, Left } from 'purify-ts/Either';
import { Codec, string, GetInterface } from "purify-ts/Codec"
import * as mailgun from "mailgun-js"

export const UpdateMailProps = Codec.interface({
    toEmail: string,
    articleTitle: string,
    comment: string,
    commentId: string,
    name: string
})

export type UpdateMailProps = GetInterface<typeof UpdateMailProps>

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
    `}

export function sendConfirmationMail() {
    const subject = 'Confirm comment on driftercode.com';

    return async (props: UpdateMailProps): Promise<Either<string, mailgun.messages.SendResponse>> => {
        const decodedMailProps = UpdateMailProps.decode(props)
        if (decodedMailProps.isRight()) {
            const mailProps = decodedMailProps.extract()
            const msgBody = await mg.messages().send({
                from, subject, to: mailProps.toEmail,
                html: confirmationEmail(props)
            }, function (error, body) {
                if (error) {
                    console.log(error)
                }

                console.log("emailBody", body)
                return body
            })
            return Right(msgBody)
        } else {
            return Left("Error sending email")
        }
    }
}