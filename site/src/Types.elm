module Types exposing (CommentForm, CommentSendResponse, Model, Msg(..))

import RemoteData exposing (WebData)


type Msg
    = NoOp
    | ToggleMobileMenu
    | ChangedPage
    | UpdateCommentForm CommentForm
    | SubmitComment String
    | SendCommentResponse (WebData CommentSendResponse)


type alias Model =
    { mobileMenuVisible : Bool
    , commentForm : CommentForm
    }


type alias CommentForm =
    { name : String
    , email : String
    , message : String
    , sendRequest : WebData CommentSendResponse
    }


type alias CommentSendResponse =
    { success : Bool
    }
