
import { Comment } from '../codecs/Comment';
import { Either, Right, Left } from 'purify-ts/Either';
import { Codec, string, GetInterface, array } from "purify-ts/Codec"
import { mg, from } from "./index"
import * as mailgun from "mailgun-js"

function deleteCommentEmail({ comments }: DeleteMailProps): string {
    const commentLinks: string = comments.map(comment => `
        
        <h2>Comment to delete</h2>
        <p>${comment.comment}</p>
        <a href="https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/delete/${comment.id}">Click here to delete</a>
        <br/>
        <hr/>
    `).join()

    return `
        <h1>Email deletion</h1>
        <strong>WARNING: Clicking on any of these results in permanent deletion of your comment. You will not be asked to confirm.</strong>
        ${commentLinks}
    `}

const DeleteMailProps = Codec.interface({
    toEmail: string,
    comments: array(Comment)
})

type DeleteMailProps = GetInterface<typeof DeleteMailProps>



export function sendDeletionMail() {
    const subject = 'Delete comment on driftercode.com';
    return async (props: DeleteMailProps): Promise<Either<string, mailgun.messages.SendResponse>> => {
        try {
            const msgBody = await mg.messages().send({
                from, subject, to: props.toEmail,
                html: deleteCommentEmail(props)
            }, function (error, body) {
                if (error) {
                    console.log(error)
                }

                return body
            })
            return Right(msgBody)
        } catch (e) {
            return Left(e)
        }
    }
}
