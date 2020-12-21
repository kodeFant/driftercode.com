---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "How to talk with IHP from an Elm widget",
  "description": "Generate types, encoders and decoders for Elm automatically in IHP.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-19",
  "draft": true,
  "slug": "http-requests-from-elm-to-ihp",
  tags: [],
}
---

_This is **part 3** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_

We have Elm set up in IHP, initialized values from flags and we are just going through the final part of making our Elm widgets fully interoperable with IHP: **HTTP requests**.

I'm happy to say that most of what we did in the last post also applies for http requests.

In `/Application/View/Show.hs`, let's

## Install elm/http

This tutorial only needs one additional package, the official `elm/http`, so let's just install that right away.

```bash
elm-json install elm/http
```

## Make the Book index output JSON in addition to HTMl

Thanks to what we have done so far, making the index view of `Book` is very simple.

Add this import in the top of `/Application/View/Books/Index.hs`

```hs
import Web.JsonTypes ( bookToJSON )
```

Then all we have to do is to add the line `json IndexView {..} = toJSON (books |> map bookToJSON)` to the bottom of this instance:

```hs
instance View IndexView where
    html IndexView { .. } = [hsx|
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item active"><a href={BooksAction}>Books</a></li>
            </ol>
        </nav>
        <h1>Index <a href={pathTo NewBookAction} class="btn btn-primary ml-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Book</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach books renderBook}</tbody>
            </table>
        </div>
    |]

    json IndexView {..} = toJSON (books |> map bookToJSON)
```
A List of `Book` maps into a List of the `BookJSON` type we defined in the previous post and turns it into JSON.

The `/Books` endpoint will now serve you HTML by default. But if you set the header `Accept: application/json`, it will display the JSON version instead. You can test it with curl:

```bash
curl -H "Accept: application/json" http://localhost:8000/Books
```

So, to over-explain it: Remove that header from the curl, and you'll of course get the HTML back. 

## Add a case for the Widget type

In `Application/Helper/View.hs`, all we need is adding another case in the data type. This widget won't have any data, but will be passed as a flag to tell Elm which widget to load.

```hs
data Widget
  = BookWidget BookJSON
  | BookSearchWidget
  deriving ( Generic
           , Aeson.ToJSON
           , SOP.Generic
           , SOP.HasDatatypeInfo
           )
```

So in the same file, lets add another Elm widget entrypoint.

```hs
bookSearchWidget ::  Html
bookSearchWidget = [hsx|
    <div data-flags={encode BookSearchWidget} class="elm"></div>
|]
```

And of course, we must add the `bookSearchWidgets` in the module definition on top:

```
module Application.Helper.View (
    -- To use the built in login:
    -- module IHP.LoginSupport.Helper.View
    bookWidget,
    bookSearchWidget,
    Widget(..),
) where
```

By updating the Widget type, we can auto-generate the types:

```bash
npm start gen-types
```

Elm complain a bit not, so let's do some stuff to fix that.

## Add widget to 

Let's first create the file `/elm/Api/Http.elm`.

```bash
touch elm/Api/Http.elm
```

To make sure we remember to set the `Accept: application/json` header, let's define a wrapper around Elm's `Http.request` and call it `ihpRequest`.

The `getBooksAction` function will take in a string and a generic `msg` type taking in a `Result`. [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData) is of probably a better data model, but let's not cram in to many things in this lesson.

```elm
module Api.Http exposing (..)

import Api.Generated exposing (Book, bookDecoder)
import Http
import Json.Decode as D


getBooksAction : String -> (Result Http.Error (List Book) -> msg) -> Cmd msg
getBooksAction searchTerm msg =
    ihpRequest
        { method = "GET"
        , headers = []
        , url = "/Books?searchTerm=" ++ searchTerm
        , body = Http.emptyBody
        , expect = Http.expectJson msg (D.list bookDecoder)
        }

ihpRequest :
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Cmd msg
ihpRequest { method, headers, url, body, expect } =
    Http.request
        { method = method
        , headers = [ Http.header "Accept" "application/json" ] ++ headers
        , url = url
        , body = body
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }

```

Then we will have to handle

```elm
module Main exposing (main)

import Api.Http exposing (getBooksAction)
import Api.Generated exposing (Book, Widget(..), widgetDecoder)
import Browser
import Html exposing (..)
import Html.Attributes exposing (href, placeholder, type_)
import Html.Events exposing (onInput)
import Http
import Json.Decode as D



-- MAIN


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

-- INIT


init : D.Value -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags
    , Cmd.none
    )


initialModel : D.Value -> Model
initialModel flags =
    case D.decodeValue widgetDecoder flags of
        Ok widget ->
            widgetFlagToModel widget

        Err error ->
            ErrorModel (D.errorToString error)


widgetFlagToModel : Widget -> Model
widgetFlagToModel widget =
    case widget of
        BookWidget book ->
            BookModel book

        BookSearchWidget ->
            BookSearchModel (Ok []) ""



-- MODEL


type Model
    = BookModel Book
    | BookSearchModel (Result Http.Error (List Book)) String
    | ErrorModel String



-- UPDATE


type Msg
    = UpdatedSearchInput String
    | GotBookSearchResult (Result Http.Error (List Book))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        BookSearchModel books searchTerm ->
            case msg of
                UpdatedSearchInput newSearchTerm ->
                    ( BookSearchModel books newSearchTerm
                    , getBooksAction newSearchTerm GotBookSearchResult
                    )

                GotBookSearchResult booksResult ->
                    ( BookSearchModel booksResult searchTerm
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )


httpErrorView : Http.Error -> Html msg
httpErrorView error =
    case error of
        Http.BadUrl info ->
            pre [] [ text "BadUrl: ", text info ]

        Http.NetworkError ->
            pre [] [ text "Network Error" ]

        Http.Timeout ->
            pre [] [ text "Timeout" ]

        Http.BadStatus code ->
            pre [] [ text ("BadStatus: " ++ String.fromInt code) ]

        Http.BadBody info ->
            pre [] [ text info ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none





-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text "<🌳>"
        , widgetView model
        , text "</🌳>"
        ]


widgetView : Model -> Html Msg
widgetView model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg

        BookModel book ->
            bookView book

        BookSearchModel books searchTerm ->
            bookSearchView books searchTerm


errorView : String -> Html msg
errorView errorMsg =
    pre [] [ text "Widget Error: ", text errorMsg ]


bookView : Book -> Html msg
bookView book =
    div []
        [ h2 [] [ text book.title ]
        , p []
            [ text "Pages: "
            , book.pageCount |> String.fromInt |> text
            ]
        , p []
            [ text
                (if book.hasRead == True then
                    "You have read this book"

                 else
                    "You have not read this book"
                )
            ]
        , p [] [ showReview book.review ]
        ]


bookSearchView : Result Http.Error (List Book) -> String -> Html Msg
bookSearchView books searchTerm =
    div []
        [ h2 [] [ text "Book Search" ]
        , Html.input
            [ type_ "search"
            , onInput UpdatedSearchInput
            , placeholder "Search by book title"
            ]
            []
        , bookSearchResults books searchTerm
        ]


bookSearchResults : Result Http.Error (List Book) -> String -> Html msg
bookSearchResults booksResult searchTerm =
    case searchTerm of
        "" ->
            div [] [ text "Enter a search term" ]

        _ ->
            case booksResult of
                Ok books ->
                    div []
                        (books
                            |> List.map bookSearchResult
                        )

                Err error ->
                    div [] [ text "Something went wrong" ]


bookSearchResult : Book -> Html msg
bookSearchResult book =
    let
        bookLink =
            "/ShowBook?bookId=" ++ book.id
    in
    p [] [ a [ href bookLink ] [ text book.title ] ]


showReview : Maybe String -> Html msg
showReview maybeReview =
    case maybeReview of
        Just review ->
            text ("Your book review: " ++ review)

        Nothing ->
            text "You have not reviewed this book"

```

Up until now, it has been fairly simple to keep everything in `Main.elm`, but it is growing in complexity. The logic for each widget should probably be separated since they all have their unique individual model any way.

In the next and final lesson, we will figure out how to make a more maintainable widget architecture.