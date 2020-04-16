import { Codec, string, GetInterface } from "purify-ts/Codec";

import { EitherAsync } from "purify-ts/EitherAsync";
import { sendEmail } from "./send";

export const UpdateMailProps = Codec.interface({
  toEmail: string,
  comment: string,
  commentId: string,
  name: string,
  path: string,
});

export type UpdateMailProps = GetInterface<typeof UpdateMailProps>;

function confirmationEmail({
  name,
  comment,
  commentId,
  path,
}: UpdateMailProps): string {
  return `
    <h1>Hi, ${name}</h1>
    <p>Thank you for your comment on driftercode.com</p>
    <p>To prevent spam, I need you to prove you own this email.</p>
    <a href="https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/approval/${commentId}">Click here to confirm that you wrote the following comment:</a>
    <br/>
    <p>${comment}</p>
    `;
}

export function sendConfirmationMail(
  props: UpdateMailProps
) /* : EitherAsync<string, mailgun.messages.SendResponse> */ {
  const subject = "Confirm comment on driftercode.com";
  return EitherAsync<string, UpdateMailProps>(async ({ liftEither }) => {
    const decodedMailProps = await liftEither(UpdateMailProps.decode(props));
    return decodedMailProps;
  }).chain((mailProps) =>
    EitherAsync(async ({ fromPromise }) => {
      const sendResponse = await fromPromise(
        sendEmail({ subject, mailProps, emailBody: confirmationEmail })
      );

      return sendResponse;
    })
  );
}
