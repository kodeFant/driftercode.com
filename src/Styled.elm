module Styled exposing
    ( button
    , dangerButton
    , emailInput
    , heading1
    , heading2
    , heading3
    , heading4
    , heading5
    , heading6
    , image
    , link
    , mainContainer
    , newTabLink
    , paragraph
    , primaryButton
    , textAreaInput
    , textInput
    )

import Css exposing (..)
import Css.Transitions exposing (backgroundColor3, easeInOut, transition)
import Design.Palette exposing (colors)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)


image : List (Attribute msg) -> { path : String, description : String } -> Html msg
image attr { path, description } =
    img
        ([ src path
         , alt description
         , css [ Css.width (pct 100) ]
         ]
            ++ attr
        )
        []


link : List (Attribute msg) -> List (Html msg) -> Html msg
link attr content =
    a
        (attr
            ++ [ css
                    [ color (rgb 255 165 0)
                    , textDecoration none
                    , transition [ backgroundColor3 500 0 easeInOut ]
                    , hover
                        [ backgroundColor (rgba 0 0 0 0.829)
                        , color (rgb 255 165 0)
                        ]
                    ]
               ]
        )
        content


newTabLink : List (Attribute msg) -> List (Html msg) -> Html msg
newTabLink attr content =
    link (attr ++ [ Attr.target "_blank", rel "noreferrer noopener" ]) content


mainContainer : List (Html msg) -> Html msg
mainContainer content =
    main_
        [ css
            [ Css.width (pct 100)
            , displayFlex
            , justifyContent center
            ]
        ]
        content


heading1 : List (Attribute msg) -> List (Html msg) -> Html msg
heading1 attr content =
    h1 (attr ++ [ css [ fontSize (px 42), fontFamilies [ "Merriweather" ] ] ]) content


heading2 : List (Attribute msg) -> List (Html msg) -> Html msg
heading2 attr content =
    h2 (attr ++ [ css [ fontSize (px 36), fontFamilies [ "Merriweather" ] ] ]) content


heading3 : List (Attribute msg) -> List (Html msg) -> Html msg
heading3 attr content =
    h3 (attr ++ [ css [ fontSize (px 32), fontFamilies [ "Merriweather" ] ] ]) content


heading4 : List (Attribute msg) -> List (Html msg) -> Html msg
heading4 attr content =
    h4 (attr ++ [ css [ fontSize (px 28), fontFamilies [ "Merriweather" ] ] ]) content


heading5 : List (Attribute msg) -> List (Html msg) -> Html msg
heading5 attr content =
    h5 (attr ++ [ css [ fontSize (px 24), fontFamilies [ "Merriweather" ] ] ]) content


heading6 : List (Attribute msg) -> List (Html msg) -> Html msg
heading6 attr content =
    h6 (attr ++ [ css [ fontSize (px 20), fontFamilies [ "Merriweather" ] ] ]) content


paragraph : List (Attribute msg) -> List (Html msg) -> Html msg
paragraph attr content =
    p (attr ++ [ css [ fontSize (rem 1.1), lineHeight (rem 2) ] ]) content


{-| Autocomplete Values:
<https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete#Values>
-}
genericInput :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , label : String
        , autoComplete : Maybe String
        , fieldType : Maybe String
        }
    -> Html msg
genericInput attr { onChange, label, autoComplete, fieldType } =
    div
        []
        [ Html.label []
            [ text label
            , input
                (attr
                    ++ [ css
                            [ displayFlex
                            , flexDirection column
                            , Css.width (pct 100)
                            , padding (rem 0.3)
                            , fontSize (rem 1.2)
                            , margin2 (rem 1) zero
                            ]
                       , onInput onChange
                       , case fieldType of
                            Just string ->
                                type_ string

                            Nothing ->
                                type_ "text"
                       , case autoComplete of
                            Just string ->
                                attribute "autocomplete" string

                            Nothing ->
                                autocomplete False
                       ]
                )
                []
            ]
        ]


emailInput :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , label : String
        , autoComplete : Bool
        }
    -> Html msg
emailInput attr { onChange, label, autoComplete } =
    genericInput (attr ++ [])
        { autoComplete =
            if autoComplete == True then
                Just "email"

            else
                Nothing
        , label = label
        , onChange = onChange
        , fieldType = Just "email"
        }


textInput :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , label : String
        , autoComplete : Maybe String
        }
    -> Html msg
textInput attr { onChange, label, autoComplete } =
    genericInput (attr ++ [])
        { autoComplete = autoComplete
        , label = label
        , onChange = onChange
        , fieldType = Just "text"
        }


textAreaInput :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , label : String
        }
    -> Html msg
textAreaInput attr { onChange, label } =
    div
        []
        [ Html.label [ onInput onChange ]
            [ text label
            , textarea
                (attr
                    ++ [ css
                            [ displayFlex
                            , flexDirection column
                            , Css.width (pct 100)
                            , padding (rem 0.3)
                            , fontSize (rem 1.2)
                            , margin2 (rem 1) zero
                            ]
                       ]
                )
                []
            ]
        ]


{-| Autocomplete Values:
<https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button>
-}
button :
    List (Attribute msg)
    ->
        { onPress : msg
        , label : Html msg
        , buttonType : String
        }
    -> Html msg
button attr { onPress, buttonType, label } =
    Html.button
        ([ onClick onPress
         , type_ buttonType
         , css
            [ fontSize (rem 1)
            , padding (rem 0.5)
            , border zero
            , borderRadius (px 5)
            , margin4 (rem 0.5) (rem 0.5) (rem 0.5) zero
            ]
         ]
            ++ attr
        )
        [ label ]


dangerButton :
    List (Attribute msg)
    ->
        { onPress : msg
        , label : Html msg
        , buttonType : String
        }
    -> Html msg
dangerButton attr { onPress, buttonType, label } =
    button
        (attr
            ++ [ css
                    [ backgroundColor colors.error
                    , color colors.black
                    ]
               ]
        )
        { onPress = onPress
        , buttonType = buttonType
        , label = label
        }


primaryButton :
    List (Attribute msg)
    ->
        { onPress : msg
        , label : Html msg
        , buttonType : String
        }
    -> Html msg
primaryButton attr { onPress, buttonType, label } =
    button
        (attr
            ++ [ css
                    [ backgroundColor colors.secondary
                    , color colors.white
                    , hover
                        [ backgroundColor colors.primary
                        ]
                    ]
               ]
        )
        { onPress = onPress
        , buttonType = buttonType
        , label = label
        }
