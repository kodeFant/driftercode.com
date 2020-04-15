module Layout.Header exposing (view)

import Css exposing (..)
import Css.Animations exposing (..)
import Design.Palette exposing (colors)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Pages
import Pages.PagePath exposing (PagePath)
import Styled


view : PagePath Pages.PathKey -> Html msg
view _ =
    div
        [ css
            [ displayFlex
            , justifyContent center
            , Css.width (pct 100)
            , Css.backgroundColor colors.darkestGray
            , padding2 (rem 0.5) (rem 1)
            ]
        ]
        [ a
            [ href "/"
            , css [ Css.width (px 170) ]
            ]
            [ logo ]
        ]


logo : Html msg
logo =
    Styled.image
        [ css
            [ hover
                [ animationName logoKeyFrames
                , animationDuration (ms 200)
                , Css.property "animation-timing-function" "linear"
                , Css.property "animation-fill-mode" "forwards"
                ]
            ]
        ]
        { path = "/images/logo.png", description = "" }


logoKeyFrames : Keyframes {}
logoKeyFrames =
    keyframes
        [ ( 0
          , [ Css.Animations.property "filter" "brightness(1)"
            , Css.Animations.property "filter" "saturate(1)"
            ]
          )
        , ( 100
          , [ Css.Animations.property "filter" "brightness(5)"
            , Css.Animations.property "filter" "saturate(0)"
            ]
          )
        ]
