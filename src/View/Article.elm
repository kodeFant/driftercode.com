module View.Article exposing (view)

import Comment exposing (Comment)
import Data.Author as Author
import Element
import Head.Metadata exposing (ArticleMetadata, Metadata)
import Html.Styled exposing (..)
import Layout.Header
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath exposing (PagePath)
import Styled
import Types exposing (Model, Msg(..))
import Util.Date exposing (formatDate)


view :
    Model
    -> Int
    -> ArticleMetadata
    -> List Comment
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> List (Html Msg)
    -> Html Msg
view model count metadata comments page viewForPage =
    div []
        [ Layout.Header.view page.path
        , bio metadata
        , text metadata.title
        , text metadata.description
        , text (publishedDateView <| metadata)
        , text (displayReadingLength count)
        , articleImageView metadata.image
        , div [] viewForPage
        , fromUnstyled
            (Element.layout
                []
                (Comment.view
                    { commentInfoToggle = CommentInfo
                    , updateCommentForm = UpdateCommentForm
                    , updateDeleteCommentForm = UpdateDeleteCommentForm
                    , submitComment = SubmitComment
                    , requestDeletionEmail = RequestDeletionEmail
                    }
                    { commentForm = model.commentForm
                    , commentInfo = model.commentInfo
                    , deleteCommentForm = model.deleteCommentForm
                    }
                    metadata.slug
                    comments
                )
            )
        ]


bio : ArticleMetadata -> Html msg
bio metadata =
    div []
        [ div []
            [ Author.view []
                metadata.author
            , div
                []
                [ text metadata.author.name ]
            ]
        , div []
            [ text "twitterLink"
            , text "linkedInLink"
            ]
        , div [] [ text metadata.author.bio ]
        ]



-- Element.row [ Element.spacing 20 ]
--     [ Author.elmUIView [] metadata.author
--     , Element.column [ Element.spacing 10, Element.width Element.fill ]
--         [ row [ spacing 16 ]
--             [ Element.paragraph [ Font.bold, Font.size 24, Font.family [ Font.typeface "Merriweather" ] ]
--                 [ Element.text metadata.author.name
--                 ]
--             , row [ spacing 10 ]
--                 [ newTabLink
--                     [ width (px 16)
--                     , height (px 16)
--                     , Font.color (rgba255 29 161 242 0.5)
--                     , mouseOver [ Font.color (rgba255 29 161 242 1) ]
--                     ]
--                     { label = Design.Icon.twitter [ width fill, height fill ], url = "https://twitter.com/" ++ metadata.author.twitter }
--                 , newTabLink
--                     [ width (px 16)
--                     , height (px 16)
--                     , Font.color (rgba255 29 161 242 0.5)
--                     , mouseOver [ Font.color (rgba255 29 161 242 1) ]
--                     ]
--                     { label = Design.Icon.linkedIn [ width fill, height fill ], url = metadata.author.linkedinUrl }
--                 ]
--             ]
--         , Element.paragraph [ Font.size 16 ]
--             [ Element.text metadata.author.bio ]
--         ]
--     ]


publishedDateView : Head.Metadata.ArticleMetadata -> String
publishedDateView metadata =
    formatDate
        metadata.published


articleImageView : ImagePath Pages.PathKey -> Html msg
articleImageView articleImage =
    Styled.image []
        { path = ImagePath.toString articleImage
        , description = "Article cover photo"
        }


displayReadingLength : Int -> String
displayReadingLength wordCount =
    let
        readingLength : Float
        readingLength =
            toFloat
                wordCount
                / 265.0
    in
    if readingLength < 1 then
        "Less than one minute"

    else
        String.fromInt (round readingLength) ++ " minute read"
