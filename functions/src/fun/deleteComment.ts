import { Request, Response } from "express"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import { commentsRef } from "../firebase"

import { Either } from "purify-ts/Either";
import { EitherAsync } from "purify-ts/EitherAsync"
import { commentExistIO } from "../util/commentExistsIO";


const UpdateApprovalBody = Codec.interface({
    commentId: string
})

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>


export default async function deleteComment(request: Request, response: Response) {

    const body = { commentId: request.params.commentId }
    const decodedBody: Either<string, UpdateApprovalBody> = UpdateApprovalBody.decode(body)



    if (decodedBody.isRight()) {
        const commentRef = await commentsRef.doc(decodedBody.extract().commentId)
        const commentExists: Either<string, true> = await commentExistIO(commentRef)

        const approved = await updateApprovedCommentIO({ commentExists, commentRef }).run()
        return approved

    } else {
        response.statusCode = 500
        response.send(decodedBody.extract())
        return `Something went wrong: ${decodedBody.extract()}`
    }
}



interface UpdateApprovedCommentIOProps {
    commentExists: Either<string, true>,
    commentRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>,
}

function updateApprovedCommentIO({ commentExists, commentRef }: UpdateApprovedCommentIOProps): EitherAsync<string, string> {
    const updatedApprovedComment = EitherAsync<string, string>(async ({ liftEither, fromPromise }) => {
        if (commentExists.isRight()) {
            await commentRef.delete()
            return ("Comment deleted")
        } else {
            return ("The comment does not exist.")
        }
    })
    return updatedApprovedComment
}