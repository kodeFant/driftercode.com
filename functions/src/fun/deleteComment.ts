import { Request, Response } from 'express';
import { Codec, string, GetInterface } from 'purify-ts/Codec';
import { commentsRef } from '../firebase';
import { EitherAsync } from 'purify-ts/EitherAsync';
import { commentExistIO } from '../util/commentExistsIO';
import buildNetlify from '../util/buildNetlifyIO';

const UpdateApprovalBody = Codec.interface({
	commentId: string
});

type UpdateApprovalBody = GetInterface<typeof UpdateApprovalBody>;

export default async function deleteComment(request: Request, response: Response) {
	try {
		const IO = await deleteCommentIO(request).run();
		return IO.ifRight(() => response.send('Your comment was successfully deleted')).ifLeft((error) => {
			response.statusCode = 400;
			response.send(`Something went wrong: ${error}`);
			return `Something went wrong: ${error}`;
		});
	} catch (e) {
		response.statusCode = 500;
		response.send(`Something went wrong: ${e}`);
		return `Something went wrong: ${e}`;
	}
}

const deleteCommentIO = (request: Request): EitherAsync<string, globalThis.Response> =>
	EitherAsync<string, FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>>(async ({ liftEither }) => {
		const decodedBody = await liftEither(UpdateApprovalBody.decode({ commentId: request.params.commentId }));
		const commentRef = await commentsRef.doc(decodedBody.commentId);

		return commentRef;
	})
		.chain((commentRef) =>
			EitherAsync<
				string,
				[boolean, FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>]
			>(async ({ fromPromise }) => {
				const commentExists = await fromPromise(commentExistIO(commentRef));
				return [ commentExists, commentRef ];
			})
		)
		.chain(([ _, commentRef ]) =>
			EitherAsync<string, globalThis.Response>(async ({ fromPromise }) => {
				await commentRef.delete();
				const netlifyBuildResult = await fromPromise(buildNetlify());
				return netlifyBuildResult;
			})
		);
