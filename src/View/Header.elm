module View.Header exposing (view)

import Element exposing (Element, fill, height, paddingXY, rgba255, spaceEvenly, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Pages
import Pages.PagePath exposing (PagePath)
import Palette
import Types exposing (Msg)
import View.Nav exposing (logo, navMenu)


view : PagePath Pages.PathKey -> Element Msg
view currentPath =
    Element.column [ width fill ]
        [ Element.row
            [ paddingXY 25 4
            , spaceEvenly
            , width fill
            , Region.navigation
            , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Border.color (rgba255 40 80 40 0.4)
            , Background.color Palette.color.darkestGray
            , Font.color Palette.color.white
            , Element.paddingXY 48 16
            ]
            [ Element.link
                [ Font.color Palette.color.primary
                , Element.mouseOver [ Font.color Palette.color.white ]
                ]
                { url = "/"
                , label =
                    Element.row [ Font.size 30, Element.spacing 16 ]
                        [ logo
                        ]
                }
            , navMenu currentPath
            ]
        , Element.el
            [ Element.height (Element.px 4)
            , Element.width Element.fill
            , Background.gradient
                { angle = 0.2
                , steps =
                    [ Palette.color.darkestGray
                    , Palette.color.primary
                    ]
                }
            ]
            Element.none
        ]
