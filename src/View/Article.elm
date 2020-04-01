module View.Article exposing (view)

import Comment exposing (Comment)
import Data.Author as Author
import Design.Palette as Palette
import Design.Styles exposing (linkStyle)
import Element exposing (Element, centerX, column, el, fill, html, link, newTabLink, none, padding, paragraph, rgb255, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Region
import Metadata exposing (ArticleMetadata, Metadata)
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath exposing (PagePath)
import Types exposing (Model, Msg)
import Util.Date exposing (formatDate)
import View.Header


view :
    Model
    -> Int
    -> ArticleMetadata
    -> List Comment
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> List (Element Msg)
    -> Element Msg
view model count metadata comments page viewForPage =
    Element.column [ Element.width Element.fill ]
        [ View.Header.view page.path
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
            , paragraph [ width fill, Border.width 2, Border.color (rgb255 25 25 25), padding 10 ]
                [ text "Any comments? "
                , newTabLink linkStyle
                    { label = text "Drop me a tweet 😀"
                    , url = "https://twitter.com/intent/tweet?text=Hey%2C%20%40larsparsfromage"
                    }
                , el [] (text " I'll implement some comment system when I have some spare time. Will probably avoid Disqus, so I am open for some good advice.")
                ]
            , Comment.view metadata.slug model.commentForm comments
            ]
        ]


bio : ArticleMetadata -> Element msg
bio metadata =
    Element.row [ Element.spacing 20 ]
        [ Author.view [] metadata.author
        , Element.column [ Element.spacing 10, Element.width Element.fill ]
            [ Element.paragraph [ Font.bold, Font.size 24 ]
                [ Element.text metadata.author.name
                ]
            , Element.paragraph [ Font.size 16 ]
                [ Element.text metadata.author.bio ]
            ]
        ]


publishedDateView : Metadata.ArticleMetadata -> Element msg
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
