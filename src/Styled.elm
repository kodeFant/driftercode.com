module Styled exposing (image, link)

import Html exposing (Attribute, Html, a, img)
import Html.Attributes exposing (alt, class, src)


image : List (Attribute msg) -> { path : String, description : String } -> Html msg
image attr { path, description } =
    img ([ src path, alt description, class "image" ] ++ attr) []


link : List (Attribute msg) -> List (Html msg) -> Html msg
link attr content =
    a (attr ++ [ class "link" ]) content
