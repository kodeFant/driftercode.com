module Layout.Header exposing (view)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Pages
import Pages.PagePath exposing (PagePath)
import Styled
import Types exposing (Msg)



-- view : PagePath Pages.PathKey -> Element msg
-- view _ =
--     Element.column [ width fill ]
--         [ Element.row
--             [ paddingXY 25 4
--             , width fill
--             , Border.color (rgba255 40 80 40 0.4)
--             , Background.color Palette.color.darkestGray
--             , Element.paddingXY 48 16
--             ]
--             [ Element.link
--                 [ Font.color Palette.color.primary
--                 , Element.mouseOver [ Font.color Palette.color.white ]
--                 , centerX
--                 ]
--                 { url = "/"
--                 , label =
--                     Element.row [ Font.size 30, Element.spacing 16 ]
--                         [ logo
--                         ]
--                 }
--             ]
--         ]


view : PagePath Pages.PathKey -> Html msg
view _ =
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "width" "100%"
        , style "background-color" "var(--darkest-gray)"
        , style "padding" "0.5rem 1rem"
        ]
        [ a [ href "/", style "width" "170px" ] [ logo ]
        ]


logo : Html msg
logo =
    Styled.image [ class "logo" ] { path = "/images/logo.png", description = "" }
