module MarkdownRenderer exposing (Rendered, markdownView, pageRenderer)

import Element
    exposing
        ( Element
        , alignTop
        , centerX
        , column
        , el
        , fill
        , height
        , maximum
        , moveRight
        , none
        , padding
        , paddingEach
        , paddingXY
        , paragraph
        , row
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode as Encode
import Markdown.Html
import Markdown.Parser exposing (Renderer)
import Media.Svgs exposing (quoteSvg)
import Palette


type alias Rendered msg =
    ( Int, List (Element msg) )


markdownView : String -> Result String ( Int, List (Element msg) )
markdownView markdown =
    let
        wordCount =
            List.length (String.split " " markdown)
    in
    case markdown |> Markdown.Parser.parse of
        Ok okAst ->
            case Markdown.Parser.render pageRenderer okAst of
                Ok rendered ->
                    Ok ( wordCount, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


pageRenderer : Renderer (Element msg)
pageRenderer =
    { heading = heading
    , raw = raw
    , html = html
    , plain = plain
    , code = code
    , bold = bold
    , italic = italic
    , link = mdLink
    , image = image
    , unorderedList = unorderedList
    , orderedList = orderedList
    , codeBlock = codeBlock
    , thematicBreak = thematicBreak
    }


heading :
    { level : Int
    , rawText : String
    , children : List (Element msg)
    }
    -> Element msg
heading { level, children } =
    let
        style =
            case level of
                1 ->
                    [ Font.size 36 ]

                2 ->
                    [ Font.size 24 ]

                _ ->
                    [ Font.size 20 ]
    in
    paragraph
        ([ Font.bold
         , Font.family
            [ Font.typeface "Merriweather"
            , Font.serif
            ]
         , Region.heading level
         , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
         ]
            ++ style
        )
        children


raw : List (Element msg) -> Element msg
raw elements =
    paragraph [ width fill, spacing 10 ] elements


html : Markdown.Html.Renderer (List (Element msg) -> Element msg)
html =
    Markdown.Html.oneOf
        [ Markdown.Html.tag "youtube"
            (\id _ ->
                el [ paddingXY 0 16, width fill, height (fill |> maximum 500) ]
                    (Element.html
                        (Html.iframe
                            [ Html.Attributes.src ("https://www.youtube.com/embed/" ++ id)
                            , Html.Attributes.height 400
                            ]
                            []
                        )
                    )
            )
            |> Markdown.Html.withAttribute "id"
        , Markdown.Html.tag "blockquote"
            (\quote author _ ->
                let
                    authorField =
                        case author of
                            Just auth ->
                                paragraph [ Font.bold ] [ text auth ]

                            Nothing ->
                                none
                in
                row
                    [ Border.widthEach { left = 10, right = 0, top = 0, bottom = 0 }
                    , Border.color Palette.color.primary
                    , Background.color Palette.color.lighterGray
                    , padding 20
                    , spacing 16
                    , Font.size 22
                    ]
                    [ el [ Font.color Palette.color.primary, Font.size 44, padding 10 ]
                        (Element.html quoteSvg)
                    , column
                        [ width fill ]
                        [ paragraph [ Font.italic ] [ text quote ]
                        , authorField
                        ]
                    ]
            )
            |> Markdown.Html.withAttribute "quote"
            |> Markdown.Html.withOptionalAttribute "author"
        ]


plain : String -> Element msg
plain string =
    text string


code : String -> Element msg
code string =
    el [] (text string)


bold : String -> Element msg
bold string =
    el [ Font.bold ] (text string)


italic : String -> Element msg
italic string =
    el [ Font.italic ] (text string)


mdLink : { title : Maybe String, destination : String } -> List (Element msg) -> Result String (Element msg)
mdLink link body =
    -- Pages.isValidRoute link.destination
    --     |> Result.map
    --         (\() ->
    Element.newTabLink
        [ Element.htmlAttribute (Html.Attributes.style "display" "inline-flex")
        , Font.color Palette.color.primary
        ]
        { url = link.destination
        , label =
            Element.paragraph
                []
                body
        }
        |> Ok


image : { src : String } -> String -> Result String (Element msg)
image { src } description =
    el
        [ height (fill |> maximum 600) ]
        (Element.image
            [ centerX
            , width (fill |> maximum 600)
            ]
            { description = description, src = src }
        )
        |> Ok



--     , unorderedList : List (List view) -> view
--     , orderedList : Int -> List (List view) -> view


unorderedList : List (List (Element msg)) -> Element msg
unorderedList items =
    Element.column [ Element.spacing 15 ]
        (items
            |> List.map
                (\itemBlocks ->
                    Element.wrappedRow [ Element.spacing 5, moveRight 5 ]
                        [ el [ alignTop ] (text "•")
                        , paragraph [] itemBlocks
                        ]
                )
        )


orderedList : Int -> List (List (Element msg)) -> Element msg
orderedList _ _ =
    column [ spacing 15 ]
        []


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock details =
    case details.language of
        Just lang ->
            Html.node "code-editor"
                [ editorValue details.body
                , Html.Attributes.style "white-space" "normal"
                , Html.Attributes.attribute "language" lang
                ]
                []
                |> Element.html
                |> Element.el [ Element.width Element.fill ]

        Nothing ->
            Html.node "code-editor"
                [ editorValue details.body
                , Html.Attributes.style "white-space" "normal"
                ]
                []
                |> Element.html
                |> Element.el [ Element.width Element.fill ]


thematicBreak : Element msg
thematicBreak =
    el [] (text "Thematic Break")


editorValue : String -> Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorValue"
