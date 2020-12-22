---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Structure Elm into a multi-widget app for IHP",
  "description": "Making the widget-equivalent of Richard Feldmans's RealWorld SPA.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-22",
  "draft": false,
  "slug": "structure-elm-into-a-multi-widget-app-for-ihp",
  tags: [],
}
---

_This is **part 3** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_

We have set up a single widget and most of our logic lives in a single `Main.elm` file.

Since we are planning on creating an application supporting multiple isolated widgets, we might as well split this application into smaller more maintainable sub-modules with their own seperate model, view and update functions.

A simplified version of [Richard Feldmans's RealWord Example app](https://github.com/rtfeldman/elm-spa-example) is a great architecture for this use-case.

## Continue from part two

If you haven't done [part 2](blog/passing-flags-from-ihp-to-elm) of this series, do so first.

**If you don't want to**, you could [clone the project source](https://github.com/kodeFant/ihp-with-elm) and checkout to this tag to follow along:

```bash
git clone https://github.com/kodeFant/ihp-with-elm.git
cd ihp-with-elm
git checkout tags/3-pass-data-from-ihp-to-elm -b structure-elm-into-a-multi-widget-app
npm install
```

## Separating the BookWidget module

Inside the `elm` folder, let's create a sub-folder named `Widget`, and a module inside named `Book.elm`

```bash
mkdir elm/Widget
touch elm/Widget/Book.elm
```

Let us extract all the relevant logic into `elm/Widget/Book.elm`.

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
subscriptions _ =
    Sub.none


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
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

What's nice about this is that we now can maintain this entire widget inside this isolated module.

Now we need to rewrite `Main.elm` into a central hub that can support many different Elm widgets.

```elm
module Main exposing (main)

import Api.Generated exposing (Book, bookDecoder, widgetDecoder, Widget(..))
import Browser
import Html exposing (..)
import Json.Decode as D
import Widget.Book


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


view : Model -> Html Msg
view model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg

        BookModel book ->
            Html.map GotBookMsg (Widget.Book.view book)


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
            BookModel book
```

## Add a new widget

Let's start the process of adding a new widget. As you might have guessed, it starts with Haskell.

The first thing we need to do is to add it to the Widget type in `/Application/Helper/View.hs`:

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

We can also add a new widget entrypoint named `bookSearchWidget`.

This one won't use any initial data from IHP. Therefore, we won't need to pass in any data other than the `Widget` type's representation on the `BookSearchWiget`.

```hs
bookSearchWidget :: Html
bookSearchWidget = [hsx|
    <div data-flags={encode BookSearchWidget} class="elm"></div>
|]
```

Make sure the module can expose the `bookSearchWidget` at the module definition.

```hs
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

## Break the app

We should now generate the types for the new Elm widgets defined in Haskell.

Imagine someone saying this for a JavaScript tutorial: **Let's break the app to make it better.**

Close the server **(ctrl+c)** and start it again with the npm script which also should generate the new types.

```bash
npm start
```

`Main.elm` should now be complaining. Good! Let's first make the separate `BookSearch` module.

## Make the initial BookSearch widget

First create a new file for the new Widget.

```bash
touch elm/Widget/BookSearch.elm
```

Then create a simple module to start with.

```elm
module Widget.BookSearch exposing (..)

import Api.Generated exposing (Book)
import Html exposing (..)


type alias Model =
    Result String (List Book)


initialModel : Model
initialModel =
    Ok []


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


view : Model -> Html Msg
view model =
    div []
        [ h2 []
            [ text "🔎 Search Books 🔎" ]
        ]
```

## Add the new widget to Main.elm

To finally get rid of the Elm errors, let's fix `Main.elm` step-by-step.

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

The Main `update` function also needs to deal with the sub-module. This looks complicated, but it's worth it 😄 Next time you add something, just follow the pattern.

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

Keep on just adding to the pattern with `subscriptions` and `view`.

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


view : Model -> Html Msg
view model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg

        BookSearchModel subModel ->
            Html.map GotBookSearchMsg (Widget.BookSearch.view subModel)

        BookModel book ->
            Html.map GotBookMsg (Widget.Book.view book)
```

The last thing the compiler should complain about is `widgetFlagToModel`. This one decides which widget to display based on the flags from IHP and returns the initial model.

```elm
widgetFlagToModel : Widget -> Model
widgetFlagToModel widget =
    case widget of
        BookWidget book ->
            BookModel book

        BookSearchWidget ->
            BookSearchModel Widget.BookSearch.initialModel
```

Going into any book, you should now see a very dumb widget below that is just a title:

![A dumb Elm widget](/images/archive/ihp-with-elm/dumb-widget.png)

## Next up

We will finalize this simple book app by making the new `BookSearch` widget more advanced with basic search functionality.

By doing this, we will walk through the final part of doing IHP interop Elm: **JSON HTTP requests with IHP through Elm**. And we'll finally get to update some Elm state 😊
