import { Request, Response } from "express";
import { Either, Right, Left } from "purify-ts/Either";
import { Codec, string, GetInterface } from "purify-ts/Codec";
import { commentsRef } from "../firebase";
import { sendDeletionMail } from "../email/deleteEmails";
import { Comment } from "../codecs/Comment";
import { EitherAsync } from "purify-ts/EitherAsync";
import * as mailgun from "mailgun-js";

const DeleteRequestBody = Codec.interface({
  email: string,
});

type DeleteRequestBody = GetInterface<typeof DeleteRequestBody>;

export default async function requestDeletionMail(
  request: Request,
  response: Response
) {
  try {
    const IO = await sendMail(request).run();

    return IO.ifLeft((error) => {
      response.statusCode = 400;
      response.send(`Something went wrong ${error}`);
    }).ifRight(async (data) => {
      response.send(data[1]);
    });
  } catch (e) {
    response.statusCode = 500;
    response.send(`Something went wrong ${e}`);
    return `Something went wrong ${e}`;
  }
}

async function getFilteredComments(
  body: DeleteRequestBody
): Promise<Either<string, Comment[]>> {
  const commentList: Comment[] = [];
  try {
    const comments = await commentsRef.where("email", "==", body.email).get();
    comments.forEach((doc) => {
      if (doc.exists) {
        Comment.decode({
          ...doc.data(),
          id: doc.id,
        }).ifRight((data) => commentList.push(data));
      }
    });
    if (commentList.length > 0) {
      return Right(commentList);
    } else {
      return Left("You haven't left any comments on this email address");
    }
  } catch (e) {
    return Left(e);
  }
}

const sendMail = (request: Request) =>
  EitherAsync<string, [mailgun.messages.SendResponse, string]>(
    async ({ liftEither, fromPromise }) => {
      const body = await liftEither(
        DeleteRequestBody.decode({ email: request.params.email })
      );

      const filteredComments = await liftEither(
        await getFilteredComments(body)
      );

      return [
        await fromPromise(
          sendDeletionMail()({
            toEmail: body.email,
            comments: filteredComments,
          })
        ),
        body.email,
      ];
    }
  );
