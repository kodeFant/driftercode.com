module View.SiteIndex exposing (view)

import Constants
import Css exposing (..)
import Design.Icon as Icon
import Design.Palette exposing (colors)
import Design.Responsive as Responsive
import Head.Metadata exposing (Index, Metadata(..))
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
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
            [ css
                [ displayFlex
                , flexDirection column
                , alignItems center
                , Css.width (pct 100)
                , maxHeight (vh 100)
                ]
            ]
            [ styledIndexGrid
                [ styledHeroContent
                    [ styledTitle [ text indexMeta.title ]
                    , styledSubTitle [ text indexMeta.subHeading ]
                    , styledContent
                        [ p [] [ text "A budding functional programmer who used to be a journalist." ]
                        , p [] [ text "I’m learning functional programming by blogging about it." ]
                        , p [] [ text "Mathy algebraic slang to be kept at a minimum." ]
                        ]
                    , styledButtonLinkContainer
                        [ Styled.buttonLink
                            [ href indexMeta.buttonLink ]
                            [ text indexMeta.buttonText ]
                        ]
                    ]
                , styledHeroImage
                    { path = ImagePath.toString Pages.images.driftercode, description = "" }
                , socialMediaLinksContainer
                , languageLinksContainer
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


styledHeroImage : { path : String, description : String } -> Html msg
styledHeroImage =
    Styled.image
        [ css
            [ Css.width auto
            , Css.maxWidth (pct 100)
            , float right
            , Css.property "grid-area" "image"
            , Responsive.tabletUp [ Css.maxHeight (pct 90) ]
            , alignSelf center
            ]
        ]


styledSubTitle : List (Html msg) -> Html msg
styledSubTitle =
    div [ css [ fontSize (px 22), textAlign center, Responsive.tabletUp [ textAlign left ] ] ]


styledContent : List (Html msg) -> Html msg
styledContent =
    div
        [ css
            [ display none
            , Responsive.tabletUp
                [ padding2 (rem 2.5) zero
                , fontSize (px 18)
                , display block
                ]
            ]
        ]


styledButtonLinkContainer : List (Html msg) -> Html msg
styledButtonLinkContainer =
    div [ css [ displayFlex, justifyContent center, marginTop (rem 2), Responsive.tabletUp [ justifyContent flexStart ] ] ]


type alias SocialMediaLink msg =
    { url : String
    , icon : Html msg
    }


socialMediaLinksData : List (SocialMediaLink msg)
socialMediaLinksData =
    [ { url = "https://twitter.com/" ++ Constants.siteTwitter, icon = Icon.twitter }
    , { url = Constants.siteLinkedIn, icon = Icon.linkedIn }
    , { url = Constants.githubLink, icon = Icon.github }
    , { url = Constants.rssFeed, icon = Icon.rss }
    ]


socialMediaLinkElement : SocialMediaLink msg -> Html msg
socialMediaLinkElement link =
    Styled.link
        [ Attr.target "_blank"
        , rel "noreferrer noopener me"
        ]
        { content = [ styledIconContainer [ marginRight (rem 1) ] [ link.icon ] ]
        , url = link.url
        , css = socialMediaStyle
        }


socialMediaLinks : List (SocialMediaLink msg) -> List (Html msg)
socialMediaLinks links =
    links
        |> List.map socialMediaLinkElement


socialMediaLinksContainer : Html msg
socialMediaLinksContainer =
    div [ css [ displayFlex, paddingBottom (rem 2), Css.property "grid-area" "some", justifyContent center, Responsive.tabletUp [ justifyContent flexStart ] ] ]
        (socialMediaLinks socialMediaLinksData)


type alias SupportedLanguage =
    { name : String
    , icon : String
    , link : String
    }


supportedLanguages : List SupportedLanguage
supportedLanguages =
    [ { name = "Elm"
      , icon = ImagePath.toString Pages.images.elm
      , link = "https://elm-lang.org/"
      }
    , { name = "TypeScript"
      , icon = ImagePath.toString Pages.images.typescript
      , link = "https://www.typescriptlang.org/"
      }
    ]


languageLinks : List SupportedLanguage -> List (Html msg)
languageLinks languages =
    languages
        |> List.map
            (\language ->
                Styled.newTabLink []
                    { url = language.link
                    , content =
                        [ styledIconContainer [ marginLeft (rem 1) ]
                            [ Styled.image []
                                { description = language.name
                                , path = language.icon
                                }
                            ]
                        ]
                    , css = []
                    }
            )


languageLinksContainer : Html msg
languageLinksContainer =
    div [ css [ display none, Responsive.tabletUp [ displayFlex, justifyContent flexEnd, alignItems center, paddingBottom (rem 2), Css.property "grid-area" "language" ] ] ]
        (span [ css [ fontWeight bold ] ] [ text "Featuring" ]
            :: languageLinks supportedLanguages
        )


socialMediaStyle : List Style
socialMediaStyle =
    [ color colors.drifterCoal, hover [ color colors.freshDirt ] ]


styledIconContainer : List Style -> List (Html msg) -> Html msg
styledIconContainer styles =
    div [ css ([ Css.height (px 25), Css.width (px 25) ] ++ styles) ]


styledIndexGrid : List (Html msg) -> Html msg
styledIndexGrid =
    div
        [ css
            [ padding (rem 1)
            , Css.width (pct 100)
            , Css.maxWidth (px 1000)
            , paddingTop (rem 5)
            , Css.height (pct 100)
            , Css.property "display" "grid"
            , Css.property "grid-template-columns" "1fr"
            , Css.property "grid-gap" "1rem"
            , Css.property "grid-template-areas" """
                                                 "image"
                                                 "content"
                                                 "language"
                                                 "some"
                                                 """
            , Css.property "grid-template-rows" "auto 2rem 1rem 1 rem"
            , Responsive.tabletUp
                [ marginTop zero
                , Css.height (vh 100)
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
