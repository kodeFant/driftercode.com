module View.Article exposing (view)

import Comment exposing (Comment)
import Component.Bio exposing (bio)
import Constants
import Css exposing (..)
import Design.Palette exposing (colors)
import Head.Metadata exposing (ArticleMetadata, Metadata)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Scaffold
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
    Layout.Scaffold.view page.path
        (Styled.mainContainer [ paddingTop (rem 5) ]
            [ styledContentContainer
                [ bio metadata
                , Styled.heading1 [ textAlign center, margin2 (rem 1) zero, fontWeight normal ]
                    [ text metadata.title ]
                , styledPreamble
                    [ text metadata.description ]
                , styledMetadata
                    [ styledPublishedDate [ text "Published: ", text (publishedDateView <| metadata) ]
                    , styledReadingLength
                        [ text (displayReadingLength count) ]
                    ]
                , articleImageView metadata.image
                , article [] viewForPage
                -- , Comment.view
                --     { commentInfoToggle = CommentInfo
                --     , updateCommentForm = UpdateCommentForm
                --     , updateDeleteCommentForm = UpdateDeleteCommentForm
                --     , submitComment = SubmitComment
                --     , requestDeletionEmail = RequestDeletionEmail
                --     }
                --     { commentForm = model.commentForm
                --     , commentInfo = model.commentInfo
                --     , deleteCommentForm = model.deleteCommentForm
                --     }
                --     metadata.slug
                --     comments
                -- ]
            ]
        )
        True



-- UTILS


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
        String.fromInt (Basics.round readingLength) ++ " minute read"



-- METADATA CONTAINER


styledMetadata : List (Html msg) -> Html msg
styledMetadata =
    div
        [ css
            [ color colors.darkestGray
            , textAlign center
            , fontSize (rem 0.9)
            , margin2 (rem 2) zero
            ]
        ]


styledPublishedDate : List (Html msg) -> Html msg
styledPublishedDate =
    div [ css [ marginBottom (rem 0.5) ] ]


styledReadingLength : List (Html msg) -> Html msg
styledReadingLength =
    div
        []



-- PREAMBLE


styledPreamble : List (Html msg) -> Html msg
styledPreamble =
    div
        [ css
            [ fontSize (rem 2)
            , textAlign center
            , fontSize (px 24)
            , fontWeight (int 400)
            , margin2 (rem 2) zero
            ]
        ]



-- CONTAINER


styledContentContainer : List (Html msg) -> Html msg
styledContentContainer =
    div
        [ css [ maxWidth Constants.maxWidthDefault, Css.width (pct 100), padding (rem 1), backgroundColor colors.trueWhite ] ]
