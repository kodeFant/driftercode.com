module Layout.Header exposing (view)

import Constants
import Css exposing (..)
import Css.Animations exposing (..)
import Design.Palette exposing (colors)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Pages
import Pages.PagePath exposing (PagePath)


view : PagePath Pages.PathKey -> Html msg
view _ =
    div
        [ css
            [ displayFlex
            , justifyContent center
            , Css.backgroundColor colors.drifterCoal
            , position fixed
            , Css.width (pct 100)
            ]
        ]
        [ div
            [ css
                [ displayFlex
                , justifyContent spaceBetween
                , alignItems center
                , Css.width (pct 100)
                , Css.maxWidth Constants.maxWidthLarge
                , padding2 (rem 0.5) (rem 1)
                ]
            ]
            [ a
                [ href "/"
                , css
                    [ color colors.white
                    , textDecoration none
                    , fontFamilies [ "Rye" ]
                    , fontSize (px 32)
                    ]
                ]
                [ text "DrifterCode" ]
            , nav []
                [ a
                    [ href "/blog"
                    , css
                        [ color colors.white
                        , fontWeight bold
                        , fontSize (px 20)
                        , textDecoration none
                        ]
                    ]
                    [ text "Blog" ]
                ]
            ]
        ]
