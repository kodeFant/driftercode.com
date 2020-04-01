
import {
    Codec,
    string,
    GetInterface,
    boolean,
    lazy,
    oneOf,
    nullType,
    array,
    number
} from 'purify-ts/Codec'




// Lazy so that Commant can recursively take in subcomment
// https://gigobyte.github.io/purify/utils/Codec#lazy

const SubComment = lazy(() => oneOf([array(Comment), nullType]))

type SubComment = GetInterface<typeof SubComment>


export const Comment: Codec<Comment> = Codec.interface({
    id: string,
    path: string,
    email: string,
    name: string,
    comment: string,
    approved: boolean,
    created_at: number,
    updated_at: number,
    responses: SubComment
})

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

export type AddComment = GetInterface<typeof AddComment>

export const AddComment = Codec.interface({
    path: string,
    email: string,
    name: string,
    comment: string,
    approved: boolean,
    created_at: number,
    updated_at: number,
    responses: nullType
})

export type AddCommentForm = GetInterface<typeof AddCommentForm>

export const AddCommentForm = Codec.interface({
    path: string,
    email: string,
    name: string,
    comment: string,
})

