module View.Page exposing (view)

import Head.Metadata exposing (Metadata)
import Html.Styled exposing (..)
import Pages
import Pages.PagePath exposing (PagePath)
import Types exposing (Msg)


view :
    String
    -> List (Html msg)
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Html msg
view title viewForPage page =
    div [] [ h2 [] [ text title ] ]
