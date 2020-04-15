module View.BlogIndex exposing (view)

import Css exposing (..)
import Data.Author
import Date
import Design.Palette exposing (colors)
import Design.Responsive as Responsive
import Head.Metadata exposing (Metadata(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Scaffold
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
    Layout.Scaffold.view page.path
        (Styled.mainContainer
            [ blogIndexContainer
                [ indexAuthor
                    [ Data.Author.view
                        [ css [ Css.width (px 60), borderRadius (pct 50) ]
                        ]
                        Data.Author.defaultAuthor
                    , div [] rendered
                    ]
                , blogIndexItems posts
                ]
            ]
        )


indexAuthor : List (Html msg) -> Html msg
indexAuthor content =
    div
        [ css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "auto 1fr"
            , Css.property "grid-gap" "1rem"
            , alignItems center
            , padding2 (rem 3) zero
            ]
        ]
        content


blogIndexItems : List ( PagePath Pages.PathKey, Metadata ) -> Html msg
blogIndexItems posts =
    div
        [ css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "1fr"
            , Css.property "grid-gap" "1rem"
            , Responsive.tabletUp
                [ Css.property "grid-template-columns" "1fr 1fr"
                ]
            ]
        ]
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
    indexCard ( postPath, post )
        [ indexCardPart1
            [ indexCardImage (ImagePath.toString post.image)
            ]
        , indexCardPart2
            [ div []
                [ indexCardDate [ text (post.published |> formatDate) ]
                , indexCardTitle [ text post.title ]
                , indexCardDescription [ text post.description ]
                ]
            ]
        ]


indexCard : ( PagePath Pages.PathKey, Head.Metadata.ArticleMetadata ) -> List (Html msg) -> Html msg
indexCard ( postPath, _ ) content =
    a
        [ href (PagePath.toString postPath)
        , css
            [ textDecoration none
            , color colors.black
            , borderRadius (px 7)
            , Responsive.tabletUp [ border3 (px 4) solid colors.lighterGray ]
            , fontFamilies [ "Merriweather" ]
            , fontSize (rem 1)
            , firstOfType
                [ Responsive.desktopUp
                    [ Css.property "display" "grid"
                    , Css.property "grid-column-start" "1"
                    , Css.property "grid-column-end" "3"
                    , Css.property "grid-template-columns" "3fr 2fr"
                    , Css.property "grid-gap" "1rem"
                    , Css.height (px 400)
                    ]
                ]
            , hover
                [ border3 (px 4) solid colors.secondary
                ]
            ]
        ]
        content


indexCardPart1 : List (Html msg) -> Html msg
indexCardPart1 content =
    div [] content


indexCardPart2 : List (Html msg) -> Html msg
indexCardPart2 content =
    div
        [ css
            [ displayFlex
            , padding (rem 1)
            , justifyContent center
            , alignItems center
            , textAlign center
            ]
        ]
        content


indexCardDate : List (Html msg) -> Html msg
indexCardDate content =
    div [ css [ fontWeight bold ] ] content


indexCardTitle : List (Html msg) -> Html msg
indexCardTitle content =
    h2 [ css [ fontSize (rem 2) ] ] content


indexCardDescription : List (Html msg) -> Html msg
indexCardDescription content =
    div [ css [ fontSize (rem 1.3) ] ] content


indexCardImage : String -> Html msg
indexCardImage imagePath =
    Styled.image
        [ css
            [ Css.height (pct 100)
            , Css.property "object-fit" "cover"
            ]
        ]
        { description = "", path = imagePath }


blogIndexContainer : List (Html msg) -> Html msg
blogIndexContainer content =
    div
        [ css
            [ maxWidth (px 900)
            ]
        ]
        content
