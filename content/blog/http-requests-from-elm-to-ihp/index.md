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

_This is **part 4** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_

We have Elm set up in IHP, initialized values from flags and we are just going through the final part of making our Elm widgets fully interoperable with IHP: **HTTP requests**.

I'm happy to say that most of what we did in the last post also applies for http requests.

In `/Application/View/Show.hs`, let's

## Install elm/http

This tutorial only needs one additional package, the official `elm/http`, so let's just install that right away.

```bash
elm-json install elm/http
```

## Support json response from /Books

The `/Books` endpoint currently delivers HTML by default, but we can easily make it return JSON as well.

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

It's nice that we can use the same type that we defined for the Elm flags.

A list of `Book` now maps into a list of the `BookJSON` type we defined in the previous post and turns it into a plain JSON representation, and it can be decoded by the same `bookDecoder` we generated into Elm.

The `/Books` endpoint will now serve you HTML by default. But if you set the header `Accept: application/json`, it will display the JSON version instead. You can test it with curl:

```bash
curl -H "Accept: application/json" http://localhost:8000/Books
```

## Add widget to

Let's first create the file `/elm/Api/Http.elm` for a place to make http requests.

```bash
touch elm/Api/Http.elm
```

To make sure we remember to set the `Accept: application/json` header, let's define a wrapper around Elm's `Http.request` and call it `ihpRequest`.

The `getBooksAction` function will take in a string and a generic `msg` type taking in a `Result`. You could use [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/RemoteData)of course, but we'll skip it for this tutorial.

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

## Make an ErrorView module

It can be nice to display some Http errors of various sorts in a standardised way. I like to make a view function for this.

Let's create a new Elm module at `/elm/ErrorView.elm`

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
