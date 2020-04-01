
import * as admin from "firebase-admin"

admin.initializeApp();

const db = admin.firestore();
export const commentsRef = db.collection('comments');