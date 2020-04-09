module Design.Icon exposing (linkedIn, twitter)

import Element exposing (Attribute, Element, el, html)
import FontAwesome.Brands as FaBrands
import FontAwesome.Icon as Icon


twitter : List (Attribute msg) -> Element msg
twitter attr =
    el attr
        (html
            (Icon.viewStyled
                []
                FaBrands.twitter
            )
        )


linkedIn : List (Attribute msg) -> Element msg
linkedIn attr =
    el attr
        (html
            (Icon.viewStyled
                []
                FaBrands.linkedin
            )
        )
