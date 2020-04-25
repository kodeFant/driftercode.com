module View.SiteIndex exposing (view)

import Constants
import Css exposing (..)
import Design.Icon as Icon
import Design.Palette exposing (colors)
import Design.Responsive as Responsive
import Head.Metadata exposing (Index, Metadata(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Scaffold
import Pages
import Pages.ImagePath as ImagePath
import Pages.PagePath exposing (PagePath)
import Styled


view :
    Index
    -> List ( PagePath Pages.PathKey, Metadata )
    -> List (Html msg)
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Html msg
view indexMeta posts rendered page =
    Layout.Scaffold.view page.path
        (div
            [ css [ displayFlex, flexDirection column, alignItems center, Css.width (pct 100) ] ]
            [ styledIndexHero
                [ div
                    [ css [ Css.width (pct 100) ] ]
                    [ Styled.heading1 [ marginTop zero, fontWeight normal, fontSize (px 64) ] [ text indexMeta.title ]
                    , div [ css [ fontSize (px 22) ] ]
                        [ text indexMeta.subHeading ]
                    , div [ css [ padding2 (rem 2.5) zero, fontSize (px 18) ] ]
                        [ p [] [ text "A budding functional programmer who used to be a journalist." ]
                        , p [] [ text "I’m learning functional programming by blogging about it." ]
                        , p [] [ text "Mathy algebraic slang to be kept at a minimum." ]
                        ]
                    , div [ css [ displayFlex ] ]
                        [ Styled.buttonLink
                            [ href indexMeta.buttonLink ]
                            [ text indexMeta.buttonText ]
                        ]
                    ]
                , Styled.image
                    [ css
                        [ Css.width auto
                        , Css.maxWidth (pct 100)
                        , Css.maxHeight (pct 90)
                        , float right
                        ]
                    ]
                    { path = ImagePath.toString Pages.images.driftercode, description = "" }
                , socialMediaLinks
                , languageLinks
                ]
            ]
        )
        False


socialMediaLinks : Html msg
socialMediaLinks =
    div [ css [ displayFlex, paddingBottom (rem 2) ] ]
        [ Styled.newTabLink []
            { content = [ iconContainer [ marginRight (rem 1) ] [ Icon.twitter ] ]
            , url = "https://twitter.com/" ++ Constants.siteTwitter
            , css = socialMediaStyle
            }
        , Styled.newTabLink []
            { content = [ iconContainer [ marginRight (rem 1) ] [ Icon.linkedIn ] ]
            , url = Constants.siteLinkedIn
            , css = socialMediaStyle
            }
        , Styled.newTabLink []
            { content = [ iconContainer [ marginRight (rem 1) ] [ Icon.github ] ]
            , url = Constants.githubLink
            , css = socialMediaStyle
            }
        ]


socialMediaStyle : List Style
socialMediaStyle =
    [ color colors.drifterCoal, hover [ color colors.black ] ]


languageLinks : Html msg
languageLinks =
    div [ css [ displayFlex, justifyContent flexEnd, alignItems center, paddingBottom (rem 2) ] ]
        [ span [ css [ fontWeight bold ] ] [ text "Featuring" ]
        , Styled.newTabLink []
            { url = "https://elm-lang.org/"
            , content = [ iconContainer [ marginLeft (rem 1) ] [ Styled.image [] { description = "TypeScript", path = ImagePath.toString Pages.images.typescript } ] ]
            , css = []
            }
        , Styled.newTabLink []
            { url = "https://www.typescriptlang.org/"
            , content = [ iconContainer [ marginLeft (rem 1) ] [ Styled.image [] { description = "Elm", path = ImagePath.toString Pages.images.elm } ] ]
            , css = []
            }
        ]


iconContainer : List Style -> List (Html msg) -> Html msg
iconContainer styles =
    div [ css ([ Css.height (px 25), Css.width (px 25) ] ++ styles) ]


styledIndexHero : List (Html msg) -> Html msg
styledIndexHero =
    div
        [ css
            [ padding (rem 1)
            , Css.height (vh 100)
            , Css.width (pct 100)
            , Css.maxWidth (px 1000)
            , Responsive.tabletUp
                [ Css.property "display" "grid"
                , Css.property "grid-template-columns" "1fr 1fr"
                , Css.property "align-items" "center"
                , Css.property "grid-template-rows" "auto 2rem"
                ]
            ]
        ]
