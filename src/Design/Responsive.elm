module Design.Responsive exposing (desktopUp, mobileOnly, responsiveFillScreen, responsiveView, tabletUp)

import Css exposing (Style, px)
import Css.Media exposing (..)
import Element exposing (Attribute, Element, column, el, fill, height, width)
import Html.Attributes as Attr
import Html.Styled.Attributes exposing (..)


class : String -> Attribute msg
class className =
    Element.htmlAttribute <| Attr.class className


type alias ResponsiveView msg =
    { phone : Element msg
    , medium : Element msg
    , large : Element msg
    }


responsiveView : List (Attribute msg) -> ResponsiveView msg -> Element msg
responsiveView args { phone, medium, large } =
    column args
        [ el (args ++ [ class "responsive-mobile" ]) phone
        , el (args ++ [ class "responsive-medium" ]) medium
        , el (args ++ [ class "responsive-large" ]) large
        ]


responsiveFillScreen : Element msg -> Element msg
responsiveFillScreen element =
    el [ class "responsive-mobile", Element.width Element.fill, Element.height fill ] element


mobileOnly : List Style -> Style
mobileOnly styles =
    withMedia [ only screen [ maxWidth (px 599) ] ] styles


tabletUp : List Style -> Style
tabletUp styles =
    withMedia [ only screen [ minWidth (px 600) ] ] styles


desktopUp : List Style -> Style
desktopUp styles =
    withMedia [ only screen [ minWidth (px 1200) ] ] styles
