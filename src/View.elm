module View exposing (view)

import Comment exposing (Comment, commentsDecoder)
import Head
import Head.Metadata exposing (Metadata)
import Head.PageHead exposing (head)
import Html
import Html.Styled exposing (Html, div, toUnstyled)
import Pages
import Pages.PagePath exposing (PagePath)
import Pages.Secrets as Secrets
import Pages.StaticHttp as StaticHttp
import Renderer.View exposing (Rendered)
import Types exposing (Model, Msg)
import View.Article
import View.BlogList
import View.Page
import View.SiteIndex


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Rendered Msg -> { title : String, body : Html.Html Msg }
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
                        toUnstyled body
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
    -> { title : String, body : Html Msg }
pageView model comments siteMetadata page ( count, viewForPage ) =
    case page.frontmatter of
        Head.Metadata.Page metadata ->
            { title = metadata.title
            , body =
                View.Page.view metadata.title viewForPage page
            }

        Head.Metadata.Article metadata ->
            let
                filteredComments =
                    comments
                        |> List.filter (\comment -> comment.path == metadata.slug)
            in
            { title = metadata.title
            , body = View.Article.view model count metadata filteredComments page viewForPage
            }

        Head.Metadata.SiteIndex indexMeta ->
            { title = "Home"
            , body =
                View.SiteIndex.view indexMeta siteMetadata viewForPage page
            }

        Head.Metadata.BlogIndex ->
            { title = "Blog"
            , body =
                View.BlogList.view siteMetadata viewForPage page
            }

        Head.Metadata.Author author ->
            { title = author.name
            , body =
                div [] []
            }
