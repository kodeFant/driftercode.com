module View.Article exposing (view)

import Comment exposing (Comment)
import Data.Author as Author
import Design.Icon
import Design.Palette as Palette
import Element
    exposing
        ( Element
        , centerX
        , column
        , el
        , fill
        , height
        , mouseOver
        , newTabLink
        , padding
        , paragraph
        , px
        , rgba255
        , row
        , spacing
        , text
        , width
        )
import Element.Font as Font
import Element.Region
import Head.Metadata exposing (ArticleMetadata, Metadata)
import Layout.Header
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath exposing (PagePath)
import Types exposing (Model, Msg(..))
import Util.Date exposing (formatDate)


view :
    Model
    -> Int
    -> ArticleMetadata
    -> List Comment
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> List (Element Msg)
    -> Element Msg
view model count metadata comments page viewForPage =
    Element.column
        [ Element.width Element.fill
        ]
        [ Layout.Header.view page.path
        , Element.column
            [ Element.padding 30
            , Element.spacing 40
            , Element.Region.mainContent
            , Element.width (Element.fill |> Element.maximum 750)
            , Element.centerX
            ]
            [ Element.textColumn [ Element.spacing 24, Element.width Element.fill ]
                ([ bio metadata
                 , Palette.blogHeading metadata.title
                 , paragraph [ Font.family [ Font.typeface "Merriweather", Font.sansSerif ], Font.size 24, Font.center ] [ text metadata.description ]
                 , column
                    [ Font.size 16
                    , Font.color (Element.rgba255 0 0 0 0.6)
                    , Font.center
                    , spacing 10
                    ]
                    [ el [ centerX ] (publishedDateView <| metadata)
                    , el [ centerX ] (text (displayReadingLength count))
                    ]
                 , articleImageView metadata.image
                 ]
                    ++ viewForPage
                )
            , Comment.view
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
            ]
        ]


bio : ArticleMetadata -> Element msg
bio metadata =
    Element.row [ Element.spacing 20 ]
        [ Author.view [] metadata.author
        , Element.column [ Element.spacing 10, Element.width Element.fill ]
            [ row [ spacing 16 ]
                [ Element.paragraph [ Font.bold, Font.size 24 ]
                    [ Element.text metadata.author.name
                    ]
                , row [ spacing 10 ]
                    [ newTabLink
                        [ width (px 16)
                        , height (px 16)
                        , Font.color (rgba255 29 161 242 0.5)
                        , mouseOver [ Font.color (rgba255 29 161 242 1) ]
                        ]
                        { label = Design.Icon.twitter [ width fill, height fill ], url = "https://twitter.com/" ++ metadata.author.twitter }
                    , newTabLink
                        [ width (px 16)
                        , height (px 16)
                        , Font.color (rgba255 29 161 242 0.5)
                        , mouseOver [ Font.color (rgba255 29 161 242 1) ]
                        ]
                        { label = Design.Icon.linkedIn [ width fill, height fill ], url = metadata.author.linkedinUrl }
                    ]
                ]
            , Element.paragraph [ Font.size 16 ]
                [ Element.text metadata.author.bio ]
            ]
        ]


publishedDateView : Head.Metadata.ArticleMetadata -> Element msg
publishedDateView metadata =
    Element.text
        (formatDate
            metadata.published
        )


articleImageView : ImagePath Pages.PathKey -> Element msg
articleImageView articleImage =
    Element.image [ Element.width Element.fill ]
        { src = ImagePath.toString articleImage
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
