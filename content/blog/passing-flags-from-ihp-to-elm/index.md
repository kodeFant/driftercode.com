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

When initializing an Elm app through JavaScript, you have access to set initial values into the app through something called [flags](https://guide.elm-lang.org/interop/flags.html).

For this part of the series, I want to show you a technique for loading these values called flags directly from IHP into Elm.

**And what's even cooler, we will also enable you to generate Haskell types to Elm without writing any decoders or encoders manually 😍**

- This is a **part 2** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)

## Starting out simple

Elm should not be used for everything in an IHP app. IHP gives you server-side rendering, easy authentication and a great framework for forms. Keeping that is good and improves your quality of life as a developer. 

If you are looking for pure Elm Single Page App with a JSON api, [haskell-servant](https://www.servant.dev/) is probably a more logical way to go.

**In IHP, use Elm only when you start to think "I really need Elm for this".** That will keep the complexity down and let you use Elm for what it's great for.

All this being said, the example in this tutorial is made extremely simple to make the process easier to follow.

## Continue from part one

If you haven't done [part 1](blog/ihp-with-elm) of this series, do so first.

**If you don't want to do that**, you could [clone the soruce](https://github.com/kodeFant/ihp-with-elm) and checkout to this tab to follow along:
```bash
g checkout tags/setup-elm-in-ihp -b setup-elm-in-ihp
```

Remember to do `npm install` before running the application.


## Create a Haskell type

To demonstrate how we can insert different datatypes into Elm, let's create a relatively complex database table.

Run `npm start` and go to [localhost:8001/Tables](http://localhost:8001/Tables).

Right click and select `Add Table` in the context menu. Name the table `books`.

**Just like this:**

![Elm not running](/images/archive/ihp-with-elm/create-books-table.gif)

Right click and add columns to the database until you have these exact fields:

![Elm not running](/images/archive/ihp-with-elm/books-table.png)

Try to match these fields excactly to avoid getting into a confusing situation later 🙂

To be guaranteed an excact copy of this table, you can also safely paste this snippet into the **Schema.sql** file.

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

When all the fields are filled in, press `Update DB`. This should update the database with the new table.

## Generate Controller and Views

Stay in the `localhost:8001` admin panel and select `Codegen` in the menu to the left.

Select `Controller`, name it `Books` and click `Preview` and click `Generate`.

**Like this:**

![Elm not running](/images/archive/ihp-with-elm/make-controller.gif)

You will now have generated all you need to view, update, create and delete books. Pretty cool!

Just a couple of small adjustments before we proceeed:

Let's just use a checkbox field for the `hasRead` value and a datepicker for the `publishedAt` value.

In both `New.hs` and `Edit.hs` in the `/Web/Controller/View/Books/` folder, replace these two fields:

```haskell
{{textField #hasRead}}
{{textField #publishedAt}}
```

to

```haskell
{{checkboxField #hasRead}}
{{dateField #publishedAt}}
```

Let's also take a short visit to the Books Controller `/Web/Controller/Books.hs` and make sure the nullable value `review` turns into `Nothing` if empty.

```haskell
buildBook book = book
    |> fill @["title","pageCount","hasRead","review","publishedAt"]
    |> emptyValueToNothing #review
```

Go to [http://localhost:8000/Books](http://localhost:8000/Books) to create a couple of Books with some varying values.

## Some small changes in the hsx templates

First, navigate to `Web/View/Layout.hs` and add the elm script at the **bottom** in the body tag.

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

It's important to have this script at the bottom and not at the top with the other scripts. It won't run otherwise.

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

## Install haskell-to-elm

`haskell-to-elm` will let us generate Elm types from Haskell types, including encoders and decoders.

In order to generate Elm types from IHP, add the `haskell-to-elm` package to **haskellDeps** in `default.nix`

```nix
  haskellDeps = p: with p; [
      ...
      haskell-to-elm
  ];
```

To update your local environment, close the server **(ctrl+c)** and run

```bash
nix-shell --run 'make -B .envrc'
```

Also add the required Elm packages required by `haskell-to-elm`. I recommend using the cli-tool [elm-json](https://github.com/zwilias/elm-json) to install elm packages.

```bash
elm-json install elm/json NoRedInk/elm-json-decode-pipeline elm-community/maybe-extra elm/time rtfeldman/elm-iso8601-date-strings
```

## Reduce boilerplate for Haskell-to-Elm types

Following these instructions will make it easier to add `haskell-to-elm` types later on.

Create a folder named `Lib` and make a new Haskell file:

```
mkdir Application/Lib
touch Application/Lib/DerivingViaElm.hs
```

Paste this code into `Application/Lib/DerivingViaElm.hs`.

```haskell
module Application.Lib.DerivingViaElm where

import IHP.Prelude
import qualified Data.Aeson as Aeson
import qualified Data.Text as Text
import qualified Generics.SOP as SOP
import GHC.Generics (Generic, Rep)
import qualified Language.Elm.Name as Name
import Language.Haskell.To.Elm

-- This reduces boilerplate when making Haskell types that are serializable to Elm
-- Derived from: https://github.com/folq/haskell-to-elm

newtype ElmType (name :: Symbol) a
  = ElmType a

instance
  (Generic a, Aeson.GToJSON Aeson.Zero (Rep a)) =>
  Aeson.ToJSON (ElmType name a)
  where
  toJSON (ElmType a) =
    Aeson.genericToJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = dropWhile (== '_')} a

instance
  (Generic a, Aeson.GFromJSON Aeson.Zero (Rep a)) =>
  Aeson.FromJSON (ElmType name a)
  where
  parseJSON =
    fmap ElmType . Aeson.genericParseJSON Aeson.defaultOptions {Aeson.fieldLabelModifier = dropWhile (== '_')}

instance
  (SOP.HasDatatypeInfo a, SOP.All2 HasElmType (SOP.Code a), KnownSymbol name) =>
  HasElmType (ElmType name a)
  where
  elmDefinition =
    Just
      $ deriveElmTypeDefinition @a defaultOptions {fieldLabelModifier = dropWhile (== '_')}
      $ fromString $ symbolVal $ Proxy @name

instance
  (SOP.HasDatatypeInfo a, HasElmType a, SOP.All2 (HasElmDecoder Aeson.Value) (SOP.Code a), HasElmType (ElmType name a), KnownSymbol name) =>
  HasElmDecoder Aeson.Value (ElmType name a)
  where
  elmDecoderDefinition =
    Just
      $ deriveElmJSONDecoder
        @a
        defaultOptions {fieldLabelModifier = dropWhile (== '_')}
        Aeson.defaultOptions {Aeson.fieldLabelModifier = dropWhile (== '_')}
      $ Name.Qualified moduleName $ lowerName <> "Decoder"
    where
      Name.Qualified moduleName name = fromString $ symbolVal $ Proxy @name
      lowerName = Text.toLower (Text.take 1 name) <> Text.drop 1 name

instance
  (SOP.HasDatatypeInfo a, HasElmType a, SOP.All2 (HasElmEncoder Aeson.Value) (SOP.Code a), HasElmType (ElmType name a), KnownSymbol name) =>
  HasElmEncoder Aeson.Value (ElmType name a)
  where
  elmEncoderDefinition =
    Just
      $ deriveElmJSONEncoder
        @a
        defaultOptions {fieldLabelModifier = dropWhile (== '_')}
        Aeson.defaultOptions {Aeson.fieldLabelModifier = dropWhile (== '_')}
      $ Name.Qualified moduleName $ lowerName <> "Encoder"
    where
      Name.Qualified moduleName name = fromString $ symbolVal $ Proxy @name
      lowerName = Text.toLower (Text.take 1 name) <> Text.drop 1 name


```

## Turn IHP types into JSON serializable types

Create the file where the elm-compatible types will live.

```
touch Web/JsonTypes.hs
```

In `Web/JsonTypes.hs` we will create types that can be directly serialized into both JSON and Elm decoders. For starters, we will make a `BookJSON` type and a function for creating it from the IHP generated `Book`.


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

This is some extra work, but you also get to control what fields that will be sent into Elm. And you get generic JSON serializing at the same time. 

Not all values are relevant all the time. And some values should not be shared through the API's and frontend, like password hashes and email adresses, so this is a good practice anyway.

## Make a widget entry-point

A logical place to write the entrypoints for the Elm widget is `Application/Helpers/View.hs` as functions exposed here are accessible in all view modules.

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

Not much code, but lots of power in here. Use the normal IHP type as an argument, and this widget will convert the type and encode the value for sending it to Elm.

Let's add this `bookWidget` t `/Web/View/Books/Show.hs`:

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

The value passed into the `data-flags` attribute is serialized and ready to be sent right through JavaScript and directly into Elm.

## Autogenerate types

Now it's time for the fun stuff. We need to go back to [http://localhost:8001](http://localhost:8001) and generate a script and select `Codegen` in the left menu and then `Script`. Type `GenerateElmTypes`, select `Preview` and then `Generate`. 

**Like this:**

![Elm not running](/images/archive/ihp-with-elm/generate-elm-script.gif)

IHP will have generated an executable script for you.

Fill in the export logic for generating Elm types in `/Application/Script/GenerateElmTypes.hs`:

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

Go to [localhost:8000/Books](http://localhost:8000/Books) and press `Show` on any book you have created. You should see where Elm starts and begins with the `<elm🌳>` tag. The Elm logic is handling every type as it was in Haskell, from `Bool` to `Maybe String` etc.

## Next up

We have created only one widget, but in the next post I will show you how to support an unlimited amount of widgets that will operate separately.

Most of the groundwork is done, so we can hit the ground running in the next post.