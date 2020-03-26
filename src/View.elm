module View exposing (view)

import BlogIndex
import Data.Author as Author
import Design.Palette as Palette
import Element
    exposing
        ( Element
        , centerX
        , column
        , fill
        , height
        , text
        , width
        )
import Element.Font as Font
import Element.Region
import Head
import Html exposing (Html)
import MarkdownRenderer exposing (Rendered)
import Metadata exposing (Metadata)
import PageHead exposing (head)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.StaticHttp as StaticHttp
import Types exposing (Model, Msg)
import View.Article
import View.Header
import View.Page


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Rendered Msg -> { title : String, body : Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.succeed
        { view =
            \model viewForPage ->
                let
                    { title, body } =
                        pageView model siteMetadata page viewForPage
                in
                { title = title ++ " | DrifterCode"
                , body =
                    Element.layout
                        [ Element.width Element.fill
                        , height fill
                        , Font.size 20
                        , Font.family [ Font.typeface "Open Sans", Font.sansSerif ]
                        , Font.color (Element.rgba255 0 0 0 0.8)
                        ]
                        body
                }
        , head = head page.frontmatter
        }


pageView :
    Model
    -> List ( PagePath Pages.PathKey, Metadata )
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Rendered Msg
    -> { title : String, body : Element Msg }
pageView _ siteMetadata page ( count, viewForPage ) =
    case page.frontmatter of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                View.Page.view metadata.title viewForPage page
            }

        Metadata.Article metadata ->
            { title = metadata.title
            , body = View.Article.view count metadata page viewForPage
            }

        Metadata.BlogIndex ->
            { title = "Blog"
            , body =
                Element.column [ Element.width Element.fill ]
                    [ View.Header.view page.path
                    , Element.column
                        [ Element.centerX
                        , Element.paddingXY 0 50
                        ]
                        [ BlogIndex.view siteMetadata viewForPage ]
                    ]
            }

        Metadata.Author author ->
            { title = author.name
            , body =
                Element.column
                    [ Element.width Element.fill
                    ]
                    [ View.Header.view page.path
                    , Element.column
                        [ Element.padding 30
                        , Element.spacing 20
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        [ Palette.blogHeading author.name
                        , Author.view [] author
                        , Element.paragraph [ Element.centerX, Font.center ] [ Element.text "viewForPage" ]
                        ]
                    ]
            }
