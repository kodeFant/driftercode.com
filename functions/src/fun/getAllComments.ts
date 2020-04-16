import { Either, Right, Left } from "purify-ts/Either";

import { Request, Response } from "express";
import { commentsRef } from "../firebase";

import { Comment } from "../codecs/Comment";
import { EitherAsync } from "purify-ts/EitherAsync";

export async function getAllComments(
  _: Request,
  response: Response
): Promise<Either<string, Comment[]>> {
  const IO = await getComments().run();

  // EFFECTS
  IO.ifLeft((error) => {
    response.statusCode = 500;
    response.send(`Getting all comments failed ${error}`);
  }).ifRight((comments) => response.send(comments));

  return IO;
}

const getComments = () =>
  EitherAsync<string, Comment[]>(async ({ liftEither }) => {
    const commentsResult = liftEither(await fetchApprovedComments());
    const decodedComments = liftEither(decodeAllComments(await commentsResult));
    return decodedComments;
  });

async function fetchApprovedComments(): Promise<
  Either<
    string,
    FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>
  >
> {
  try {
    const commentsResponse = await commentsRef
      .where("approved", "==", true)
      .get();
    return Right(commentsResponse);
  } catch (e) {
    return Left(e);
  }
}

function decodeAllComments(
  snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>
): Either<string, Comment[]> {
  try {
    const entries: Comment[] = [];
    snapshot.forEach((doc) => {
      const decodedData = Comment.decode({ id: doc.id, ...doc.data() });
      if (decodedData.isLeft()) {
        throw decodedData.extract();
      } else if (decodedData.isRight()) {
        entries.push(decodedData.extract());
      }
    });
    return Right(entries);
  } catch (e) {
    return Left(e);
  }
}
