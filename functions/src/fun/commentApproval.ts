import { Request, Response } from "express"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import { commentsRef } from "../firebase"
import * as functions from "firebase-functions"
import fetch from 'cross-fetch';

const UpdateApprovalBody = Codec.interface({
    commentId: string
})

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>



export default async function commentApproval(request: Request, response: Response) {

    const body = { commentId: request.params.commentId }
    const decodedBody = UpdateApprovalBody.decode(body)



    if (decodedBody.isRight()) {

        const updateApprovalBody = decodedBody.extract()
        const commentRef = await commentsRef.doc(updateApprovalBody.commentId)
        const commentExists: boolean = await commentExistIO(commentRef)

        if (commentExists) {
            commentRef.update({
                approved: true
            })
                .then(async function () {
                    const res = await fetch(functions.config().netlify.buidhook, { method: "POST" })

                    if (res.status >= 400) {
                        throw new Error("Bad response from server");
                    }

                    console.log("Comment approval successfully updated!");
                    response.send("Comment approved")

                    return "Comment approved"
                })
                .catch(function (error) {
                    response.statusCode = 500
                    return "Something went wrong"
                });
        } else {
            response.statusCode = 500
            return "Something went wrong"
        }
    } else if (decodedBody.isLeft()) {
        response.statusCode = 500
        response.send(decodedBody.extract())
        return `Something went wrong: ${decodedBody.extract()}`
    }
    console.log("To last return")
    return "Something went wrong"
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