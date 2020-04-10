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
import Design.Palette exposing (color)
import Design.Responsive exposing (responsiveView)
import Element
    exposing
        ( Element
        , alignLeft
        , alignRight
        , centerX
        , column
        , el
        , fill
        , mouseOver
        , none
        , padding
        , paragraph
        , rgb255
        , row
        , spacing
        , text
        , textColumn
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
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


view : Config msg -> CommentState -> String -> List Comment -> Element msg
view config state slug comments =
    column [ width fill, spacing 28 ]
        [ commentFormView config slug state
        , if List.length comments == 0 then
            none

          else
            el
                [ Font.bold, Font.size 28, Font.center ]
                (text "Comments")
        , column [ width fill, spacing 20 ]
            (comments
                |> List.map
                    commentView
            )
        ]


commentFormView : Config msg -> String -> CommentState -> Element msg
commentFormView config slug state =
    let
        { commentForm } =
            state

        { updateCommentForm, submitComment, commentInfoToggle } =
            config
    in
    case state.commentForm.sendRequest of
        NotAsked ->
            column [ width fill, spacing 20, Font.size 16 ]
                [ el
                    [ Font.bold, Font.size 28, Font.center ]
                    (text "Leave a comment")
                , Input.text
                    [ width fill ]
                    { onChange = \value -> updateCommentForm { commentForm | name = value }
                    , text = commentForm.name
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Name")
                    }
                , formErrorView commentForm.errors Name
                , column [ spacing 10, width fill ]
                    [ Input.email
                        [ width fill ]
                        { onChange = \value -> updateCommentForm { commentForm | email = value }
                        , text = commentForm.email
                        , placeholder = Nothing
                        , label = Input.labelAbove [] (text "Email")
                        }
                    ]
                , formErrorView commentForm.errors Email
                , Input.multiline
                    [ width fill ]
                    { onChange = \value -> updateCommentForm { commentForm | message = value }
                    , text = commentForm.message
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Your message")
                    , spellcheck = False
                    }
                , formErrorView commentForm.errors Message
                , Input.button
                    [ width fill
                    , padding 10
                    , Font.center
                    , Font.color color.white
                    , Font.bold
                    , Background.color color.primary
                    , mouseOver [ Background.color color.secondary ]
                    ]
                    { onPress = Just (submitComment slug)
                    , label = text "Submit"
                    }
                , Input.button [ centerX, Font.size 14 ] { label = text "I want to delete a comment", onPress = Just (commentInfoToggle (not state.commentInfo)) }
                , if state.commentInfo == True then
                    deleteForm config state

                  else
                    none
                ]

        Loading ->
            paragraph [] [ text "Sending..." ]

        Failure err ->
            paragraph [] [ text (errorToString err) ]

        Success _ ->
            paragraph [] [ text "Comment successfully sent. Please verify your comment at the given email, ", el [ Font.bold ] (text commentForm.email), text ", within 24 hours." ]


deleteForm : Config msg -> CommentState -> Element msg
deleteForm { updateDeleteCommentForm, commentInfoToggle, requestDeletionEmail } state =
    case state.deleteCommentForm.sendRequest of
        NotAsked ->
            let
                deleteCommentForm =
                    state.deleteCommentForm
            in
            column [ width fill, spacing 16, Border.width 2, padding 16 ]
                [ el [ centerX, Font.bold ] (text "Delete Comment")
                , paragraph [ Font.center, Font.italic ] [ text "Want to delete a comment on this page? Fill in you email. You can delete the comment from your email inbox." ]
                , Input.email
                    [ width fill ]
                    { onChange = \value -> updateDeleteCommentForm { deleteCommentForm | email = value }
                    , text = state.deleteCommentForm.email
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Email")
                    }
                , Input.button
                    [ width fill
                    , padding 10
                    , Font.center
                    , Font.color color.white
                    , Font.bold
                    , Background.color color.red
                    , mouseOver [ Background.color color.darkRed ]
                    ]
                    { onPress = Just (requestDeletionEmail state.deleteCommentForm.email)
                    , label = text "Request Deletion"
                    }
                , Input.button
                    [ padding 10
                    , Font.center
                    , Font.color color.black
                    , Font.bold
                    , Background.color color.lightGray
                    , mouseOver [ Background.color color.lighterGray ]
                    , centerX
                    ]
                    { onPress = Just (commentInfoToggle False)
                    , label = text "Cancel"
                    }
                ]

        Loading ->
            el [] (text "Sending Request...")

        Failure err ->
            el [] (text (errorToString err))

        Success string ->
            paragraph [] [ text "Success! Please check your inbox at ", el [ Font.bold ] (text string), text " for info about deleting comments." ]


formErrorView : List CommentError -> CommentField -> Element msg
formErrorView commentError commentField =
    column [ Font.color color.red, spacing 10 ]
        (commentError
            |> List.filter (\( field, _ ) -> field == commentField)
            |> List.map (\( _, string ) -> text string)
        )


commentHeader : Comment -> List (Element msg) -> Element msg
commentHeader comment _ =
    responsiveView [ width fill ]
        { mobile =
            column [ width fill, spacing 10 ]
                [ el [ Font.bold, alignLeft ] (text comment.name)
                , el [ Font.size 14, alignLeft ]
                    (text
                        (formatDate
                            (fromPosix utc (millisToPosix comment.createdAt))
                        )
                    )
                ]
        , medium =
            row [ width fill ]
                [ el [ Font.bold, alignLeft ] (text comment.name)
                , el [ Font.size 14, alignRight ]
                    (text
                        (formatDate
                            (fromPosix utc (millisToPosix comment.createdAt))
                        )
                    )
                ]
        , large =
            row [ width fill ]
                [ el [ Font.bold, alignLeft ] (text comment.name)
                , el [ Font.size 14, alignRight ]
                    (text
                        (formatDate
                            (fromPosix utc (millisToPosix comment.createdAt))
                        )
                    )
                ]
        }


commentView : Comment -> Element msg
commentView comment =
    textColumn
        [ spacing 20
        , padding 20
        , width fill
        , Background.color (rgb255 250 250 250)
        ]
        [ commentHeader comment
            [ el [ Font.bold, alignLeft ] (text comment.name)
            , el [ Font.size 14, alignRight ]
                (text
                    (formatDate
                        (fromPosix utc (millisToPosix comment.createdAt))
                    )
                )
            ]
        , paragraph [] [ text comment.comment ]
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
