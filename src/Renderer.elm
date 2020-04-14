module Renderer exposing (Rendered, wordCountMarkdownView)

import Element
    exposing
        ( Element
        , height
        , html
        , link
        , text
        )
import Html exposing (Attribute, Html, h1, h2, h3, h4, h5, h6)
import Html.Attributes exposing (class, property, target)
import Json.Encode as Encode
import Markdown.Block exposing (HeadingLevel(..), ListItem(..), Task(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
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
        , heading = heading
    }


heading : { children : List (Html msg), level : HeadingLevel, rawText : String } -> Html msg
heading { children, level } =
    case level of
        H1 ->
            h1 [ class "heading" ] children

        H2 ->
            h2 [ class "heading" ] children

        H3 ->
            h3 [ class "heading" ] children

        H4 ->
            h4 [ class "heading" ] children

        H5 ->
            h5 [ class "heading" ] children

        H6 ->
            h6 [ class "heading" ] children


html : Markdown.Html.Renderer (List (Html msg) -> Html msg)
html =
    Markdown.Html.oneOf
        [ Markdown.Html.tag "youtube"
            (\id _ ->
                Html.iframe
                    [ Html.Attributes.src ("https://www.youtube.com/embed/" ++ id)
                    , Html.Attributes.height 400
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
                            [ Html.Attributes.href destination
                            , target "_blank"
                            ]
                            [ bodyElement
                            ]

                    else
                        Styled.link [ Html.Attributes.href destination ]
                            [ bodyElement
                            ]

                Err string ->
                    Html.text string

        Nothing ->
            Html.text ""


image : { src : String, alt : String, title : Maybe String } -> Html msg
image { src, alt } =
    Styled.image [] { description = alt, path = src }


codeBlock : { body : String, language : Maybe String } -> Html msg
codeBlock details =
    case details.language of
        Just lang ->
            Html.node "code-editor"
                [ editorValue details.body
                , Html.Attributes.style "white-space" "normal"
                , Html.Attributes.attribute "language" lang
                ]
                []

        Nothing ->
            Html.node "code-editor"
                [ editorValue details.body
                , Html.Attributes.style "white-space" "normal"
                ]
                []


editorValue : String -> Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorValue"
