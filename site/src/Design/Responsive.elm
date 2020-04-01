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


responsiveView : List (Attribute msg) -> ResponsiveView msg -> Element msg
responsiveView args { mobile, medium, large } =
    column args
        [ el (args ++ [ class "responsive-mobile" ]) mobile
        , el (args ++ [ class "responsive-medium" ]) medium
        , el (args ++ [ class "responsive-large" ]) large
        ]


responsiveFillScreen : Element msg -> Element msg
responsiveFillScreen element =
    el [ class "responsive-mobile", width fill, height fill ] element
