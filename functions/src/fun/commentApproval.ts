import { Request, Response } from "express"
import { Codec, string, GetInterface} from "purify-ts/Codec"
import { commentsRef } from "../firebase"

import { Either, Left, Right } from "purify-ts/Either";
import { EitherAsync } from "purify-ts/EitherAsync"
import { commentExistIO } from "../util/commentExistsIO";
import buildNetlify from "../util/buildNetlifyIO"

const UpdateApprovalBody = Codec.interface({
    commentId: string
})

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>

export default async function commentApproval(request: Request, response: Response) {
    const IO = await commentApprovalIO(request).run()

    if ((IO).isRight()) {
        response.send("You have successfully confirmed your comment. Please allow a couple of minutes for it to appear on the site.")
        return IO.extract()
    }
    else {
        response.statusCode = 500
        response.send(IO.extract())
        return `Something went wrong: ${IO.extract()}`
    }
}

const commentApprovalIO = (request: Request) =>
    EitherAsync<string, FirebaseFirestore.WriteResult>(async ({ liftEither, fromPromise }) => {
        const body = await liftEither(UpdateApprovalBody.decode({ commentId: request.params.commentId }))
        const commentRef = await commentsRef.doc(body.commentId)
        liftEither(await commentExistIO(commentRef))
        fromPromise(buildNetlify())
        const approved = await fromPromise(updateApprovedCommentIO(commentRef))
        return approved
    })


async function updateApprovedCommentIO(commentRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>): Promise<Either<string, FirebaseFirestore.WriteResult>> {
    try {
        const update = await commentRef.update({ approved: true })
        return Right(update)
    } catch (e) {
        return Left(e)
    }
}
