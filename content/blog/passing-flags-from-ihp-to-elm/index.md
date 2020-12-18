---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Passing values from IHP to Elm",
  "description": "Pass Haskell data directly to your Elm widget.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-17",
  "draft": true,
  "slug": "pass-data-from-ihp-to-elm",
  tags: [],
}
---

Setting initial values in Elm is easy because you have the opportunity to define flags during the initialization of Elm. That saves you from fetching those initial values from a separate endpoint.

For this part of the series, I want to show you some techniques for loading these values immediately as soon as the page has loaded.

This will also be the first step towards using Elm as a widget loader. As mentioned in the last post, replacing IHP's templates with a full Elm application is opting out of the amazing features of IHP.

Regular server-rendered HTML is faster and gives you that SSR everyone is talking about without the added complexity of something like NextJS. Only when you think "I need Elm for this", use Elm. If you can do without, it's in my opinion simpler and better to just use HTML.

All this being said, these examples will be very simple to reduce the chance of confusion.

## This is going to be long

Take a good breath. There is quite some things to do here. But you are on your way to make a cool system for implementing Elm views wherever you want in you Applications with auto-generated types. How cool is that?

If you haven't done [part 1](blog/ihp-with-elm) of this series, do so. Or you could [clone how far we have come so far](https://github.com/kodeFant/ihp-with-elm/tree/setup-elm-in-ihp) (Remember to do an `npm install` in that case).

**Remember to run you scripts inside `nix-shell`. Some commands does not work outside that environment.**


## Create a Haskell type

To demonstrate how we can insert different datatypes into Elm, let's create a relatively complex data model.

Run `npm start` and go to [htts://localhost:8001/Tables](htts://localhost:8001/Tables).

Right click and select `Add Table` in the context menu. Name the table `books`.

Image

Right click and add columns to the database until you have these exact fields:

Image

Try to match these fields excactly to avoid getting into a confusing situation later :)

Double check `Schema.sql` file to ensure the table schema looks like this.

```bash
-- Your database schema. Use the Schema Designer at http://localhost:8001/ to add some tables.
CREATE TABLE books (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    page_count INT NOT NULL,
    has_read BOOLEAN DEFAULT false NOT NULL,
    review TEXT DEFAULT NULL,
    published_at TIMESTAMP WITH TIME ZONE NOT NULL
);
```

When all the fields are filled in, press `Update DB`. This should update the database.

## Generate Controller and Views

Stay in the `localhost:8001` admin panel and select `Codegen` in the menu to the left.

Select `Controller`, name it `Books` and click `Preview` and click `Generate`.

You will now have generated all you need to view, update, create and delete books. Pretty cool!

Just a couple of small adjustments before we proceeed:

Let's just make a checkbox field for the boolean value.

In the files `New.hs` and `Edit.hs` in the `/Web/Controller/View/Books/` folder, replace these two fields:

```haskell
{{textField #hasRead}}
{{textField #publishedAt}}
```

to

```haskell
{{checkboxField #hasRead}}
{{dateField #publishedAt}}
```

Let's also take a short visit to the Controller at `/Web/Controller/Books.hs` and add let's make sure that the nullable type is null when the field is empty so we get a real Maybe.

```haskell
buildBook book = book
    |> fill @["title","pageCount","hasRead","review","publishedAt"]
    |> emptyValueToNothing #review
```

Go to [http://localhost:8000/Books](http://localhost:8000/Books) to create a couple of Books with some varying values.

## Some small changes in the hsx templates

First, navigate to `Web/View/Layout.hs` and add the elm script at the bottom in the body tag.

```hs
defaultLayout :: Html -> Html
defaultLayout inner = H.docTypeHtml ! A.lang "en" $ [hsx|
<head>
    {metaTags}

    {stylesheets}
    {scripts}

    <title>App</title>
</head>
<body>
    <div class="container mt-4">
        {renderFlashMessages}
        {inner}
       <script src="/elm/index.js"></script>
    </div>
</body>
|]
```

It's important to have this script at the bottom and not at the top with the other scripts.

Secondly, let's replace what we wrote in the previous part of the series in `/Web/View/Static/Welcome.hs`, just to have some nice linking to the Books.

```hs
module Web.View.Static.Welcome where
import Web.View.Prelude

data WelcomeView = WelcomeView

instance View WelcomeView where
    html WelcomeView = [hsx|
    <h1>The books app</h1>
    <a href={BooksAction}>See all my books</a>
|]
```

```hs
module Web.View.Static.Welcome where
import Web.View.Prelude

data WelcomeView = WelcomeView

instance View WelcomeView where
    html WelcomeView = [hsx|
    <h1>The books app</h1>
    <a href={BooksAction}>See all my books</a>
|]
```

## Install `haskell-to-elm`

`haskell-to-elm` will let us generate Elm types from Haskell types, including encoders and decoders.

In order to generate Elm types from IHP, add the `haskell-to-elm` package to **haskellDeps** in `default.nix`

```nix
  haskellDeps = p: with p; [
      ...
      haskell-to-elm
  ];
```

To update your local environment, close the server (ctrl+c) and run

```bash
nix-shell --run 'make -B .envrc'
```

Also add the required Elm packages needed by `haskell-to-elm`. I recommend [elm-json](https://github.com/zwilias/elm-json) to install elm packages from the command line.

```bash
elm-json install elm/json NoRedInk/elm-json-decode-pipeline elm-community/maybe-extra elm/time rtfeldman/elm-iso8601-date-strings
```

## Reduce boilerplate for Haskell to Elm types

Now, let's create a couple of new files. First some code to reduce the boilerplate

```
mkdir Application/Lib
touch Application/Lib/DerivingViaElm.hs
```

In `Application/Lib/DerivingViaElm.hs`, we are just inserting some logic for reducing boilerplate to `haskell-to-elm`. Just pasting in [this gist](https://gist.github.com/kodeFant/4513c07a78f35e0a879b0f3dd31efd9f) should do it. You can treat this like a library addition and you won't be touching it apart from importing it into the next file we are creating.

Create the **Haskell to Elm types** file.

```
touch Web/JsonTypes.hs
```

In `Web/JsonTypes.hs` we will create types that can be directly serialized into both Json and Elm decoders. For starters, make a `CompanyJSON` file and a function for converting a `Company` type.


```haskell
{-# language DeriveAnyClass #-}

module Web.JsonTypes where

import Generated.Types 
import IHP.ControllerPrelude
import qualified Data.Aeson as Aeson
import GHC.Generics (Generic)
import qualified Generics.SOP as SOP
import Language.Haskell.To.Elm
import Application.Lib.DerivingViaElm ( ElmType(..) )

-- JSON serializable types and functions for exposing IHP data to Elm and JSON responses

data BookJSON = BookJSON
  { title :: Text
  , pageCount :: Int
  , hasRead :: Bool
  , review :: Maybe Text
  , publishedAt :: UTCTime
  } deriving (Generic, SOP.Generic, SOP.HasDatatypeInfo)
    deriving (Aeson.ToJSON, Aeson.FromJSON, HasElmType, HasElmDecoder Aeson.Value, HasElmEncoder Aeson.Value) 
    via ElmType "Api.Generated.Book" BookJSON

bookToJSON :: (?context :: ControllerContext) => Book -> BookJSON
bookToJSON book =
    BookJSON {
        title = get #title book,
        pageCount = get #pageCount book,
        hasRead = get #hasRead book,
        review = get #review book,
        publishedAt = get #publishedAt book
    }
```

## Make a widget entry-point

A logical place to write the entrypoints for the Elm widget entrypoints is `Application/Helpers/View.hs`

```haskell
module Application.Helper.View (
    -- To use the built in login:
    -- module IHP.LoginSupport.Helper.View
    bookWidget
) where

-- Here you can add functions which are available in all your views
import IHP.ViewPrelude
import Generated.Types
import Data.ByteString.Lazy as BLS
import Data.Aeson
import Web.JsonTypes

-- To use the built in login:
-- import IHP.LoginSupport.Helper.View

bookWidget :: Book -> Html
bookWidget book = [hsx|
    <div data-type={widgetName} data-flags={flags} class="elm"></div>
|]
    where
        widgetName :: BLS.ByteString = "Book"
        bookData :: BookJSON = bookToJSON book
        flags :: BLS.ByteString = encode bookData
```

Not much code, but lots of power in here. Use the normal IHP type and insert it here, and this widget will pass the encoded version to Elm

Let's use this `bookWidget` function in the `/Web/View/Books/Show.hs`:

```haskell
module Web.View.Books.Show where
import Web.View.Prelude

data ShowView = ShowView { book :: Book }

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
    |]

```

Now we need to jump to the JavaScript file at `elm/index.js` and do some minor tweaks.

```tsx
import { Elm } from "./Main.elm";

const node = document.querySelector(".elm");
const flags = node.dataset.flags ? JSON.parse(node.dataset.flags) : null

Elm.Main.init({
  node,
  flags,
});
```

The value passed into the `data-flags` attribute is serialized and ready to be shot right through JavaScript and directly into Elm.

## Autogenerate types

Now it's time for the fun stuff. We need to go back to [http://localhost:8001](http://localhost:8001) and generate a script and select `Codegen` in the left menu and then `Script`. Type `GenerateElmTypes`, select `Preview` and then `Generate`.

IHP will have generated an executable script for you.

Write the export logic for generating Elm types in `/Application/Script/GenerateElmTypes.hs`:

```haskell
#!/usr/bin/env run-script
module Application.Script.GenerateElmTypes where

import Application.Script.Prelude
import qualified Language.Elm.Simplification as Simplification
import qualified Language.Elm.Pretty as Pretty
import Language.Haskell.To.Elm
import Data.Text.IO
import Web.JsonTypes
import qualified System.Directory as Directory
import qualified Data.HashMap.Lazy as HashMap

run :: Script
run = do
    let
        definitions = Simplification.simplifyDefinition <$>
                        jsonDefinitions @BookJSON

        modules = Pretty.modules definitions

    Directory.createDirectoryIfMissing False "elm/Api"

    forM_ (HashMap.toList modules) $ \(_moduleName, contents) ->
        writeFile "elm/Api/Generated.elm" (show contents)
```

Let's test it. Run:

```bash
nix-shell --run './Application/Script/GenerateElmTypes.hs'
```

Voila! If everything has gone well so far, you should have a file named `elm/Api/Generated.elm`. Inspect it with great joy. You didn't need to write any of this manually in Elm.

## Write some Elm

Let's finish up this tutorial by rewriting the `Main.elm` to decode the flags and use the Haskell model.

```elm
module Main exposing (main)

import Api.Generated exposing (Book, bookDecoder)
import Browser
import Html exposing (Html, div, h1, h2, p, pre, text)
import Json.Decode as D


type Model
    = BookView Book
    | ErrorModel String


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html msg
view model =
    div []
        [ text "<🌳>"
        , widgetView model
        , text "</🌳>"
        ]


widgetView : Model -> Html msg
widgetView model =
    case model of
        ErrorModel errorMsg ->
            errorView errorMsg

        BookView book ->
            bookView book


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
        , p [] [ text (if book.hasRead == True then "You have read this book" else "You have not read this book") ]
        , p [] [ showReview book.review ]
        ]


showReview : Maybe String -> Html msg
showReview maybeReview =
    case maybeReview of
        Just review ->
            text ("Your book review: " ++ review)

        Nothing ->
            text "You have not reviewed this book"


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
    ( case D.decodeValue bookDecoder flags of
        Ok model ->
            BookView model

        Err error ->
            ErrorModel (D.errorToString error)
    , Cmd.none
    )
```

Go to [localhost:8000/books](http://localhost:8000/books) and press show. You should see where Elm starts and begins with the <🌳> tag. Pretty cool. 