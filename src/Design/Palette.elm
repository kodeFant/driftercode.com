module Design.Palette exposing (colors)

import Css exposing (Color, rgb)


type alias PaletteColors =
    { primary : Color
    , secondary : Color
    , lightGray : Color
    , white : Color
    , darkestGray : Color
    , lighterGray : Color
    , black : Color
    , red : Color
    , darkRed : Color
    }


colors : PaletteColors
colors =
    { primary = rgb 255 165 0 -- rgb(255,165,0)
    , secondary = rgb 235 145 0 -- rgb(235,145,0)
    , white = rgb 255 255 255 -- rgb(255, 255, 255)
    , darkestGray = rgb 51 51 51 --rgb(51,51,51)
    , lightGray = rgb 200 200 200 --rgb(200,200,200)
    , lighterGray = rgb 237 237 237 --rgb(237,237,237)
    , black = rgb 30 30 30 --rgb(30,30,30)
    , red = rgb 200 0 0
    , darkRed = rgb 150 0 0
    }
