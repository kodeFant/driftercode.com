module Renderer.View exposing (Rendered, wordCountMarkdownView)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Markdown.Block exposing (HeadingLevel(..), ListItem(..), Task(..))
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import Renderer.Markdown exposing (mainRenderer)


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
            case Markdown.Renderer.render mainRenderer okAst of
                Ok rendered ->
                    Ok ( wordCount, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")
