module Update exposing (init, update)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..))
import Types exposing (CommentForm, CommentSendResponse, Model, Msg(..))


initialCommentForm : CommentForm
initialCommentForm =
    { name = ""
    , email = ""
    , message = ""
    , sendRequest = NotAsked
    }


init : ( Model, Cmd Msg )
init =
    ( { mobileMenuVisible = False
      , commentForm = initialCommentForm
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
            ( { model | mobileMenuVisible = False, commentForm = initialCommentForm }, Cmd.none )

        ToggleMobileMenu ->
            ( { model | mobileMenuVisible = not model.mobileMenuVisible }, Cmd.none )

        UpdateCommentForm form ->
            ( { model | commentForm = form }, Cmd.none )

        SubmitComment slug ->
            ( { model | commentForm = { commentForm | sendRequest = Loading } }, postComment slug model.commentForm )

        SendCommentResponse webData ->
            ( { model | commentForm = { commentForm | sendRequest = webData } }, Cmd.none )


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
