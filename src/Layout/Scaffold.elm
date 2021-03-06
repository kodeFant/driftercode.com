module Layout.Scaffold exposing (view)

import Css exposing (..)
import Design.Palette exposing (colors)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Footer
import Layout.Header
import Pages
import Pages.PagePath exposing (PagePath)


view : PagePath Pages.PathKey -> Html msg -> Bool -> Html msg
view page content footerVisible =
    div [ css [ Css.width (pct 100), backgroundColor colors.white, minHeight (vh 100) ] ]
        ([ Layout.Header.view page
         , content
         ]
            ++ (if footerVisible == True then
                    [ Layout.Footer.view ]

                else
                    []
               )
        )
