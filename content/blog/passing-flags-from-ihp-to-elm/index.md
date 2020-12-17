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

Right click and select `Add Table` in the context menu. Name the table `companies`.

Image

Right click and add columns to the database until you have these exact fields:

Image

Try to match these fields excactly to avoid getting into a confusing situation later :)

You can double check the `Schema.sql` file to ensure the table schema looks like this.

```bash
-- Your database schema. Use the Schema Designer at http://localhost:8001/ to add some tables.
CREATE TABLE companies (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    employees INT NOT NULL,
    is_public BOOLEAN DEFAULT false NOT NULL,
    slogan TEXT DEFAULT NULL,
    founded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

```

When all the fields are filled in, press `Update DB`. This should update the database.

## Generate Controller and Views

Stay in the `localhost:8001` admin panel and select `Codegen` in the menu to the left.

Select `Controller`, name it `Companies` and click `Preview` and click `Generate`.

You will now have generated all you need to view, update, create and delete companies. Pretty cool!

Just a couple of small adjustments before we proceeed:

Let's just make a checkbox field for the boolean value.

In both `New.hs` and `Edit.hs` in the `/Web/Controller/View/Companies/` folder, replace this

```haskell
{{textField #isPublic}}
```

to

```haskell
{{checkboxField #isPublic}}
```

Let's also take a short visit to the Controller at `/Web/Controller/Companies.hs` and add let's make sure that the nullable type is null when the field is empty so we get a real Maybe.

```haskell
buildCompany company = company
    |> fill @["name","employees","isPublic","slogan"]
    |> emptyValueToNothing #slogan
```

Go to [http://localhost:8000/Companies](http://localhost:8000/Companies) to create a couple of Companies with some varying values.

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
touch Application/Lib/DerivingVia.hs
```

In `Application/Elm/DerivingVia.hs`, we are just inserting some logic for reducing boilerplate to `haskell-to-elm`. Just pasting in this gist should help. You can treat this like a library addition and you won't be touching it apart from importing it into the next file we are creating.

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

data CompanyJSON = CompanyJSON
  { name :: Text
  , employees :: Int
  , isPublic :: Bool
  , slogan :: Maybe Text
  , foundedAt :: UTCTime
  } deriving (Generic, SOP.Generic, SOP.HasDatatypeInfo)
    deriving (Aeson.ToJSON, Aeson.FromJSON, HasElmType, HasElmDecoder Aeson.Value, HasElmEncoder Aeson.Value) 
    via ElmType "Api.Generated.Company" CompanyJSON

companyToJSON :: (?context :: ControllerContext) => Company -> CompanyJSON
companyToJSON company =
    CompanyJSON {
        name = get #name company,
        employees = get #employees company,
        isPublic = get #isPublic company,
        slogan = get #slogan company,
        foundedAt = get #foundedAt company
    }
```

## Make a widget entry-point

A logical place to write the entrypoints for the Elm widget entrypoints is `Application/Helpers/View.hs`

```haskell
module Application.Helper.View (
    -- To use the built in login:
    -- module IHP.LoginSupport.Helper.View
    companyCardWidget
) where

-- Here you can add functions which are available in all your views
import IHP.ViewPrelude
import Generated.Types
import Data.ByteString.Lazy as BLS
import Data.Aeson
import Web.JsonTypes

-- To use the built in login:
-- import IHP.LoginSupport.Helper.View

companyCardWidget :: Company -> Html
companyCardWidget company = [hsx|
    <div data-type={widgetName} data-flags={flags} class="elm"></div>
|]
    where
        widgetName :: BLS.ByteString = "CompanyCard"
        flags :: BLS.ByteString = encode $ companyToJSON company
```

Not much code, but lots of power in here. The `flags` variable takes the `Company`, converts it to a CompanyJson type and encodes it to a JSON string.

Now we need to jump to the JavaScript file and do some minor tweaks.

```tsx
import { Elm } from "./Main.elm";

const node = document.querySelector(".elm");
const flags = JSON.parse(node.dataset.flags) ?? null;

Elm.Main.init({
  node,
  flags,
});
```

The value passed into the `data-flags` attribute is serialized and ready to be shot right through JavaScript and directly into Elm. No need for TypeScript here.

## Autogenerate types

Now it's time for the fun stuff. We need to go back to [http://localhost:8001](http://localhost:8001) and generate a script and select `Codegen` in the left menu and then `Script`. Type `GenerateElmTypes`, select `Preview` and then `Generate`.

IHP will have generated an executable script for you.

Let's write the generation script for exporing the CompanyJSON type.

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
                        jsonDefinitions @CompanyJSON

        modules = Pretty.modules definitions

    Directory.createDirectoryIfMissing False "elm/Api"

    forM_ (HashMap.toList modules) $ \(_moduleName, contents) ->
        writeFile "elm/Api/Generated.elm" (show contents)
```

Voila! If everything has gone well so far, you should have a file named `elm/Api/Generated.elm`. Inspect it with great joy. You didn't need to write those decoders.

## Write some Elm

Let's finish up this tutorial by rewriting the Main.elm to decode the flags and use the Haskell model.

```elm
module Main exposing (main)

import Api.Generated exposing (Company, companyDecoder)
import Browser
import Html exposing (Html, div, h1, h2, p, pre, text)
import Json.Decode as D


type Model
    = CompanyCard Company
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

        CompanyCard company ->
            companyCardView company


errorView : String -> Html msg
errorView errorMsg =
    pre [] [ text "Widget Error: ", text errorMsg ]


companyCardView : Company -> Html msg
companyCardView company =
    div []
        [ h2 [] [ text company.name ]
        , p []
            [ text "Employees: "
            , company.employees |> String.fromInt |> text
            ]
        , p [] [ text "Is public? ", showYesOrNo company.isPublic ]
        , p [] [ showSlogan company.slogan ]
        ]


showYesOrNo : Bool -> Html msg
showYesOrNo bool =
    if bool == True then
        text "Yes"

    else
        text "No"


showSlogan : Maybe String -> Html msg
showSlogan maybeSlogan =
    case maybeSlogan of
        Just slogan ->
            text ("Slogan: " ++ slogan)

        Nothing ->
            text "There is no slogan :("


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
    ( case D.decodeValue companyDecoder flags of
        Ok model ->
            CompanyCard model

        Err error ->
            ErrorModel (D.errorToString error)
    , Cmd.none
    )
```