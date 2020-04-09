module Types exposing (CommentError, CommentField(..), CommentForm, CommentSendResponse, DeleteCommentForm, Model, Msg(..))

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


type alias DeleteCommentForm =
    { email : String
    , sendRequest : WebData String
    }


type alias CommentForm =
    { name : String
    , email : String
    , message : String
    , errors : List CommentError
    , sendRequest : WebData CommentSendResponse
    }


type CommentField
    = Name
    | Email
    | Message


type alias CommentError =
    ( CommentField, String )


type alias CommentSendResponse =
    { success : Bool
    }
