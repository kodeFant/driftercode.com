module Design.Icon exposing (github, linkedIn, rss, twitter)

import Css exposing (..)
import FontAwesome.Brands as FaBrands
import FontAwesome.Icon as Icon
import FontAwesome.Solid as FaSolid
import Html.Attributes exposing (style)
import Html.Styled exposing (Html, fromUnstyled)


rss : Html msg
rss =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaSolid.rss
        )


twitter : Html msg
twitter =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaBrands.twitter
        )


github : Html msg
github =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaBrands.github
        )


linkedIn : Html msg
linkedIn =
    fromUnstyled
        (Icon.viewStyled
            [ style "width" "100%" ]
            FaBrands.linkedinIn
        )
