import { Either, Right, Left } from "purify-ts/Either"

import { Request, Response } from "express"
import { commentsRef } from "../firebase"

import { Comment } from "../codecs/Comment"
import { EitherAsync } from "purify-ts/EitherAsync"

export async function getAllComments(_: Request, response: Response): Promise<Either<string, Comment[]>> {
    const comments = await getComments().run()
    if (comments.isRight()) {
        await response.send(comments.extract())
    } else {
        response.statusCode = 500
        await response.send(`Getting all comments failed ${comments.extract()}`)
    }
    return comments
}

const getComments = () => EitherAsync<string, Comment[]>(async ({ liftEither }) => {
    const commentsResult = liftEither(await fetchApprovedComments())
    const decodedComments = liftEither(decodeAllComments(await commentsResult))
    return decodedComments
})

async function fetchApprovedComments(): Promise<Either<string, FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>>> {
    try {
        const commentsResponse = await commentsRef.where("approved", "==", true).get()
        return Right(commentsResponse)
    } catch (e) {
        return Left(e)
    }
}

function decodeAllComments(snapshot: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData>): Either<string, Comment[]> {
    try {
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
    } catch (e) {
        return Left(e)
    }
}

