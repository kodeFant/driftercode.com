import { Either, Right } from "purify-ts/Either"

import { Request, Response } from "express"
import { commentsRef } from "../firebase"

import { Comment } from "../codecs/Comment"

export const getAllComments = async (request: Request, response: Response) => {

    const commentsResponse: Either<string, Comment[]> = await commentsRef.where("approved", "==", true).get()
        .then(decodeAllComments)
        .catch((err: Either<string, never>) => {
            console.error(err)
            return err
        });

    if (commentsResponse.isLeft()) {

        response.statusCode = 500
    }

    response.send(commentsResponse.extract());
}

function decodeAllComments(snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>): Either<never, Comment[]> {
    const entries: Comment[] = []
    snapshot.forEach(doc => {
        const decodedData = Comment.decode({ id: doc.id, ...doc.data() })
        if (decodedData.isLeft()) {
            throw decodedData
        } else if (decodedData.isRight()) {
            entries.push(decodedData.extract())
        }
    });
    return Right(entries)
}