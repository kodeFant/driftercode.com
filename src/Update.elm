module Update exposing (init, update)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..))
import Types exposing (CommentError, CommentField(..), CommentForm, CommentSendResponse, DeleteCommentForm, Model, Msg(..))
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


initialCommentForm : CommentForm
initialCommentForm =
    { name = ""
    , email = ""
    , message = ""
    , errors = []
    , sendRequest = NotAsked
    }


initialDeleteCommentForm : DeleteCommentForm
initialDeleteCommentForm =
    { email = ""
    , sendRequest = NotAsked
    }


init : ( Model, Cmd Msg )
init =
    ( { mobileMenuVisible = False
      , commentForm = initialCommentForm
      , commentInfo = False
      , deleteCommentForm = initialDeleteCommentForm
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { commentForm } =
            model
    in
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangedPage ->
            ( { model | mobileMenuVisible = False, commentForm = initialCommentForm, commentInfo = False, deleteCommentForm = initialDeleteCommentForm }, Cmd.none )

        ToggleMobileMenu ->
            ( { model | mobileMenuVisible = not model.mobileMenuVisible }, Cmd.none )

        UpdateCommentForm form ->
            ( { model | commentForm = { form | errors = [] } }, Cmd.none )

        SubmitComment slug ->
            case validate validateCommentForm commentForm of
                Ok _ ->
                    ( { model | commentForm = { commentForm | sendRequest = Loading } }, postComment slug model.commentForm )

                Err err ->
                    ( { model | commentForm = { commentForm | errors = err } }, Cmd.none )

        SendCommentResponse webData ->
            ( { model | commentForm = { commentForm | sendRequest = webData } }, Cmd.none )

        CommentInfo bool ->
            ( { model | commentInfo = bool }, Cmd.none )

        UpdateDeleteCommentForm form ->
            ( { model | deleteCommentForm = form }, Cmd.none )

        RequestDeletionEmail email ->
            ( { model | deleteCommentForm = { initialDeleteCommentForm | sendRequest = Loading } }, requestDeleteEmail email )

        GotDeletionEmailResponse webData ->
            ( { model | deleteCommentForm = { initialDeleteCommentForm | sendRequest = webData } }, Cmd.none )


postComment : String -> CommentForm -> Cmd Msg
postComment slug commentForm =
    Http.post
        { url = "https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/new"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "path", Encode.string slug )
                    , ( "name", Encode.string commentForm.name )
                    , ( "email", Encode.string commentForm.email )
                    , ( "comment", Encode.string commentForm.message )
                    ]
                )
        , expect = Http.expectJson (RemoteData.fromResult >> SendCommentResponse) commentSendResponseDecoder
        }


commentSendResponseDecoder : Decode.Decoder CommentSendResponse
commentSendResponseDecoder =
    Decode.map CommentSendResponse (Decode.field "success" Decode.bool)


requestDeleteEmail : String -> Cmd Msg
requestDeleteEmail email =
    Http.post
        { url = "https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/request-delete/" ++ email
        , body = Http.emptyBody
        , expect = Http.expectString (RemoteData.fromResult >> GotDeletionEmailResponse)
        }


validateCommentForm : Validator CommentError CommentForm
validateCommentForm =
    Validate.all
        [ ifBlank .email ( Email, "Email is required" )
        , ifInvalidEmail .email (\_ -> ( Email, "Please enter a valid email adress" ))
        , ifBlank .name ( Name, "Name is required" )
        , ifBlank .message ( Message, "Please leave a comment before submitting" )
        ]
