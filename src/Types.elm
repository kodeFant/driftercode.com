module Types exposing (Model, Msg(..))

import Comment exposing (CommentForm, CommentSendResponse, DeleteCommentForm)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | ToggleMobileMenu
    | ChangedPage
    | UpdateCommentForm CommentForm
    | SubmitComment String
    | SendCommentResponse (WebData CommentSendResponse)
    | CommentInfo Bool
    | RequestDeletionEmail String
    | UpdateDeleteCommentForm DeleteCommentForm
    | GotDeletionEmailResponse (WebData String)


type alias Model =
    { mobileMenuVisible : Bool
    , commentForm : CommentForm
    , commentInfo : Bool
    , deleteCommentForm : DeleteCommentForm
    }
