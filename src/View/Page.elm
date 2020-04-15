module View.Page exposing (view)

import Head.Metadata exposing (Metadata)
import Html.Styled exposing (Html, div, h2, text)
import Pages
import Pages.PagePath exposing (PagePath)


view :
    String
    -> List (Html msg)
    -> { path : PagePath Pages.PathKey, frontmatter : Metadata }
    -> Html msg
view title viewForPage _ =
    div [] (List.concat [ [ h2 [] [ text title ] ], viewForPage ])
