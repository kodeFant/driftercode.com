module Comment exposing (Comment, commentsDecoder, view)

import Date exposing (fromPosix)
import Design.Palette exposing (color)
import Design.Responsive exposing (responsiveView)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline
import RemoteData exposing (RemoteData(..))
import Time exposing (millisToPosix, utc)
import Types exposing (CommentForm, Model, Msg(..))
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


view : String -> CommentForm -> List Comment -> Element Msg
view slug commentForm comments =
    column [ width fill, spacing 28 ]
        [ el
            [ Font.bold, Font.size 28 ]
            (text "Comments")
        , commentFormView slug commentForm
        , column [ width fill, spacing 20 ]
            (comments
                |> List.map
                    commentView
            )
        ]


commentFormView : String -> CommentForm -> Element Msg
commentFormView slug commentForm =
    case commentForm.sendRequest of
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
                    [ Input.text
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
                    , paragraph [ Font.size 14, Font.italic ] [ text "My comment system is pretty simple at this moment. If you wisht to delete a message, send me an email (available in the confirmation mail you will recieve)." ]
                ]

        Loading ->
            paragraph [] [ text "Sending..." ]

        Failure err ->
            paragraph [] [ text "Something went wrong. Try again later" ]

        Success _ ->
            paragraph [] [ text "Comment successfully sent. Please verify your comment at the given email, ", el [ Font.bold ] (text commentForm.email), text ", within 24 hours." ]


commentHeader : Comment -> List (Element msg) -> Element msg
commentHeader comment content =
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
