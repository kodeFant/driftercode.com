import { Request, Response } from "express"
import { Either } from "purify-ts/Either"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import { commentsRef } from "../firebase"
import { sendDeletionMail } from "../email"
import { CommentList, Comment } from "../codecs/Comment"

const DeleteRequestBody = Codec.interface({
    email: string
})

type UpdateApprovalBody = GetInterface<typeof DeleteRequestBody>

export default async function requestDeletionMail(request: Request, response: Response) {
    const body = { email: request.params.email }
    const decodedBody: Either<string, UpdateApprovalBody> = DeleteRequestBody.decode(body)

    try {
        if (decodedBody.isRight()) {
            const comments = await commentsRef.where("email", "==", request.params.email).get()

            const commentList: CommentList = []


            comments.forEach(doc => {
                console.log("doc.data()", doc.data())
                if (!doc.exists) {
                    console.log("Comment does not exist")
                } else {

                    const comment = {
                        ...doc.data(), id: doc.id
                    }
                    console.log("comment", comment)
                    const decodedComment = Comment.decode(comment)
                    if (decodedComment.isRight()) {
                        commentList.push(decodedComment.extract())
                    } else {
                        console.log(decodedComment)
                    }
                }
            })

            console.log("commentList", commentList)


            const decodedComments = await CommentList.decode(commentList)

            if (decodedComments.isRight()) {
                console.log("decodedComments.isRight()", decodedComments.extract())
                return sendDeletionMail(response)({
                    toEmail: decodedBody.extract().email,
                    comments: decodedComments.extract()
                })
            } else {
                console.log("decodedComments.isLeft()", decodedComments.extract())
                throw (decodedComments.extract())
            }

        } else {
            throw Error(`Something wrong with the body ${decodedBody.extract()}`)
        }

    } catch (e) {
        response.statusCode = 500
        response.send(decodedBody.extract())
        return `Something went wrong: ${decodedBody.extract()}`
    }
}