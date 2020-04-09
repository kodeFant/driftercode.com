import { Codec, string, GetInterface, boolean, lazy, oneOf, nullType, array, number } from 'purify-ts/Codec';
import { Right, Left, Either } from 'purify-ts/Either';
import * as R from 'remeda';

const email = Codec.custom<string>({
	decode: (input) => validateEmail(input),
	encode: (input) => input
});

const textInput = Codec.custom<string>({
	decode: (input) => validateTextInput(input),
	encode: (input) => input
});

const validateEmail = (input: unknown): Either<string, string> => {
	return R.pipe(
		input,
		(x) => (typeof x === 'string' ? Right(x) : Left('Not a string')),
		(x) => (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(x.extract()) ? x : Left('Not a valid email'))
	);
};

const validateTextInput = (input: unknown): Either<string, string> => {
	return R.pipe(
		input,
		(x) => (typeof x === 'string' ? Right(x) : Left('Not a string')),
		(x) => (x.extract().length > 2 ? x : Left('Input is too short'))
	);
};

// Lazy so that Commant can recursively take in subcomment
// https://gigobyte.github.io/purify/utils/Codec#lazy

const SubComment = lazy(() => oneOf([ array(Comment), nullType ]));

type SubComment = GetInterface<typeof SubComment>;

export const Comment: Codec<Comment> = Codec.interface({
	id: string,
	path: string,
	email: email,
	name: string,
	comment: string,
	approved: boolean,
	created_at: number,
	updated_at: number,
	responses: SubComment
});

export const CommentList = array(Comment);
export type CommentList = Comment[];

export interface Comment {
	id: string;
	path: string;
	email: string;
	name: string;
	comment: string;
	approved: boolean;
	created_at: number;
	updated_at: number;
	responses: SubComment;
}

export type AddComment = GetInterface<typeof AddComment>;

export const AddComment = Codec.interface({
	path: string,
	email: email,
	name: textInput,
	comment: textInput,
	approved: boolean,
	created_at: number,
	updated_at: number,
	responses: nullType
});

export type AddCommentForm = GetInterface<typeof AddCommentForm>;

export const AddCommentForm = Codec.interface({
	path: string,
	email: email,
	name: textInput,
	comment: textInput
});

export const CommentToDelete = Codec.interface({
	path: string,
	email: email,
	name: string,
	comment: string,
	approved: boolean,
	created_at: number,
	updated_at: number
});

export type CommentToDelete = GetInterface<typeof CommentToDelete>;
