import { Codec, string, GetInterface } from "purify-ts/Codec";
import { EitherAsync } from "purify-ts/EitherAsync";
import * as mailgun from "mailgun-js";
import { sendEmail } from "./send";

const CommentNotification = Codec.interface({
  path: string,
  comment: string,
  name: string,
  toEmail: string,
});

type CommentNotification = GetInterface<typeof CommentNotification>;

function commentNotification({
  name,
  comment,
  path,
}: CommentNotification): string {
  return `
          <h1>New Comment from ${name}</h1>
          <p>Slug: ${path}</p>
          <h2>Comment</h2>
          <p>${comment}</p>
          `;
}

export function sendCommentNotification(
  props: CommentNotification
): EitherAsync<string, mailgun.messages.SendResponse> {
  const subject = `${props.name} left a comment on DrifterCode`;
  return EitherAsync<string, CommentNotification>(async ({ liftEither }) => {
    const decodedMailProps = await liftEither(
      CommentNotification.decode(props)
    );
    return decodedMailProps;
  }).chain((mailProps) =>
    EitherAsync(async ({ fromPromise }) => {
      const sendResponse = await fromPromise(
        sendEmail({
          subject,
          mailProps,
          emailBody: commentNotification,
        })
      );
      return sendResponse;
    })
  );
}
