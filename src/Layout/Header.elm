module Layout.Header exposing (view)

import Design.Palette as Palette
import Element exposing (Element, centerX, fill, paddingXY, px, rgba255, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes
import Pages
import Pages.PagePath exposing (PagePath)
import Types exposing (Msg)


view : PagePath Pages.PathKey -> Element msg
view _ =
    Element.column [ width fill ]
        [ Element.row
            [ paddingXY 25 4
            , width fill
            , Border.color (rgba255 40 80 40 0.4)
            , Background.color Palette.color.darkestGray
            , Element.paddingXY 48 16
            ]
            [ Element.link
                [ Font.color Palette.color.primary
                , Element.mouseOver [ Font.color Palette.color.white ]
                , centerX
                ]
                { url = "/"
                , label =
                    Element.row [ Font.size 30, Element.spacing 16 ]
                        [ logo
                        ]
                }
            ]
        ]


logo : Element msg
logo =
    Element.image [ Element.htmlAttribute (Html.Attributes.class "logo"), width (px 180) ] { src = "/images/logo.png", description = "" }
