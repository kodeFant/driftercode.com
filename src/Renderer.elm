module Renderer exposing (Rendered, wordCountMarkdownView)

import DefaultHtmlRenderer exposing (defaultHtmlRenderer)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Json.Encode as Encode
import Markdown.Block exposing (HeadingLevel(..), ListItem(..), Task(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import Pages
import Styled


type alias Rendered msg =
    ( Int, List (Html msg) )


wordCountMarkdownView : String -> Result String ( Int, List (Html msg) )
wordCountMarkdownView markdown =
    let
        wordCount =
            List.length (String.split " " markdown)
    in
    case markdown |> Markdown.Parser.parse of
        Ok okAst ->
            case Markdown.Renderer.render htmlRenderer okAst of
                Ok rendered ->
                    Ok ( wordCount, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


htmlRenderer : Renderer (Html msg)
htmlRenderer =
    { defaultHtmlRenderer
        | html = html
        , codeBlock = codeBlock
        , link = mdLink
        , image = image
    }


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


mdLink : { title : Maybe String, destination : String } -> List (Html msg) -> Html msg
mdLink { destination } body =
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
