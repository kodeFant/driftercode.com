module Design.Responsive exposing (responsiveFillScreen, responsiveView)

import Element exposing (Attribute, Element, column, el, fill, height, width)
import Html.Attributes as Attr


class : String -> Attribute msg
class className =
    Element.htmlAttribute <| Attr.class className


type alias ResponsiveView msg =
    { mobile : Element msg
    , medium : Element msg
    , large : Element msg
    }


responsiveView : ResponsiveView msg -> Element msg
responsiveView { mobile, medium, large } =
    column []
        [ el [ class "responsive-mobile" ] mobile
        , el [ class "responsive-medium" ] medium
        , el [ class "responsive-large" ] large
        ]


responsiveFillScreen : Element msg -> Element msg
responsiveFillScreen element =
    el [ class "responsive-mobile", width fill, height fill ] element
