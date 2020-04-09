module MarkdownRenderer exposing (Rendered, pageRenderer, wordCountMarkdownView)

import Design.Palette as Palette
import Design.Styles exposing (linkStyle)
import Element
    exposing
        ( Element
        , alignTop
        , centerX
        , column
        , el
        , fill
        , height
        , link
        , maximum
        , moveRight
        , newTabLink
        , none
        , padding
        , paddingEach
        , paddingXY
        , paragraph
        , row
        , spacing
        , text
        , width
        , wrappedRow
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode as Encode
import Markdown.Block exposing (HeadingLevel(..), ListItem(..), Task(..), headingLevelToInt)
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer)
import Media.Svgs exposing (quoteSvg)
import Pages


type alias Rendered msg =
    ( Int, List (Element msg) )


wordCountMarkdownView : String -> Result String ( Int, List (Element msg) )
wordCountMarkdownView markdown =
    let
        wordCount =
            List.length (String.split " " markdown)
    in
    case markdown |> Markdown.Parser.parse of
        Ok okAst ->
            case Markdown.Renderer.render pageRenderer okAst of
                Ok rendered ->
                    Ok ( wordCount, rendered )

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


pageRenderer : Renderer (Element msg)
pageRenderer =
    { heading = heading
    , paragraph = mdParagraph
    , blockQuote = blockQuote
    , html = html
    , text = text
    , codeSpan = codeSpan
    , strong = strong
    , emphasis = emphasis
    , hardLineBreak = hardLineBreak
    , link = mdLink
    , image = image
    , unorderedList = unorderedList
    , orderedList = orderedList
    , codeBlock = codeBlock
    , thematicBreak = thematicBreak
    , table = Element.column []
    , tableHeader = Element.column []
    , tableBody = Element.column []
    , tableRow = Element.row []
    , tableHeaderCell =
        \_ children ->
            Element.paragraph [] children
    , tableCell = Element.paragraph []
    }


heading :
    { level : HeadingLevel
    , rawText : String
    , children : List (Element msg)
    }
    -> Element msg
heading { level, children } =
    let
        style =
            case level of
                H1 ->
                    [ Font.size 36 ]

                H2 ->
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
         , Region.heading (headingLevelToInt level)
         , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
         ]
            ++ style
        )
        children


mdParagraph : List (Element msg) -> Element msg
mdParagraph elements =
    paragraph [ Element.spacing 15 ] elements


blockQuote : List (Element msg) -> Element msg
blockQuote elements =
    paragraph [] elements


codeSpan : String -> Element msg
codeSpan string =
    el [ Font.bold ] (text string)


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


strong : List (Element msg) -> Element msg
strong content =
    if List.length content == 1 then
        el [ Font.bold ] (getFirst content)

    else
        paragraph [ Font.bold ] content


emphasis : List (Element msg) -> Element msg
emphasis content =
    if List.length content == 1 then
        el [ Font.italic ] (getFirst content)

    else
        paragraph [ Font.bold ] content


hardLineBreak : Element msg
hardLineBreak =
    el [] (text "lineBreak")


mdLink : { title : Maybe String, destination : String } -> List (Element msg) -> Element msg
mdLink { destination } body =
    case List.head body of
        Just bodyElement ->
            case Pages.isValidRoute destination of
                Ok _ ->
                    if String.startsWith "http" destination then
                        newTabLink linkStyle
                            { label = bodyElement
                            , url = destination
                            }

                    else
                        link linkStyle
                            { label = bodyElement
                            , url = destination
                            }

                Err string ->
                    text string

        Nothing ->
            none


image : { src : String, alt : String, title : Maybe String } -> Element msg
image { src, alt } =
    el
        [ height (fill |> maximum 600) ]
        (Element.image
            [ centerX
            , width (fill |> maximum 600)
            ]
            { description = alt, src = src }
        )



--     , unorderedList : List (List view) -> view
--     , orderedList : Int -> List (List view) -> view


unorderedList : List (ListItem (Element msg)) -> Element msg
unorderedList items =
    Element.textColumn [ Element.spacing 15, moveRight 15, width fill ]
        (items
            |> List.map
                (\(ListItem task children) ->
                    wrappedRow
                        [ alignTop, width fill ]
                        ((case task of
                            IncompleteTask ->
                                Input.defaultCheckbox False

                            CompletedTask ->
                                Input.defaultCheckbox True

                            NoTask ->
                                text "•"
                         )
                            :: text " "
                            :: children
                        )
                )
        )


orderedList : Int -> List (List (Element msg)) -> Element msg
orderedList startingIndex items =
    column [ spacing 15, moveRight 15 ]
        (items
            |> List.indexedMap
                (\index itemBlocks ->
                    row [ spacing 5 ]
                        [ row [ alignTop ]
                            (text (String.fromInt (index + startingIndex) ++ ". ") :: itemBlocks)
                        ]
                )
        )


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


getFirst : List (Element msg) -> Element msg
getFirst content =
    case List.head content of
        Just cont ->
            cont

        Nothing ->
            none
