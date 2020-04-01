import * as functions from 'firebase-functions';
import * as express from 'express';
import * as cors from 'cors';
import { getAllComments } from "./fun/getAllComments"
import newComment from "./fun/newComment"
import commentApproval from "./fun/commentApproval"

const app = express()
app.use(cors({ origin: true }))

app.get("/", getAllComments)
app.post("/new", newComment)
app.get("/approval/:commentId", commentApproval)

export const comments = functions.https.onRequest(app);
