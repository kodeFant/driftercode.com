module DefaultHtmlRenderer exposing (defaultHtmlRenderer)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Markdown.Block as Block exposing (HeadingLevel(..), ListItem(..), Task(..))
import Markdown.Html
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Styled


defaultHtmlRenderer : Renderer (Html msg)
defaultHtmlRenderer =
    { heading =
        \{ level, children } ->
            case level of
                Block.H1 ->
                    Styled.heading1 [] children

                Block.H2 ->
                    Styled.heading2 [] children

                Block.H3 ->
                    Styled.heading3 [] children

                Block.H4 ->
                    Styled.heading4 [] children

                Block.H5 ->
                    Styled.heading5 [] children

                Block.H6 ->
                    Styled.heading6 [] children
    , paragraph = Styled.paragraph []
    , hardLineBreak = br [] []
    , blockQuote = blockquote []
    , strong =
        \children -> strong [] children
    , emphasis =
        \children -> em [] children
    , codeSpan =
        \content -> code [] [ text content ]
    , link =
        \link content ->
            case link.title of
                Just titleText ->
                    a
                        [ href link.destination
                        , title titleText
                        ]
                        content

                Nothing ->
                    a [ href link.destination ] content
    , image =
        \imageInfo ->
            case imageInfo.title of
                Just titleText ->
                    img
                        [ src imageInfo.src
                        , alt imageInfo.alt
                        , title titleText
                        ]
                        []

                Nothing ->
                    img
                        [ src imageInfo.src
                        , alt imageInfo.alt
                        ]
                        []
    , text =
        text
    , unorderedList =
        \items ->
            ul []
                (items
                    |> List.map
                        (\item ->
                            case item of
                                Block.ListItem task children ->
                                    let
                                        checkbox =
                                            case task of
                                                Block.NoTask ->
                                                    text ""

                                                Block.IncompleteTask ->
                                                    input
                                                        [ disabled True
                                                        , checked False
                                                        , type_ "checkbox"
                                                        ]
                                                        []

                                                Block.CompletedTask ->
                                                    input
                                                        [ disabled True
                                                        , checked True
                                                        , type_ "checkbox"
                                                        ]
                                                        []
                                    in
                                    li [] (checkbox :: children)
                        )
                )
    , orderedList =
        \startingIndex items ->
            ol
                (case startingIndex of
                    1 ->
                        [ start startingIndex ]

                    _ ->
                        []
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            li []
                                itemBlocks
                        )
                )
    , html = Markdown.Html.oneOf []
    , codeBlock =
        \{ body, language } ->
            pre []
                [ code []
                    [ text body
                    ]
                ]
    , thematicBreak = hr [] []
    , table = table []
    , tableHeader = thead []
    , tableBody = tbody []
    , tableRow = tr []
    , tableHeaderCell =
        \maybeAlignment ->
            let
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            th attrs
    , tableCell = td []
    }
