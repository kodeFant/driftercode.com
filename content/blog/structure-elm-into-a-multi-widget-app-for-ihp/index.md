---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Structure Elm into a multi-widget app for IHP",
  "description": "We are making the widget-based equivalent of Richard Feldmans's RealWorld example.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-22",
  "draft": true,
  "slug": "structure-elm-into-a-multi-widget-app-for-ihp",
  tags: [],
}
---

_This is **part 3** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_

We have set up a single widget and most of our logic lives in a single `Main.elm` file.

Since we are planning on creating an application supporting multiple isolated widgets, we might as well split this application into smaller more maintainable sub-modules with their own seperate models and update functions.

A simplified version of [Richard Feldmans's RealWord Example app](https://github.com/rtfeldman/elm-spa-example) is a great architecture for this use-case.

## Continue from part one

If you haven't done [part 2](blog/passing-flags-from-ihp-to-elm) of this series, do so first.

**If you don't want to**, you could [clone the soruce](https://github.com/kodeFant/ihp-with-elm) and checkout to this tag to follow along:

```bash
git clone https://github.com/kodeFant/ihp-with-elm.git
cd ihp-with-elm
git checkout tags/3-pass-data-from-ihp-to-elm -b structure-elm-into-a-multi-widget-app
npm install
```

## Separating the BookWidget module

Inside the `elm` folder, let's create a sub-folder named `Widget`, and a module inside named `Book.elm`

```
mkdir elm/Widget
touch elm/Widget/Book.elm
```

Let us extract all the relevant logic from `Main.elm` into this one:

```elm
module Widget.Book exposing (..)

import Api.Generated exposing (Book)
import Html exposing (..)
import Json.Decode as D


type alias Model =
    Book


init : Book -> ( Model, Cmd msg )
init book =
    ( book, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html msg
view book =
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


showReview : Maybe String -> Html msg
showReview maybeReview =
    case maybeReview of
        Just review ->
            text ("Your book review: " ++ review)

        Nothing ->
            text "You have not reviewed this book"

```

What's nice about this is that we now can maintain this entire widget inside an isolated module fearlessly. A nice separation in my opionion.

Now we need to rewrite `Main.elm` into a central hub for all IHP widgets.

```elm
module Main exposing (main)

import Api.Generated exposing (Book, bookDecoder, widgetDecoder, Widget(..))
import Browser
import Html exposing (Html, div, h1, h2, p, pre, text)
import Json.Decode as D
import Widget.Book
import Widget.BookSearch


type Model
    = BookModel Widget.Book.Model
    | ErrorModel String


type Msg
    = GotBookMsg Widget.Book.Msg
    | WidgetErrorMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotBookMsg subMsg, BookModel book ) ->
            Widget.Book.update subMsg book
                |> updateWith BookModel GotBookMsg model

        ( WidgetErrorMsg, ErrorModel _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


subscriptions : Model -> Sub Msg
subscriptions parentModel =
    case parentModel of
        BookModel book ->
            Sub.map GotBookMsg (Widget.Book.subscriptions book)

        ErrorModel err ->
            Sub.none


view : Model -> Html msg
view model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg

        BookModel book ->
            Widget.Book.view book


errorView : String -> Html msg
errorView errorMsg =
    pre [] [ text "Widget Error: ", text errorMsg ]


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


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
            BookModel book:w

```

## Add a new widget

Let's add a new widget. The first thing we need to do is to register it into the Widget type in `/Application/Helper/View.hs`:

```hs
data Widget
  = BookWidget BookJSON
  | BookSearchWidget
  deriving (Generic, Aeson.ToJSON, SOP.Generic, SOP.HasDatatypeInfo)
```

We can also add another bookSearchWidget. This one won't take in any initial data from IHP. We won't need to pass in any data other than something that instructs Elm in what widget to run.

```hs
bookSearchWidget :: Html
bookSearchWidget = [hsx|
    <div  data-flags={encode BookSearchWidget} class="elm"></div>
|]
```

Finally, make sure the module can expose the `bookSearchWidget`.

```
module Application.Helper.View (
    -- To use the built in login:
    -- module IHP.LoginSupport.Helper.View
    bookWidget,
    bookSearchWidget,
    Widget(..)

) where
```

## Add widget to view

To demonstrate that we can insert many Elm views into one page, let's also add the `bookSearchWidget` into `/Web/View/Books/Show.hs`.

```hs
instance View ShowView where
    html ShowView { .. } = [hsx|
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href={BooksAction}>Books</a></li>
                <li class="breadcrumb-item active">Show Book</li>
            </ol>
        </nav>
        <h1>Show Book</h1>
        {bookWidget book}
        {bookSearchWidget}
    |]
```

Let's run `npm start` and see what we get.

## Make the initial BookSearch widget

Let's make the Elm app break.

Close the server **(ctrl+c)**, generate the types and run it again (if you added `gen-types` to the start script, you can run `npm start` only).

```bash
npm run gen-types
npm start
```

Let's start by making the separate `BookSearch` module.

```elm
module Widget.BookSearch exposing (..)

import Api.Generated exposing (Book)
import Html exposing (..)
import Http


type alias Model =
    Result Http.Error (List Book)


initialModel : Model
initialModel = Ok []

init : Model -> ( Model, Cmd msg )
init model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



view : Model -> Html msg
view model =
    h2 [] [ text "Search Books 📚" ]
```

## Add BookSearch to Main.elm

To get rid of the Elm errors, let's fix `Main.elm` step-by-step.

First, let's import the new widget module into Main.

```elm
import Widget.BookSearch
```

The `Model` and `Msg` types in Main needs to be have a variant for BookSearch.

```elm
type Model
    = BookModel Widget.Book.Model
    | BookSearchModel Widget.BookSearch.Model
    | ErrorModel String


type Msg
    = GotBookMsg Widget.Book.Msg
    | GotBookSearchMsg Widget.BookSearch.Msg
    | WidgetErrorMsg
```

The Main `update` function also needs to deal with the sub-module. This looks complicated, but Elm's type system should make it possible to figure this out. Note that this one has a catch-all at the end, so Elm won't crash if you forget to put it in. 

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotBookMsg subMsg, BookModel book ) ->
            Widget.Book.update subMsg book
                |> updateWith BookModel GotBookMsg model

        ( GotBookSearchMsg subMsg, BookSearchModel subModel) ->
            Widget.BookSearch.update subMsg subModel
                |> updateWith BookSearchModel GotBookSearchMsg model
                

        ( WidgetErrorMsg, ErrorModel _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


```

The same procedure with `subscriptions` and `view`.

```elm
subscriptions : Model -> Sub Msg
subscriptions parentModel =
    case parentModel of
        BookModel book ->
            Sub.map GotBookMsg (Widget.Book.subscriptions book)

        BookSearchModel subModel ->
            Sub.map GotBookSearchMsg (Widget.BookSearch.subscriptions subModel)

        ErrorModel err ->
            Sub.none


view : Model -> Html msg
view model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg
        
        BookSearchModel subModel ->
            Widget.BookSearch.view subModel

        BookModel book ->
            Widget.Book.view book
```

The last error is on the `widgetFlagToModel` that decides which widget to display based on the flags from IHP and returns the initial model. For the view.

```elm
widgetFlagToModel : Widget -> Model
widgetFlagToModel widget =
    case widget of
        BookWidget book ->
            BookModel book

        BookSearchWidget ->
            BookSearchModel Widget.BookSearch.initialModel
```

You should now see a very dumb widget with a title.

## Next up

We will finalize this simple book app by making the new Book Search widget more dynamic with live search functionality.

We will also finally walk through the final part of IHP interop: **Http requests with IHP**.