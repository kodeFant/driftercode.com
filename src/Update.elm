module Update exposing (init, update)

import Comment exposing (CommentField(..), initialCommentForm, initialDeleteCommentForm, requestDeleteEmail)
import RemoteData exposing (RemoteData(..))
import Types exposing (Model, Msg(..))


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
            Comment.updateSubmitComment SendCommentResponse slug model

        SendCommentResponse webData ->
            ( { model | commentForm = { commentForm | sendRequest = webData } }, Cmd.none )

        CommentInfo bool ->
            ( { model | commentInfo = bool }, Cmd.none )

        UpdateDeleteCommentForm form ->
            ( { model | deleteCommentForm = form }, Cmd.none )

        RequestDeletionEmail email ->
            Comment.submitDeleteCommentForm GotDeletionEmailResponse email model

        -- ( { model | deleteCommentForm = { initialDeleteCommentForm | sendRequest = Loading } }, requestDeleteEmail GotDeletionEmailResponse email )
        GotDeletionEmailResponse webData ->
            ( { model | deleteCommentForm = { initialDeleteCommentForm | sendRequest = webData } }, Cmd.none )
