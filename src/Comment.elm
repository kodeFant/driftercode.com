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
    , submitDeleteCommentForm
    , updateSubmitComment
    , validateCommentForm
    , view
    )

import Css exposing (..)
import Date exposing (fromPosix)
import Design.Palette exposing (colors)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Http exposing (Error(..))
import Json.Decode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..), WebData)
import Styled
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
    , errors : List DeleteCommentError
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


type alias DeleteCommentError =
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
    , errors = []
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
        , div []
            [ if List.length comments == 0 then
                div [] []

              else
                Styled.heading3 [] [ text "Comments" ]
            , div []
                (comments
                    |> List.indexedMap
                        commentView
                )
            ]
        ]


commentFormView : Config msg -> String -> CommentState -> Html msg
commentFormView config slug state =
    case state.commentForm.sendRequest of
        NotAsked ->
            if state.commentInfo == True then
                commentDialog
                    [ deleteForm config state ]

            else
                commentDialog
                    [ commentFormContainer slug config state ]

        Loading ->
            div [] [ text "Sending..." ]

        Failure err ->
            div [] [ text (errorToString err) ]

        Success _ ->
            div [] [ text "Comment successfully sent. Please verify your comment at the given email, ", strong [] [ text state.commentForm.email, text ", within 24 hours." ] ]


commentView : Int -> Comment -> Html msg
commentView index comment =
    styledCommentContainer
        [ styledCommentHeader
            [ styledCommentCount [ text ("#" ++ String.fromInt (index + 1)) ]
            , styledCommenterName [ text ("By " ++ comment.name) ]
            , styledCommentDate
                [ text
                    (formatDate
                        (fromPosix utc (millisToPosix comment.createdAt))
                    )
                ]
            ]
        , styledCommentBody [ Html.Styled.text comment.comment ]
        ]


commentDialog : List (Html msg) -> Html msg
commentDialog =
    div [ css [ padding (rem 1), backgroundColor colors.lighterGray ] ]


commentFormContainer : String -> Config msg -> CommentState -> Html msg
commentFormContainer slug { updateCommentForm, submitComment, commentInfoToggle } { commentForm, commentInfo } =
    div []
        [ h3
            [ css [ fontSize (px 28) ] ]
            [ text "Leave a comment" ]
        , Styled.textInput []
            { onChange = \value -> updateCommentForm { commentForm | name = value }
            , label = "Your name"
            , autoComplete = Just "name"
            }
        , formErrorView commentForm.errors Name
        , Styled.emailInput []
            { onChange = \value -> updateCommentForm { commentForm | email = value }
            , label = "Email"
            , autoComplete = False
            }
        , formErrorView commentForm.errors Email
        , Styled.textAreaInput []
            { onChange = \value -> updateCommentForm { commentForm | message = value }
            , label = "Message"
            }
        , formErrorView commentForm.errors Message
        , div [ css [ displayFlex, justifyContent spaceBetween ] ]
            [ Styled.primaryButton []
                { onPress = submitComment slug
                , label = text "Submit comment"
                , buttonType = "submit"
                }
            , Styled.dangerButton []
                { onPress = commentInfoToggle (not commentInfo)
                , label = text "I want to delete a comment"
                , buttonType = "button"
                }
            ]
        ]


deleteForm : Config msg -> CommentState -> Html msg
deleteForm { updateDeleteCommentForm, commentInfoToggle, requestDeletionEmail } state =
    case state.deleteCommentForm.sendRequest of
        NotAsked ->
            let
                deleteCommentForm =
                    state.deleteCommentForm
            in
            div []
                [ h3 [ css [ fontSize (px 28) ] ] [ text "Delete Comment" ]
                , div [] [ text "Want to delete a comment on this page? Fill in you email. You can delete the comment from your email inbox." ]
                , Styled.emailInput []
                    { onChange =
                        \value ->
                            updateDeleteCommentForm
                                { deleteCommentForm | email = value }
                    , autoComplete = True
                    , label = "Email address"
                    }
                , div [ css [ displayFlex, justifyContent spaceBetween ] ]
                    [ Styled.dangerButton []
                        { onPress = requestDeletionEmail state.deleteCommentForm.email
                        , label = text "Request deletion"
                        , buttonType = "submit"
                        }
                    , Styled.button []
                        { onPress = commentInfoToggle False
                        , label = text "Cancel"
                        , buttonType = "button"
                        }
                    ]
                , formErrorView deleteCommentForm.errors Email
                ]

        Loading ->
            div [] [ text "Sending Request..." ]

        Failure err ->
            div [] [ text (errorToString err) ]

        Success string ->
            div [] [ text "Success! Please check your inbox at ", strong [] [ text string ], text " for info about deleting comments." ]


formErrorView : List CommentError -> CommentField -> Html msg
formErrorView commentError commentField =
    div
        [ css
            [ margin2 (rem 1) zero
            ]
        ]
        (commentError
            |> List.filter (\( field, _ ) -> field == commentField)
            |> List.map (\( _, string ) -> div [ css [ padding (rem 0.3), color colors.red ] ] [ text string ])
        )


styledCommentContainer : List (Html msg) -> Html msg
styledCommentContainer =
    div [ css [ border3 (px 2) dashed colors.black, padding (rem 1), marginBottom (rem 1) ] ]


styledCommentCount : List (Html msg) -> Html msg
styledCommentCount =
    div [ css [ fontWeight bold, marginBottom (rem 0.5) ] ]


styledCommentHeader : List (Html msg) -> Html msg
styledCommentHeader =
    div [ css [ marginBottom (rem 1) ] ]


styledCommenterName : List (Html msg) -> Html msg
styledCommenterName =
    div [ css [ fontWeight bold ] ]


styledCommentDate : List (Html msg) -> Html msg
styledCommentDate =
    div [ css [ fontStyle italic, marginBottom (px 1) ] ]


styledCommentBody : List (Html msg) -> Html msg
styledCommentBody =
    div []



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


commentSendResponseDecoder : Json.Decode.Decoder CommentSendResponse
commentSendResponseDecoder =
    Json.Decode.map CommentSendResponse (Json.Decode.field "success" Json.Decode.bool)



-- HTTP


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


requestDeleteEmail : (WebData String -> msg) -> String -> Cmd msg
requestDeleteEmail message email =
    Http.post
        { url = "https://us-central1-driftercode-comments-f2d95.cloudfunctions.net/comments/request-delete/" ++ email
        , body = Http.emptyBody
        , expect = Http.expectString (RemoteData.fromResult >> message)
        }



-- UPDATE


validateCommentForm : Validator CommentError CommentForm
validateCommentForm =
    Validate.all
        [ ifBlank .email ( Email, "Email is required" )
        , ifInvalidEmail .email (\_ -> ( Email, "Please enter a valid email adress" ))
        , ifBlank .name ( Name, "Name is required" )
        , ifBlank .message ( Message, "Please leave a comment before submitting" )
        ]


validateDeleteCommentForm : Validator DeleteCommentError DeleteCommentForm
validateDeleteCommentForm =
    Validate.all
        [ ifBlank .email ( Email, "Email is required" )
        , ifInvalidEmail .email (\_ -> ( Email, "Please enter a valid email adress" ))
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


submitDeleteCommentForm :
    (WebData String -> msg)
    -> String
    -> { r | deleteCommentForm : DeleteCommentForm }
    -> ( { r | deleteCommentForm : DeleteCommentForm }, Cmd msg )
submitDeleteCommentForm message email model =
    let
        deleteCommentForm =
            model.deleteCommentForm
    in
    case validate validateDeleteCommentForm deleteCommentForm of
        Ok _ ->
            ( { model | deleteCommentForm = { deleteCommentForm | sendRequest = Loading } }, requestDeleteEmail message email )

        Err err ->
            ( { model | deleteCommentForm = { deleteCommentForm | errors = err } }, Cmd.none )
