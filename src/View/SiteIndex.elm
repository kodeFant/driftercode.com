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
view indexMeta _ _ page =
    Layout.Scaffold.view page.path
        (div
            [ css [ displayFlex, flexDirection column, alignItems center, Css.width (pct 100), maxHeight (vh 100) ] ]
            [ styledIndexHero
                [ styledHeroContent
                    [ styledTitle [ text indexMeta.title ]
                    , styledSubTitle [ text indexMeta.subHeading ]
                    , div
                        [ css
                            [ display none
                            , Responsive.tabletUp
                                [ padding2 (rem 2.5) zero
                                , fontSize (px 18)
                                , display block
                                ]
                            ]
                        ]
                        [ p [] [ text "A budding functional programmer who used to be a journalist." ]
                        , p [] [ text "I’m learning functional programming by blogging about it." ]
                        , p [] [ text "Mathy algebraic slang to be kept at a minimum." ]
                        ]
                    , div [ css [ displayFlex, justifyContent center, marginTop (rem 2), Responsive.tabletUp [ justifyContent flexStart ] ] ]
                        [ Styled.buttonLink
                            [ href indexMeta.buttonLink ]
                            [ text indexMeta.buttonText ]
                        ]
                    ]
                , Styled.image
                    [ css
                        [ Css.width auto
                        , Css.maxWidth (pct 100)
                        , float right
                        , Css.property "grid-area" "image"
                        , Responsive.tabletUp [ Css.maxHeight (pct 90) ]
                        , alignSelf center
                        ]
                    ]
                    { path = ImagePath.toString Pages.images.driftercode, description = "" }
                , socialMediaLinks
                , languageLinks
                ]
            ]
        )
        False


styledHeroContent : List (Html msg) -> Html msg
styledHeroContent =
    div
        [ css [ Css.width (pct 100), Css.property "grid-area" "content" ] ]


styledTitle : List (Html msg) -> Html msg
styledTitle =
    Styled.heading1
        [ fontSize (px 32)
        , textAlign center
        , Responsive.tabletUp
            [ fontSize (px 64)
            , marginTop zero
            , fontWeight normal
            , textAlign left
            ]
        ]


styledSubTitle : List (Html msg) -> Html msg
styledSubTitle =
    div [ css [ fontSize (px 22), textAlign center, Responsive.tabletUp [ textAlign left ] ] ]


socialMediaLinks : Html msg
socialMediaLinks =
    div [ css [ displayFlex, paddingBottom (rem 2), Css.property "grid-area" "some", justifyContent center, Responsive.tabletUp [ justifyContent flexStart ] ] ]
        [ Styled.newTabLink []
            { content = [ styledIconContainer [ marginRight (rem 1) ] [ Icon.twitter ] ]
            , url = "https://twitter.com/" ++ Constants.siteTwitter
            , css = socialMediaStyle
            }
        , Styled.newTabLink []
            { content = [ styledIconContainer [ marginRight (rem 1) ] [ Icon.linkedIn ] ]
            , url = Constants.siteLinkedIn
            , css = socialMediaStyle
            }
        , Styled.newTabLink []
            { content = [ styledIconContainer [ marginRight (rem 1) ] [ Icon.github ] ]
            , url = Constants.githubLink
            , css = socialMediaStyle
            }
        , Styled.newTabLink []
            { content = [ styledIconContainer [ marginRight (rem 1) ] [ Icon.rss ] ]
            , url = Constants.rssFeed
            , css = socialMediaStyle
            }
        ]


languageLinks : Html msg
languageLinks =
    div [ css [ display none, Responsive.tabletUp [ displayFlex, justifyContent flexEnd, alignItems center, paddingBottom (rem 2), Css.property "grid-area" "language" ] ] ]
        [ span [ css [ fontWeight bold ] ] [ text "Featuring" ]
        , Styled.newTabLink []
            { url = "https://www.typescriptlang.org/"
            , content = [ styledIconContainer [ marginLeft (rem 1) ] [ Styled.image [] { description = "TypeScript", path = ImagePath.toString Pages.images.typescript } ] ]
            , css = []
            }
        , Styled.newTabLink []
            { url = "https://elm-lang.org/"
            , content = [ styledIconContainer [ marginLeft (rem 1) ] [ Styled.image [] { description = "Elm", path = ImagePath.toString Pages.images.elm } ] ]
            , css = []
            }
        ]


socialMediaStyle : List Style
socialMediaStyle =
    [ color colors.drifterCoal, hover [ color colors.freshDirt ] ]


styledIconContainer : List Style -> List (Html msg) -> Html msg
styledIconContainer styles =
    div [ css ([ Css.height (px 25), Css.width (px 25) ] ++ styles) ]


styledIndexHero : List (Html msg) -> Html msg
styledIndexHero =
    div
        [ css
            [ padding (rem 1)
            , Css.width (pct 100)
            , Css.maxWidth (px 1000)
            , marginTop (rem 5)
            , Css.height (vh 100)
            , Css.property "display" "grid"
            , Css.property "grid-template-columns" "1fr"
            , Css.property "grid-gap" "1rem"
            , Css.property "grid-template-areas" """
                                                 "image"
                                                 "content"
                                                 "language"
                                                 "some"
                                                 """
            , Responsive.tabletUp
                [ marginTop zero
                , Css.property "display" "grid"
                , Css.property "grid-template-columns" "50% 50%"
                , Css.property "grid-template-areas" """
                                                     "content   image"
                                                     "some      language"
                                                     """
                , Css.property "align-items" "center"
                , Css.property "grid-template-rows" "auto 2rem"
                ]
            ]
        ]
