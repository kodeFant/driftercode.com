module View.Article exposing (view)

import Comment exposing (Comment)
import Css exposing (..)
import Data.Author as Author
import Design.Icon
import Element
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
        (Styled.mainContainer
            [ articleContainer
                [ bio metadata
                , Styled.heading1 [ css [ textAlign center ] ] [ text metadata.title ]
                , div
                    [ css
                        [ fontSize (rem 2)
                        , textAlign center
                        , fontSize (px 25)
                        ]
                    ]
                    [ text metadata.description ]
                , div
                    [ css [ textAlign center ] ]
                    [ div [] [ text (publishedDateView <| metadata) ]
                    , div [] [ text (displayReadingLength count) ]
                    ]
                , articleImageView metadata.image
                , div [] viewForPage

                -- , Html.Styled.fromUnstyled
                --     (Element.layout
                --         []
                --         (Comment.view
                --             { commentInfoToggle = CommentInfo
                --             , updateCommentForm = UpdateCommentForm
                --             , updateDeleteCommentForm = UpdateDeleteCommentForm
                --             , submitComment = SubmitComment
                --             , requestDeletionEmail = RequestDeletionEmail
                --             }
                --             { commentForm = model.commentForm
                --             , commentInfo = model.commentInfo
                --             , deleteCommentForm = model.deleteCommentForm
                --             }
                --             metadata.slug
                --             comments
                --         )
                --     )
                ]
            ]
        )


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


bio : ArticleMetadata -> Html msg
bio metadata =
    div
        [ css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "auto 1fr"
            , Css.property "grid-gap" "1rem"
            , padding2 (rem 2) (rem 0)
            ]
        ]
        [ Author.view []
            metadata.author
        , div
            [ css
                [ Css.property "display" "grid"
                , Css.property "grid-template-columns" "1fr"
                , Css.property "grid-gap" "0.1rem"
                , padding2 (px 0) (rem 1)
                ]
            ]
            [ div [ css [ displayFlex, alignItems center ] ]
                [ span
                    [ css
                        [ fontWeight bold
                        , fontSize (px 24)
                        , marginRight (rem 1)
                        ]
                    ]
                    [ text metadata.author.name ]
                , div [ css [ displayFlex, alignItems center ] ]
                    [ a
                        [ href ("https://twitter.com/" ++ metadata.author.twitter)
                        , Html.Styled.Attributes.target "_blank"
                        , rel "noreferrer noopener"
                        , css
                            [ Css.width (px 16)
                            , marginRight (rem 0.5)
                            , color (rgba 29 161 242 0.5)
                            , hover [ color (rgba 29 161 242 0.9) ]
                            ]
                        ]
                        [ Design.Icon.twitter ]
                    , a
                        [ href metadata.author.linkedinUrl
                        , Html.Styled.Attributes.target "_blank"
                        , rel "noreferrer noopener"
                        , css
                            [ Css.width (px 16)
                            , color (rgba 29 161 242 0.5)
                            , hover [ color (rgba 29 161 242 0.9) ]
                            ]
                        ]
                        [ Design.Icon.linkedIn ]
                    ]
                ]
            , div [] [ text metadata.author.bio ]
            ]
        ]


articleContainer : List (Html msg) -> Html msg
articleContainer content =
    article
        [ css [ maxWidth (px 700), Css.width (pct 100), padding (rem 1) ] ]
        content
