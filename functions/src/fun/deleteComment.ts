import { Request, Response } from "express"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import { commentsRef } from "../firebase"
import { EitherAsync } from "purify-ts/EitherAsync"
import { commentExistIO } from "../util/commentExistsIO";
import buildNetlify from "../util/buildNetlifyIO";


const UpdateApprovalBody = Codec.interface({
    commentId: string
})

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>


export default async function deleteComment(request: Request, response: Response) {

    const deleteCommentReq = await (await deleteCommentIO(request)).run()

    if (deleteCommentReq.isRight()) {
        response.send(deleteCommentReq.extract())
    } else {
        response.statusCode = 500
        response.send(`Something went wrong: ${deleteCommentReq.extract()}`)
        return `Something went wrong: ${deleteCommentReq.extract()}`
    }

    return deleteCommentIO

}


const deleteCommentIO = async (request: Request) =>
    EitherAsync<string, string>(async ({ liftEither, fromPromise }) => {
        const decodedBody = await liftEither(UpdateApprovalBody.decode({ commentId: request.params.commentId }))
        const commentRef = await commentsRef.doc(decodedBody.commentId)
        await fromPromise(commentExistIO(commentRef))
        await commentRef.delete()
        await fromPromise(buildNetlify())
        return "Comment Deleted"
    })

