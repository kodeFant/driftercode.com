module Layout.Scaffold exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Layout.Footer
import Layout.Header
import Pages
import Pages.PagePath exposing (PagePath)


view : PagePath Pages.PathKey -> Html msg -> Html msg
view page content =
    div [ css [ Css.width (pct 100) ] ]
        [ Layout.Header.view page
        , content
        , Layout.Footer.view
        ]
