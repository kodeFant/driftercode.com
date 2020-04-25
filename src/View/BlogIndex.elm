module View.BlogIndex exposing (view)

import Css exposing (..)
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
        (div
            [ css [ displayFlex, flexDirection column, paddingTop (rem 5) ] ]
            [ Styled.mainContainer []
                [ styledIndexContainer
                    [ blogIndexItems posts
                    ]
                ]
            ]
        )
        True


blogIndexItems : List ( PagePath Pages.PathKey, Metadata ) -> Html msg
blogIndexItems posts =
    styledIndexItemsGrid
        (posts
            |> List.filterMap
                (\( path, metadata ) ->
                    case metadata of
                        Head.Metadata.Article meta ->
                            if meta.draft then
                                Nothing

                            else
                                Just ( path, meta )

                        _ ->
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
        [ styledIndexCardPart1
            [ styledIndexCardImage (ImagePath.toString post.image)
            ]
        , styledIndexCardPart2
            [ div []
                [ styledIndexCardDate [ text (post.published |> formatDate) ]
                , styledIndexCardTitle [ text post.title ]
                , styledIndexCardDescription [ text post.description ]
                ]
            ]
        ]



-- STYLED


styledIndexItemsGrid : List (Html msg) -> Html msg
styledIndexItemsGrid =
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


indexCard : ( PagePath Pages.PathKey, Head.Metadata.ArticleMetadata ) -> List (Html msg) -> Html msg
indexCard ( postPath, _ ) =
    a
        [ href (PagePath.toString postPath)
        , css
            [ textDecoration none
            , color colors.black
            , borderRadius (px 7)
            , Responsive.tabletUp [ border3 (px 4) solid colors.lighterGray ]
            , fontFamilies [ "Rye" ]
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


styledIndexCardPart1 : List (Html msg) -> Html msg
styledIndexCardPart1 =
    div []


styledIndexCardPart2 : List (Html msg) -> Html msg
styledIndexCardPart2 =
    div
        [ css
            [ displayFlex
            , padding (rem 1)
            , justifyContent center
            , alignItems center
            , textAlign center
            ]
        ]


styledIndexCardDate : List (Html msg) -> Html msg
styledIndexCardDate =
    div [ css [ fontWeight bold ] ]


styledIndexCardTitle : List (Html msg) -> Html msg
styledIndexCardTitle =
    h2 [ css [ fontSize (rem 2) ] ]


styledIndexCardDescription : List (Html msg) -> Html msg
styledIndexCardDescription =
    div [ css [ fontSize (rem 1.3) ] ]


styledIndexCardImage : String -> Html msg
styledIndexCardImage imagePath =
    Styled.image
        [ css
            [ Css.height (pct 100)
            , Css.property "object-fit" "cover"
            , firstOfType [ padding (rem 1.5) ]
            ]
        ]
        { description = "", path = imagePath }



-- CONTAINER


styledIndexContainer : List (Html msg) -> Html msg
styledIndexContainer =
    div
        [ css
            [ maxWidth (px 900)
            ]
        ]
