module Renderer.Markdown exposing (mainRenderer)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Encode as Encode
import Markdown.Block as Block exposing (HeadingLevel(..), ListItem(..), Task(..))
import Markdown.Html
import Markdown.Renderer exposing (Renderer)
import Pages
import Styled


mainRenderer : Renderer (Html msg)
mainRenderer =
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
    , link = link
    , image = image
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
    , html = html
    , codeBlock = codeBlock
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


link : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
link { destination } body =
    case List.head body of
        Just bodyElement ->
            case Pages.isValidRoute destination of
                Ok _ ->
                    if String.startsWith "http" destination then
                        Styled.link
                            [ href destination
                            , target "_blank"
                            ]
                            [ bodyElement
                            ]

                    else
                        Styled.link [ href destination ]
                            [ bodyElement
                            ]

                Err string ->
                    text string

        Nothing ->
            text ""


image : { src : String, alt : String, title : Maybe String } -> Html msg
image { src, alt } =
    Styled.image [] { description = alt, path = src }


codeBlock : { body : String, language : Maybe String } -> Html msg
codeBlock details =
    case details.language of
        Just lang ->
            node "code-editor"
                [ editorValue details.body
                , style "white-space" "normal"
                , attribute "language" lang
                ]
                []

        Nothing ->
            node "code-editor"
                [ editorValue details.body
                , style "white-space" "normal"
                ]
                []


editorValue : String -> Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorValue"


html : Markdown.Html.Renderer (List (Html msg) -> Html msg)
html =
    Markdown.Html.oneOf
        [ Markdown.Html.tag "youtube"
            (\id _ ->
                iframe
                    [ src ("https://www.youtube.com/embed/" ++ id)
                    , height 400
                    ]
                    []
            )
            |> Markdown.Html.withAttribute "id"
        ]
