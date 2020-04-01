import { Response, Request, NextFunction } from "express"
import { commentsRef } from "../firebase"
import { AddComment, Comment } from "../codecs/Comment"
import { Either, Left } from "purify-ts/Either"
import { sendConfirmationMail } from "../email"

export default async function newComment(request: Request, response: Response, next: NextFunction) {

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

    const commentData = await createNewComment(comment)

    if (commentData.isRight()) {
        const comData = await commentData.extract()
        response.json({ success: true })
        return sendConfirmationMail(request, response, next)({
            toEmail: comData.email,
            articleTitle: comData.path,
            comment: comData.comment,
            commentId: comData.id,
            name: comData.name
        })

    } else {
        response.statusCode = 500
        response.json({ success: false })
        return "Something went wrong with adding comment"
    }
}

async function createNewComment(comment: AddComment): Promise<Either<string, Comment>> {
    try {

        const decodedComment = AddComment.decode(comment)

        if (decodedComment.isLeft()) {
            throw decodedComment.extract()
        }

        const query = await commentsRef.add(comment)
        const decodeData = async (docRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>) => {
            const documentRef = await docRef.get()
            const document = documentRef.data()
            const decodedData = Comment.decode({ id: docRef.id, ...document })
            return decodedData
        }

        const decodedResult = await (decodeData(query))
        return decodedResult

    } catch (e) {
        return Left(e)
    }
}