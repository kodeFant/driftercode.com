import * as mailgun from 'mailgun-js';
import { Codec, string, GetInterface, array } from "purify-ts/Codec"
import * as functions from "firebase-functions"
import { Comment } from './codecs/Comment';
import { Either, Right, Left } from 'purify-ts/Either';

const apiKey = functions.config().mailgun.apikey; // Set your API key
const domain = 'mg.driftercode.com'; // Set the domain you registered earlier
const from = 'Lars Lillo Ulvestad <noreply@driftercode.com>'; // Set your from email
const subject = 'Confirm comment on driftercode.com'; // Set the name you would like to send from

const options: mailgun.ConstructorParams = { host: 'api.eu.mailgun.net', apiKey, domain }

const mg = mailgun(options)


const UpdateMailProps = Codec.interface({
    toEmail: string,
    articleTitle: string,
    comment: string,
    commentId: string,
    name: string
})

type UpdateMailProps = GetInterface<typeof UpdateMailProps>


function confirmationEmail({ name, comment, commentId }: UpdateMailProps): string {
    return `
    <h1>Hi, ${name}</h1>
    <p>Thank you for your comment on driftercode.com</p>
    <p>To prevent spam, I need you to prove you own this email.</p>
    <a href="https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/approval/${commentId}">Click here to confirm that you wrote the following comment:</a>
    <br/>
    <p>${comment}</p>
    <br/>
    <br/>
    <h2>Deletion</h2>
    <p>My comment system is pretty minimal at this stage. If you with to delete your comment, just send a delete request to my <a href="mailto:lars.lillo@gmail.com">personal email.</a></p>
    `}

export function sendConfirmationMail() {
    return async (props: UpdateMailProps): Promise<Either<string, mailgun.messages.SendResponse>> => {
        const decodedMailProps = UpdateMailProps.decode(props)
        if (decodedMailProps.isRight()) {
            const mailProps = decodedMailProps.extract()
            const msgBody = await mg.messages().send({
                from, subject, to: mailProps.toEmail,
                html: confirmationEmail(props)
            }, function (error, body) {
                if (error) {
                    console.log(error)
                }

                console.log("emailBody", body)
                return body
            })
            return Right(msgBody)
        } else {
            return Left("Error sending email")
        }
    }
}



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
