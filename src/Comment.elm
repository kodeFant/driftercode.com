module Comment exposing (Comment, commentsDecoder, view)

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
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline
import RemoteData exposing (RemoteData(..))
import Time exposing (millisToPosix, utc)
import Types exposing (Model, Msg(..))
import Util.Date exposing (formatDate)


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


type Responses
    = Responses (List Comment)


view : String -> Model -> List Comment -> Element Msg
view slug model comments =
    column [ width fill, spacing 28 ]
        [ el
            [ Font.bold, Font.size 28 ]
            (text "Comments")
        , commentFormView slug model
        , column [ width fill, spacing 20 ]
            (comments
                |> List.map
                    commentView
            )
        ]


commentFormView : String -> Model -> Element Msg
commentFormView slug model =
    let
        { commentForm } =
            model
    in
    case model.commentForm.sendRequest of
        NotAsked ->
            column [ width fill, spacing 28 ]
                [ Input.text
                    [ width fill ]
                    { onChange = \value -> UpdateCommentForm { commentForm | name = value }
                    , text = commentForm.name
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Name")
                    }
                , column [ spacing 10, width fill ]
                    [ Input.email
                        [ width fill ]
                        { onChange = \value -> UpdateCommentForm { commentForm | email = value }
                        , text = commentForm.email
                        , placeholder = Nothing
                        , label = Input.labelAbove [] (text "Email")
                        }
                    ]
                , Input.multiline
                    [ width fill ]
                    { onChange = \value -> UpdateCommentForm { commentForm | message = value }
                    , text = commentForm.message
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "Your message")
                    , spellcheck = False
                    }
                , Input.button
                    [ width fill
                    , padding 10
                    , Font.center
                    , Font.color color.white
                    , Font.bold
                    , Background.color color.primary
                    , mouseOver [ Background.color color.secondary ]
                    ]
                    { onPress = Just (SubmitComment slug)
                    , label = text "Submit"
                    }
                , Input.button [ centerX, Font.size 14 ] { label = text "I want to delete a comment", onPress = Just (CommentInfo (not model.commentInfo)) }
                , if model.commentInfo == True then
                    deleteForm model

                  else
                    none
                ]

        Loading ->
            paragraph [] [ text "Sending..." ]

        Failure _ ->
            paragraph [] [ text "Something went wrong. Try again later" ]

        Success _ ->
            paragraph [] [ text "Comment successfully sent. Please verify your comment at the given email, ", el [ Font.bold ] (text commentForm.email), text ", within 24 hours." ]


deleteForm : Model -> Element Msg
deleteForm model =
    case model.deleteCommentForm.sendRequest of
        NotAsked ->
            let
                deleteCommentForm =
                    model.deleteCommentForm
            in
            column [ width fill, spacing 16, Border.width 2, padding 16 ]
                [ el [ centerX, Font.bold ] (text "Delete Comment")
                , paragraph [ Font.center, Font.italic ] [ text "Want to delete a comment on this page? Fill in you email. You can delete the comment from your email inbox." ]
                , Input.email
                    [ width fill ]
                    { onChange = \value -> UpdateDeleteCommentForm { deleteCommentForm | email = value }
                    , text = model.deleteCommentForm.email
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
                    { onPress = Just (RequestDeletionEmail model.deleteCommentForm.email)
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
                    { onPress = Just (CommentInfo False)
                    , label = text "Cancel"
                    }
                ]

        Loading ->
            el [] (text "Sending Request...")

        Failure _ ->
            el [] (text "Something went wrong")

        Success string ->
            paragraph [] [ text "Success! Please check your inbox at ", el [ Font.bold ] (text string), text " for info about deleting comments." ]


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
