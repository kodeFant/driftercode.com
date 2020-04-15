module Styled exposing
    ( heading1
    , heading2
    , heading3
    , heading4
    , heading5
    , heading6
    , image
    , link
    , mainContainer
    , newTabLink
    , paragraph
    )

import Css exposing (..)
import Css.Transitions exposing (backgroundColor3, easeInOut, transition)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, css, rel, src, target)


image : List (Attribute msg) -> { path : String, description : String } -> Html msg
image attr { path, description } =
    img
        ([ src path
         , alt description
         , css [ width (pct 100) ]
         ]
            ++ attr
        )
        []


link : List (Attribute msg) -> List (Html msg) -> Html msg
link attr content =
    a
        (attr
            ++ [ css
                    [ color (rgb 255 165 0)
                    , textDecoration none
                    , transition [ backgroundColor3 500 0 easeInOut ]
                    , hover
                        [ backgroundColor (rgba 0 0 0 0.829)
                        , color (rgb 255 165 0)
                        ]
                    ]
               ]
        )
        content


newTabLink : List (Attribute msg) -> List (Html msg) -> Html msg
newTabLink attr content =
    link (attr ++ [ Html.Styled.Attributes.target "_blank", rel "noreferrer noopener" ]) content


mainContainer : List (Html msg) -> Html msg
mainContainer content =
    main_
        [ css
            [ Css.width (pct 100)
            , displayFlex
            , justifyContent center
            ]
        ]
        content


heading1 : List (Attribute msg) -> List (Html msg) -> Html msg
heading1 attr content =
    h1 (attr ++ [ css [ fontSize (px 42), fontFamilies [ "Merriweather" ] ] ]) content


heading2 : List (Attribute msg) -> List (Html msg) -> Html msg
heading2 attr content =
    h2 (attr ++ [ css [ fontSize (px 36), fontFamilies [ "Merriweather" ] ] ]) content


heading3 : List (Attribute msg) -> List (Html msg) -> Html msg
heading3 attr content =
    h3 (attr ++ [ css [ fontSize (px 32), fontFamilies [ "Merriweather" ] ] ]) content


heading4 : List (Attribute msg) -> List (Html msg) -> Html msg
heading4 attr content =
    h4 (attr ++ [ css [ fontSize (px 28), fontFamilies [ "Merriweather" ] ] ]) content


heading5 : List (Attribute msg) -> List (Html msg) -> Html msg
heading5 attr content =
    h5 (attr ++ [ css [ fontSize (px 24), fontFamilies [ "Merriweather" ] ] ]) content


heading6 : List (Attribute msg) -> List (Html msg) -> Html msg
heading6 attr content =
    h6 (attr ++ [ css [ fontSize (px 20), fontFamilies [ "Merriweather" ] ] ]) content


paragraph : List (Attribute msg) -> List (Html msg) -> Html msg
paragraph attr content =
    p (attr ++ [ css [ fontSize (rem 1.1), lineHeight (rem 2) ] ]) content
