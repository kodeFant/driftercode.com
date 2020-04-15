module Comment exposing
    ( Comment
    , CommentField(..)
    , CommentForm
    , CommentSendResponse
    , DeleteCommentForm
    , commentsDecoder
    , initialCommentForm
    , initialDeleteCommentForm
    , postComment
    , requestDeleteEmail
    , updateSubmitComment
    , validateCommentForm
    , view
    )

import Date exposing (fromPosix)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onInput)
import Http exposing (Error(..))
import Json.Decode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..), WebData)
import Time exposing (millisToPosix, utc)
import Util.Date exposing (formatDate)
import Util.Error exposing (errorToString)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)



-- TYPES


type alias Comment =
    { id : String
    , path : String
    , name : String
    , comment : String
    , approved : Bool
    , createdAt : Int
    , updatedAt : Int
    , responses : Maybe Responses
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


type Responses
    = Responses (List Comment)


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



-- VIEW


type alias Config msg =
    { commentInfoToggle : Bool -> msg
    , updateCommentForm : CommentForm -> msg
    , updateDeleteCommentForm : DeleteCommentForm -> msg
    , submitComment : String -> msg
    , requestDeletionEmail : String -> msg
    }


type alias CommentState =
    { commentForm : CommentForm
    , commentInfo : Bool
    , deleteCommentForm : DeleteCommentForm
    }


view : Config msg -> CommentState -> String -> List Comment -> Html msg
view config state slug comments =
    div []
        [ commentFormView config slug state
        , if List.length comments == 0 then
            div [] []

          else
            Html.Styled.text "Comments"
        , div []
            (comments
                |> List.map
                    commentView
            )
        ]


commentFormView : Config msg -> String -> CommentState -> Html msg
commentFormView config slug state =
    let
        { commentForm } =
            state

        { updateCommentForm, submitComment, commentInfoToggle } =
            config
    in
    case state.commentForm.sendRequest of
        NotAsked ->
            div []
                [ div
                    []
                    [ text "Leave a comment" ]
                , input [ onInput (\value -> updateCommentForm { commentForm | name = value }) ] []
                , formErrorView commentForm.errors Name
                , input [ onInput (\value -> updateCommentForm { commentForm | email = value }) ] []
                , formErrorView commentForm.errors Email
                , textarea [ onInput (\value -> updateCommentForm { commentForm | message = value }) ] []
                , formErrorView commentForm.errors Message
                , button [ Html.Styled.Events.onClick (submitComment slug) ] [ text "Submit comment" ]
                , button [ Html.Styled.Events.onClick (commentInfoToggle (not state.commentInfo)) ] [ text "I want to delete a comment" ]
                , if state.commentInfo == True then
                    deleteForm config state

                  else
                    div [] []
                ]

        Loading ->
            div [] [ text "Sending..." ]

        Failure err ->
            div [] [ text (errorToString err) ]

        Success _ ->
            div [] [ text "Comment successfully sent. Please verify your comment at the given email, ", strong [] [ text commentForm.email, text ", within 24 hours." ] ]


deleteForm : Config msg -> CommentState -> Html msg
deleteForm { updateDeleteCommentForm, commentInfoToggle, requestDeletionEmail } state =
    case state.deleteCommentForm.sendRequest of
        NotAsked ->
            let
                deleteCommentForm =
                    state.deleteCommentForm
            in
            div []
                [ div [] [ text "Delete Comment" ]
                , div [] [ text "Want to delete a comment on this page? Fill in you email. You can delete the comment from your email inbox." ]
                , input [ onInput (\value -> updateDeleteCommentForm { deleteCommentForm | email = value }) ] []
                , button [ Html.Styled.Events.onClick (requestDeletionEmail state.deleteCommentForm.email) ] [ text "Request Deletion" ]
                , button [ Html.Styled.Events.onClick (commentInfoToggle False) ] [ text "Request Deletion" ]
                ]

        Loading ->
            div [] [ text "Sending Request..." ]

        Failure err ->
            div [] [ text (errorToString err) ]

        Success string ->
            div [] [ text "Success! Please check your inbox at ", strong [] [ text string ], text " for info about deleting comments." ]


formErrorView : List CommentError -> CommentField -> Html msg
formErrorView commentError commentField =
    div []
        (commentError
            |> List.filter (\( field, _ ) -> field == commentField)
            |> List.map (\( _, string ) -> text string)
        )


commentHeader : Comment -> Html msg
commentHeader comment =
    div []
        [ div [] [ Html.Styled.text comment.name ]
        , div []
            [ Html.Styled.text
                (formatDate
                    (fromPosix utc (millisToPosix comment.createdAt))
                )
            ]
        ]


commentView : Comment -> Html msg
commentView comment =
    div []
        [ commentHeader comment
        , div [] [ Html.Styled.text comment.comment ]
        ]



-- DECODERS


responseDecoder : Decode.Decoder (Maybe Responses)
responseDecoder =
    Decode.maybe (Decode.map Responses (Decode.list (Decode.lazy (\_ -> commentDecoder))))


commentDecoder : Decode.Decoder Comment
commentDecoder =
    Pipeline.decode Comment
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "path" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "comment" Decode.string
        |> Pipeline.required "approved" Decode.bool
        |> Pipeline.required "created_at" Decode.int
        |> Pipeline.required "updated_at" Decode.int
        |> Pipeline.required "responses" responseDecoder


commentsDecoder : Decode.Decoder (List Comment)
commentsDecoder =
    Decode.list commentDecoder


postComment : (WebData CommentSendResponse -> msg) -> String -> CommentForm -> Cmd msg
postComment message slug commentForm =
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
        , expect = Http.expectJson (RemoteData.fromResult >> message) commentSendResponseDecoder
        }


commentSendResponseDecoder : Json.Decode.Decoder CommentSendResponse
commentSendResponseDecoder =
    Json.Decode.map CommentSendResponse (Json.Decode.field "success" Json.Decode.bool)


requestDeleteEmail : (WebData String -> msg) -> String -> Cmd msg
requestDeleteEmail message email =
    Http.post
        { url = "https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/request-delete/" ++ email
        , body = Http.emptyBody
        , expect = Http.expectString (RemoteData.fromResult >> message)
        }


validateCommentForm : Validator CommentError CommentForm
validateCommentForm =
    Validate.all
        [ ifBlank .email ( Email, "Email is required" )
        , ifInvalidEmail .email (\_ -> ( Email, "Please enter a valid email adress" ))
        , ifBlank .name ( Name, "Name is required" )
        , ifBlank .message ( Message, "Please leave a comment before submitting" )
        ]


updateSubmitComment :
    (WebData CommentSendResponse -> msg)
    -> String
    -> { r | commentForm : CommentForm }
    -> ( { r | commentForm : CommentForm }, Cmd msg )
updateSubmitComment message slug model =
    let
        commentForm =
            model.commentForm
    in
    case validate validateCommentForm commentForm of
        Ok _ ->
            ( { model | commentForm = { commentForm | sendRequest = Loading } }, postComment message slug model.commentForm )

        Err err ->
            ( { model | commentForm = { commentForm | errors = err } }, Cmd.none )
