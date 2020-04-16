import { mg, from } from "./index";
import { Either, Right, Left } from "purify-ts/Either";

import * as mailgun from "mailgun-js";

interface SendEmail<M> {
  subject: string;
  mailProps: { toEmail: string };
  emailBody: (props: M) => string;
}

export async function sendEmail({
  subject,
  mailProps,
  emailBody,
}: SendEmail<any>): Promise<Either<string, mailgun.messages.SendResponse>> {
  try {
    const msgBody = await mg.messages().send(
      {
        from,
        subject,
        to: mailProps.toEmail,
        html: emailBody(mailProps),
      },
      function (error, body) {
        if (error) {
          console.log(error);
        }
      }
    );
    return Right(msgBody);
  } catch (e) {
    return Left(e);
  }
}
