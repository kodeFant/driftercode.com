module Design.Styles exposing (linkStyle)

import Design.Palette as Palette
import Element exposing (Attribute, mouseOver)
import Element.Font as Font


linkStyle : List (Attribute msg)
linkStyle =
    [ Font.color Palette.color.secondary, mouseOver [ Font.color Palette.color.primary ] ]
