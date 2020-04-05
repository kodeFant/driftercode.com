import { Request, Response } from "express"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import { commentsRef } from "../firebase"

import { Either } from "purify-ts/Either";
import { EitherAsync } from "purify-ts/EitherAsync"

const UpdateApprovalBody = Codec.interface({
    commentId: string
})

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>



export default async function commentApproval(request: Request, response: Response) {

    const body = { commentId: request.params.commentId }
    const decodedBody: Either<string, UpdateApprovalBody> = UpdateApprovalBody.decode(body)

    if (decodedBody.isRight()) {
        const updateApprovalBody = decodedBody.extract()
        const commentRef = await commentsRef.doc(updateApprovalBody.commentId)
        const commentExists: boolean = await commentExistIO(commentRef)

        const approved = await updateApprovedCommentIO({ commentExists, commentRef, decodedBody }).run()

        return approved

    } else {
        response.statusCode = 500
        response.send(decodedBody.extract())
        return `Something went wrong: ${decodedBody.extract()}`
    }
}

async function commentExistIO(commentRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>): Promise<boolean> {
    try {
        const response = await commentRef.get()
        if (response.exists) {
            console.log("Doc exists")
            return true
        } else {
            return false
        }
    } catch (e) {
        console.log("Error getting document:", e);
        return false;
    }
}


interface UpdateApprovedCommentIOProps {
    commentExists: boolean,
    commentRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>,
    decodedBody: Either<string, UpdateApprovalBody>
}



function updateApprovedCommentIO({ commentExists, commentRef, decodedBody }: UpdateApprovedCommentIOProps): EitherAsync<string, string> {
    const updatedApprovedComment = EitherAsync<string, string>(async ({ liftEither, fromPromise }) => {
        if (commentExists) {
            await commentRef.update({ approved: true })
            return ("Comment approved")
        } else {
            return ("There was an error when updating comment")
        }
    })
    return updatedApprovedComment

}