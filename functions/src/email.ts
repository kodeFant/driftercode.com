import * as mailgun from 'mailgun-js';
import * as express from "express"
import { Codec, string, GetInterface } from "purify-ts/Codec"
import * as functions from "firebase-functions"

const apiKey = functions.config().mailgun.apikey; // Set your API key
const domain = 'mg.driftercode.com'; // Set the domain you registered earlier
const from = 'Lars Lillo Ulvestad <noreply@driftercode.com>'; // Set your from email
const subject = 'Confirm comment on driftercode.com'; // Set the name you would like to send from

const options: mailgun.ConstructorParams = { host: 'api.eu.mailgun.net', apiKey, domain }

const mg = mailgun(options)


const MailProps = Codec.interface({
    toEmail: string,
    articleTitle: string,
    comment: string,
    commentId: string,
    name: string
})

type MailProps = GetInterface<typeof MailProps>


function emailContent({ name, comment, commentId }: MailProps): string {
    return `
    <h1>Hi, ${name}</h1>
    <p>Thank you for your comment on driftercode.com</p>
    <p>To prevent spam, I need you to prove you own this email.</p>
    <a href="https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/approval/${commentId}">Click here to confirm that you wrote the following comment:</a>
    <br/>
    <p>${comment}</p>
    `}

export function sendConfirmationMail(request: express.Request, response: express.Response, next: express.NextFunction) {
    return async (props: MailProps) => {
        const decodedMailProps = MailProps.decode(props)
        if (decodedMailProps.isRight()) {
            const mailProps = decodedMailProps.extract()
            const msgBody = await mg.messages().send({
                from, subject, to: mailProps.toEmail,
                html: emailContent(props)
            }, function (error, body) {
                if (error) {
                    console.log(error)
                }

                console.log("emailBody", body)
                return body
            })
            return msgBody


        } else {
            response.sendStatus(500)
            return "Error"
        }

    }

}

