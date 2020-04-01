module View.Page exposing (view)

import Element exposing (Element, centerX, column, el, fill, padding, spacing, text, textColumn, width)
import Element.Font as Font
import Element.Region
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath exposing (PagePath)
import Types exposing (Msg)
import View.Header


view :
    String
    -> List (Element Msg)
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Element Msg
view title viewForPage page =
    textColumn [ Element.width Element.fill ]
        [ View.Header.view page.path
        , el [ width fill ]
            (column
                [ Element.padding 30
                , Element.spacing 40
                , Element.Region.mainContent
                , Element.width (Element.fill |> Element.maximum 700)
                , Element.centerX
                ]
                (el [ Font.size 48, centerX ] (text title) :: viewForPage)
            )
        ]
