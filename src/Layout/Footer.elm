module Layout.Footer exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)


view : Html msg
view =
    footer [ class "footer" ]
        [ div [ class "copyright" ]
            [ text "All Rights Reserved 2020 © Lars Lillo Ulvestad" ]
        , div [ class "privacy" ]
            [ text "I use analytics cookies to track anonymized traffic to DriferCode.com." ]
        ]
