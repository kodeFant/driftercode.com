module Design.Icon exposing (linkedIn, twitter)

import Css exposing (..)
import Element exposing (Attribute, Element, el, html)
import FontAwesome.Brands as FaBrands
import FontAwesome.Icon as Icon
import Html.Attributes exposing (style)
import Html.Styled exposing (Html, fromUnstyled)


twitter : Html msg
twitter =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaBrands.twitter
        )


linkedIn : Html msg
linkedIn =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaBrands.linkedin
        )
