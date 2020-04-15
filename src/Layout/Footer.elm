module Layout.Footer exposing (view)

import Css exposing (..)
import Design.Palette exposing (colors)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


view : Html msg
view =
    styledFooter
        [ copyright
            [ text "All Rights Reserved 2020 © Lars Lillo Ulvestad" ]
        , privacy
            [ text "I use analytics cookies to track anonymized traffic to DrifterCode.com." ]
        ]


styledFooter : List (Html msg) -> Html msg
styledFooter content =
    footer
        [ css
            [ backgroundColor colors.darkestGray
            , color colors.lighterGray
            , textAlign center
            , Css.width (pct 100)
            , padding2 (rem 3) zero
            , marginTop (rem 5)
            , fontSize (rem 1)
            ]
        ]
        content


copyright : List (Html msg) -> Html msg
copyright content =
    div [ css [ fontWeight bold, marginBottom (rem 1) ] ] content


privacy : List (Html msg) -> Html msg
privacy content =
    div [] content
