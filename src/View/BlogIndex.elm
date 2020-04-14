module View.BlogIndex exposing (view)

import Data.Author
import Date
import Head.Metadata exposing (Metadata(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Footer
import Layout.Header
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)
import Styled
import Util.Date exposing (formatDate)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> List (Html msg)
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Html msg
view posts rendered page =
    div [ style "width" "100%" ]
        [ Layout.Header.view page.path
        , div [ class "blog-index" ]
            [ div [ class "index-author" ]
                [ Data.Author.view
                    [ style "width" "60px"
                    , style "border-radius" "50%"
                    ]
                    Data.Author.defaultAuthor
                , div [] rendered
                ]
            , blogIndexItems posts
            ]
        , Layout.Footer.view
        ]


blogIndexItems : List ( PagePath Pages.PathKey, Metadata ) -> Html msg
blogIndexItems posts =
    div [ class "blog-index-items" ]
        (posts
            |> List.filterMap
                (\( path, metadata ) ->
                    case metadata of
                        Head.Metadata.Page _ ->
                            Nothing

                        Head.Metadata.Author _ ->
                            Nothing

                        Head.Metadata.Article meta ->
                            if meta.draft then
                                Nothing

                            else
                                Just ( path, meta )

                        Head.Metadata.BlogIndex ->
                            Nothing
                )
            |> List.sortWith
                (\( _, metaA ) ( _, metaB ) -> Date.compare metaA.published metaB.published)
            |> List.reverse
            |> List.map blogIndexItem
        )


blogIndexItem : ( PagePath Pages.PathKey, Head.Metadata.ArticleMetadata ) -> Html msg
blogIndexItem ( postPath, post ) =
    a [ class "index-card", href (PagePath.toString postPath) ]
        [ div [ class "index-card__part1" ]
            [ Styled.image [ class "index-card__image" ] { description = "", path = ImagePath.toString post.image }
            ]
        , div [ class "index-card__part2" ]
            [ div []
                [ div [ class "index-card__date" ] [ text (post.published |> formatDate) ]
                , h2 [ class "index-card__title" ] [ text post.title ]
                , div [ class "index-card__description" ] [ text post.description ]
                ]
            ]
        ]
