import * as admin from "firebase-admin"
import { Either, Right, Left } from "purify-ts/Either"

if (!admin) {
    console.error("Admin not loaded")
}

export async function commentExistIO(commentRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>): Promise<Either<string, true>> {
    try {
        const response = await commentRef.get()
        if (response.exists) return Right(true)
        else throw Error("Comment does not exists")

    } catch (e) {
        return Left(e);
    }
}

