module Component.Bio exposing (bio)

import Css exposing (..)
import Data.Author as Author
import Design.Icon
import Head.Metadata exposing (ArticleMetadata)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


bio : ArticleMetadata -> Html msg
bio metadata =
    styledBioContainer
        [ Author.view []
            metadata.author
        , styledInfoContainer
            [ styledNameAndSocialContainer
                [ styledAuthorName
                    [ text metadata.author.name ]
                , socialIcons metadata
                ]
            , div [] [ text metadata.author.bio ]
            ]
        ]


socialIcons : ArticleMetadata -> Html msg
socialIcons metadata =
    div [ css [ displayFlex, alignItems center ] ]
        [ a
            [ href ("https://twitter.com/" ++ metadata.author.twitter)
            , Html.Styled.Attributes.target "_blank"
            , rel "noreferrer noopener"
            , css
                [ Css.width (px 16)
                ]
            , twitterStyle
            ]
            [ Design.Icon.twitter ]
        , a
            [ href metadata.author.linkedinUrl
            , Html.Styled.Attributes.target "_blank"
            , rel "noreferrer noopener"
            , css
                [ Css.width (px 16)
                ]
            , linkedinStyle
            ]
            [ Design.Icon.linkedIn ]
        ]


twitterStyle : Attribute msg
twitterStyle =
    css
        [ marginRight (rem 0.5)
        , color (rgba 29 161 242 0.5)
        , hover [ color (rgba 29 161 242 0.9) ]
        ]


linkedinStyle : Attribute msg
linkedinStyle =
    css
        [ marginRight (rem 0.5)
        , color (rgba 29 161 242 0.5)
        , hover [ color (rgba 29 161 242 0.9) ]
        ]


styledBioContainer : List (Html msg) -> Html msg
styledBioContainer =
    div
        [ css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "auto 1fr"
            , Css.property "grid-gap" "1rem"
            , padding2 (rem 2) (rem 0)
            ]
        ]


styledInfoContainer : List (Html msg) -> Html msg
styledInfoContainer content =
    div
        [ css
            [ Css.property "display" "grid"
            , Css.property "grid-template-columns" "1fr"
            , Css.property "grid-gap" "0.1rem"
            , padding2 (px 0) (rem 1)
            ]
        ]
        content


styledNameAndSocialContainer : List (Html msg) -> Html msg
styledNameAndSocialContainer =
    div [ css [ displayFlex, alignItems center ] ]


styledAuthorName : List (Html msg) -> Html msg
styledAuthorName =
    span
        [ css
            [ fontWeight bold
            , fontSize (px 24)
            , marginRight (rem 1)
            ]
        ]
