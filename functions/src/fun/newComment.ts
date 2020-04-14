import { Response, Request } from 'express';
import { commentsRef } from '../firebase';
import { AddComment, Comment } from '../codecs/Comment';
import { Either, Left, Right } from 'purify-ts/Either';
import { sendConfirmationMail } from '../email/confirmComment';
import { EitherAsync } from 'purify-ts/EitherAsync';
import { firestore } from 'firebase-admin';

export default async function newComment(request: Request, response: Response): Promise<Either<string, Comment>> {
	try {
		const IO = await createNewComment({
			comment: request.body.comment,
			email: request.body.email,
			path: request.body.path,
			name: request.body.name,
			approved: false,
			created_at: Date.now(),
			responses: null,
			updated_at: Date.now()
		}).run();

		return IO.ifLeft((data) => fail(400, response, data)).ifRight(() => response.json({ success: true }));
	} catch (e) {
		return fail(500, response, e.message);
	}
}

function fail(code: number, response: Response, errorMessage: string) {
	response.status(code).json({ error: errorMessage });
	return Left('Something went wrong with adding comment');
}

const createNewComment = (newCom: AddComment): EitherAsync<string, Comment> =>
	EitherAsync<string, AddComment>(async ({ liftEither }) => {
		return await liftEither(AddComment.decode(newCom));
	})
		.chain((decodedComment) =>
			EitherAsync<string, firestore.DocumentReference<firestore.DocumentData>>(async ({ fromPromise }) => {
				const query = await fromPromise(addCommentIO(decodedComment));
				return query;
			})
		)
		.chain((queryResult) =>
			EitherAsync(async ({ liftEither }) => {
				const decodedResult = await liftEither(await decodeComment(queryResult));
				return decodedResult;
			})
		)
		.chain((decodedResult) =>
			EitherAsync(async ({ fromPromise }) => {
				await fromPromise(
					sendConfirmationMail({
						toEmail: decodedResult.email,
						articleTitle: decodedResult.path,
						comment: decodedResult.comment,
						commentId: decodedResult.id,
						name: decodedResult.name
					}).run()
				);
				return decodedResult;
			})
		);

const decodeComment = async (
	docRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>
): Promise<Either<string, Comment>> => {
	const documentRef = await docRef.get();
	const document = documentRef.data();
	const decodedData = Comment.decode({ id: docRef.id, ...document });
	return decodedData;
};

const addCommentIO = async (
	decodedComment: AddComment
): Promise<Either<string, firestore.DocumentReference<firestore.DocumentData>>> => {
	try {
		const result = await commentsRef.add(decodedComment);
		return Right(result);
	} catch (e) {
		return Left(e);
	}
};
