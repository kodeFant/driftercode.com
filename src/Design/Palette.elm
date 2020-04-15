module Design.Palette exposing (blogHeading, colors, elmUIcolor, heading)

import Css exposing (Color, rgb)
import Element exposing (Element, rgb255)
import Element.Font as Font
import Element.Region


type alias ElmUIPaletteColors =
    { primary : Element.Color
    , secondary : Element.Color
    , lightGray : Element.Color
    , white : Element.Color
    , darkestGray : Element.Color
    , lighterGray : Element.Color
    , black : Element.Color
    , red : Element.Color
    , darkRed : Element.Color
    }


elmUIcolor : ElmUIPaletteColors
elmUIcolor =
    { primary = rgb255 255 165 0 -- rgb(255,165,0)
    , secondary = rgb255 235 145 0 -- rgb(235,145,0)
    , white = rgb255 255 255 255 -- rgb(255, 255, 255)
    , darkestGray = rgb255 51 51 51 --rgb(51,51,51)
    , lightGray = rgb255 200 200 200 --rgb(200,200,200)
    , lighterGray = rgb255 237 237 237 --rgb(237,237,237)
    , black = rgb255 30 30 30 --rgb(30,30,30)
    , red = rgb255 200 0 0
    , darkRed = rgb255 150 0 0
    }


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


heading : Int -> List (Element msg) -> Element msg
heading level content =
    Element.paragraph
        ([ Font.bold
         , Font.family [ Font.typeface "Raleway" ]
         , Element.Region.heading level
         ]
            ++ (case level of
                    1 ->
                        [ Font.size 36 ]

                    2 ->
                        [ Font.size 24 ]

                    _ ->
                        [ Font.size 20 ]
               )
        )
        content


blogHeading : String -> Element msg
blogHeading title =
    Element.paragraph
        [ Font.bold
        , Font.family
            [ Font.typeface "Merriweather"
            , Font.serif
            ]
        , Element.Region.heading 1
        , Font.size 42
        , Font.center
        , Element.spacing 10
        , Element.paddingXY 0 10
        ]
        [ Element.text title ]
