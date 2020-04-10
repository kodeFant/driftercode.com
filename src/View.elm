module View exposing (view)

import Comment exposing (Comment, commentsDecoder)
import Data.Author as Author
import Design.Palette as Palette exposing (color)
import Element
    exposing
        ( Element
        , centerX
        , column
        , fill
        , height
        , padding
        , text
        , width
        )
import Element.Font as Font
import Element.Region
import Head
import Html exposing (Html)
import Metadata exposing (Metadata)
import PageHead exposing (head)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Secrets as Secrets
import Pages.StaticHttp as StaticHttp
import Renderer exposing (Rendered)
import Types exposing (Model, Msg)
import View.Article
import View.BlogIndex
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
    StaticHttp.map
        (\comments ->
            { view =
                \model viewForPage ->
                    let
                        { title, body } =
                            pageView model comments siteMetadata page viewForPage
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
        )
        (StaticHttp.request
            (Secrets.succeed
                (\functionUrl ->
                    { url = functionUrl
                    , method = "GET"
                    , headers = []
                    , body = StaticHttp.emptyBody
                    }
                )
                |> Secrets.with "FUNCTIONS_URL"
            )
            commentsDecoder
        )


pageView :
    Model
    -> List Comment
    -> List ( PagePath Pages.PathKey, Metadata )
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Rendered Msg
    -> { title : String, body : Element Msg }
pageView model comments siteMetadata page ( count, viewForPage ) =
    case page.frontmatter of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                View.Page.view metadata.title viewForPage page
            }

        Metadata.Article metadata ->
            let
                filteredComments =
                    comments
                        |> List.filter (\comment -> comment.path == metadata.slug)
            in
            { title = metadata.title
            , body = View.Article.view model count metadata filteredComments page viewForPage
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
                        [ View.BlogIndex.view siteMetadata viewForPage ]
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
