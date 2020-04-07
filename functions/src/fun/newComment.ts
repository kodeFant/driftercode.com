import { Response, Request, NextFunction } from "express"
import { commentsRef } from "../firebase"
import { AddComment, Comment } from "../codecs/Comment"
import { Either, Left, Right } from "purify-ts/Either"
import { sendConfirmationMail } from "../email"
import { EitherAsync } from "purify-ts/EitherAsync"
import { firestore } from "firebase-admin"



export default async function newComment(request: Request, response: Response, next: NextFunction): Promise<Either<string, Comment>> {

    const comment: AddComment = {
        comment: request.body.comment,
        email: request.body.email,
        path: request.body.path,
        name: request.body.name,
        approved: false,
        created_at: Date.now(),
        responses: null,
        updated_at: Date.now(),
    }
    try {
        const commentData = await createNewComment(comment).run()
        response.json({ success: true })
        return commentData

    } catch (e) {
        response.statusCode = 500
        response.json({ success: false })
        return Left("Something went wrong with adding comment")
    }
}


const createNewComment = (newCom: AddComment) =>
    EitherAsync<string, Comment>(async ({ liftEither, fromPromise }) => {
        const decodedComment = await liftEither(AddComment.decode(newCom))
        const query = await fromPromise(addCommentIO(decodedComment))
        const decodedResult = await liftEither(await decodeComment(query))
        fromPromise(sendConfirmationMail()(({
            toEmail: decodedResult.email,
            articleTitle: decodedResult.path,
            comment: decodedResult.comment,
            commentId: decodedResult.id,
            name: decodedResult.name
        })))

        return decodedResult
    })

const decodeComment = async (docRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>): Promise<Either<string, Comment>> => {
    const documentRef = await docRef.get()
    const document = documentRef.data()
    const decodedData = Comment.decode({ id: docRef.id, ...document })
    return decodedData
}

const addCommentIO = async (decodedComment: AddComment): Promise<Either<string, firestore.DocumentReference<firestore.DocumentData>>> => {
    try {
        const result = await commentsRef.add(decodedComment)
        return Right(result)
    } catch (e) {
        return Left(e)
    }
}
