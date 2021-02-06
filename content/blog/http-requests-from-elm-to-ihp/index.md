---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Part 4: Making http requests from Elm to IHP",
  "description": "Communication between Elm and IHP through HTTP JSON requests.",
  "image": "images/article-covers/elm-in-ihp-part-4.jpg",
  "published": "2020-12-23",
  "draft": false,
  "slug": "http-requests-from-elm-to-ihp",
  tags: [],
}
---

_This is **part 4** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_

We have Elm set up in IHP, initialized values from flags and we are just going through the final part of making our Elm widgets fully interoperable with IHP: **HTTP requests**.

The architecture is pretty much in place now, so this part should be easy 🙂

## Continue from part three

If you haven't done [part 3](blog/structure-elm-into-a-multi-widget-app-for-ihp) of this series, do so first.

**If you don't want to**, you could [clone the project source](https://github.com/kodeFant/ihp-with-generated-elm) and checkout to this tag to follow along:

```bash
git clone https://github.com/kodeFant/ihp-with-elm.git
cd ihp-with-elm
git checkout tags/3-structure-elm-into-a-multi-widget-app -b http-requests-from-elm-to-ihp
npm install
```

## Install elm/http

This tutorial only needs one additional package, the official `elm/http`, so let's just install that right away.

```bash
elm-json install elm/http
```

## Support json response from /Books

The `/Books` endpoint currently delivers HTML by default, but we can easily make it return JSON as well.

Add this import in the top of `Application/View/Books/Index.hs`

```hs
import Web.JsonTypes ( bookToJSON )
```

Then all we have to do is to add the line `json IndexView {..} = toJSON (books |> map bookToJSON)` to the bottom of this instance:

```hs
instance View IndexView where
    html IndexView { .. } = [hsx|
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item active">
                    <a href={BooksAction}>Books</a>
                </li>
            </ol>
        </nav>
        <h1>
            Index
            <a href={pathTo NewBookAction} 
               class="btn btn-primary ml-4">
                + New
            </a>
        </h1>
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

It's nice that we can use the same type for the JSON API that we defined for the Elm flags.

A list of `Book` now maps into a list of `BookJSON`. In Elm, it  can be decoded by the same `bookDecoder` we generated earlier.

The `/Books` endpoint will still serve you HTML by default as before. But if you set the header `Accept: application/json`, it will display the JSON version instead. You can test it with curl:

```bash
curl -H "Accept: application/json" http://localhost:8000/Books
```

## Add http action in Elm for fetching books in IHP

Let's first create the file `elm/Api/Http.elm` for a place to make http requests.

```bash
touch elm/Api/Http.elm
```

To make sure we remember to set the `Accept: application/json` header, let's define a wrapper around Elm's `Http.request` and call it `ihpRequest`.

The `getBooksAction` function will take in a string and a generic `msg` type taking in a `Result`. You could use [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData) of course, but we'll skip it for this tutorial.

```elm
module Api.Http exposing (..)

import Api.Generated exposing (Book, bookDecoder)
import Http
import Json.Decode as D


getBooksAction :
    String
    -> (Result Http.Error (List Book) -> msg)
    -> Cmd msg
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
        , headers =
            [ Http.header "Accept" "application/json" ] ++ headers
        , url = url
        , body = body
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }
```

## Make an ErrorView module

It can be nice to display some Http errors of various sorts in a standardised way. I like to make a view function for this.

Let's create a new Elm module at `elm/ErrorView.elm`

```bash
touch elm/ErrorView.elm
```

Let write this little snippet:

```elm
module ErrorView exposing (..)

import Http
import Html exposing (Html, pre, text)

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
```

## Add interactivity to BookSearch

Let's import the stuff we need at the top of `elm/Widget/BookSearch.elm`.

```elm
import Api.Generated exposing (Book)
import Api.Http exposing (getBooksAction)
import ErrorView exposing (httpErrorView)
import Html exposing (..)
import Html.Attributes exposing (href, type_)
import Html.Events exposing (onInput)
import Http
```

We should then make the Model inside a bit more complex, so we can turn it into a record to track both the search-term and search-result.

```elm
type alias Model =
    { searchResult : Result Http.Error (List Book)
    , searchTerm : String
    }


initialModel : Model
initialModel =
    { searchResult = Ok []
    , searchTerm = ""
    }
```

To update the model, we are making two messages and some update logic.

Whenever the search input changes, we will update the model and at the same time make a query to IHP through the `getBooksAction` function.

```elm
type Msg
    = SearchInputChanged String
    | GotSearchResult (Result Http.Error (List Book))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInputChanged text ->
            ( { model | searchTerm = text }, getBooksAction text GotSearchResult )

        GotSearchResult result ->
            ( { model | searchResult = result }, Cmd.none )
```

And the view functionality is getting some more logic.

```elm
view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "📚 Search Books 📚" ]
        , input
            [ type_ "search"
            , onInput SearchInputChanged
            ]
            []
        , searchResultView model.searchResult
        ]


searchResultView : Result Http.Error (List Book) -> Html msg
searchResultView searchResult =
    case searchResult of
        Err error ->
            httpErrorView error

        Ok books ->
            ul [] (List.map bookItem books)


bookItem : Book -> Html msg
bookItem book =
    let
        bookLink =
            "/ShowBook?bookId=" ++ book.id
    in
    li [] [ a [ href bookLink ] [ text book.title ] ]
```

## Make Books searchable

Only thing left it to adjust the controller to support the `searchTerm` parameter.

This will be done in the `BooksAction` on `Web/Controller/Books.hs`:

```haskell
    action BooksAction = do
        let maybeSearchParam :: Maybe Text = 
                paramOrNothing "searchTerm"
        case maybeSearchParam of
            Nothing -> do
                books <- query @Book |> fetch
                render IndexView { .. }
            Just searchTerm -> do
                books <- sqlQuery
                    "SELECT * FROM books WHERE title ILIKE ?"
                    (Only ("%" ++ searchTerm ++ "%"))
                render IndexView { .. }
```

## Wrapping up

That should be it. You now have a highly interactive book search functionality without leaving the page.

![A smarter Elm widget](/images/archive/ihp-with-elm/smart-widget.gif)

This widget has an advantage by not demanding IHP data directly from flags.

You can put it anywhere and it will just query the correct IHP endpoint.

This should be a fine starting point for making an IHP app with all the Elm widgets you will need. Good luck 😊

See the complete code on [Github](https://github.com/kodeFant/ihp-with-generated-elm).
