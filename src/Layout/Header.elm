module Layout.Header exposing (view)

import Constants
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
