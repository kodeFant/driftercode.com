module Design.Responsive exposing (desktopUp, mobileOnly, tabletUp)

import Css exposing (Style, px)
import Css.Media exposing (..)
import Html.Styled.Attributes exposing (..)


mobileOnly : List Style -> Style
mobileOnly styles =
    withMedia [ only screen [ maxWidth (px 599) ] ] styles


tabletUp : List Style -> Style
tabletUp styles =
    withMedia [ only screen [ minWidth (px 600) ] ] styles


desktopUp : List Style -> Style
desktopUp styles =
    withMedia [ only screen [ minWidth (px 1200) ] ] styles
