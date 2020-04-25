module Design.Palette exposing (colors)

import Css exposing (Color, rgb)


type alias PaletteColors =
    { primary : Color
    , secondary : Color
    , lightGray : Color
    , white : Color
    , trueWhite : Color
    , darkestGray : Color
    , lighterGray : Color
    , black : Color
    , red : Color
    , darkRed : Color
    , danger : Color
    , danger2 : Color
    , green : Color
    , green2 : Color
    , error : Color
    , drifterCoal : Color
    , offWhite : Color
    , freshDirt : Color
    }


colors : PaletteColors
colors =
    { primary = rgb 255 165 0 -- rgb(255,165,0)
    , secondary = rgb 235 145 0 -- rgb(235,145,0)
    , offWhite = Css.hex "#E5E5E5"
    , white = Css.hex "#EFEFEF"
    , trueWhite = Css.hex "#FFFFFF"
    , darkestGray = rgb 51 51 51 --rgb(51,51,51)
    , lightGray = rgb 200 200 200 --rgb(200,200,200)
    , lighterGray = rgb 237 237 237 --rgb(237,237,237)
    , black = rgb 30 30 30 --rgb(30,30,30)
    , red = rgb 200 0 0 --rgb(200,0,0)
    , darkRed = rgb 150 0 0 --rgb(150,0,0)
    , danger = Css.hex "#FFF59D" -- rbg(1,1,1)
    , danger2 = Css.hex "#FFEB3B" -- rbg(1,1,1)
    , green = Css.hex "#C8E6C9"
    , green2 = Css.hex "#4CAF50"
    , error = Css.hex "#ffebee"
    , drifterCoal = Css.hex "#373435"
    , freshDirt = Css.hex "#745112"
    }
