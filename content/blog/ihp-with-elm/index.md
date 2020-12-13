---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "How to use Elm with IHP",
  "description": "Get Elm with hot reloading on top of an easy to use Haskell framework.",
  "image": "images/article-covers/hundred-days-haskell.png",
  "published": "2020-12-13",
  "draft": true,
  "slug": "ihp-with-elm",
  tags: [],
}
---


## Create a new IHP Project

If you haven't used IHP before, make sure you have it installed. [It's surprisingly easy to install](https://ihp.digitallyinduced.com/Guide/installation.html).

Start a fresh IHP project for this one. Luckily, it couldn't be easier as soon as it's properly installed.

```
ihp-new ihp-with-elm
```

To verify the app is working, `cd ihp-with-elm` and run `./start`.

## Install Node

In your `default.nix` file in the root folder, add `NodeJS` to `otherDeps`:

```nix
otherDeps = p: with p; [
    # Native dependencies, e.g. imagemagick
    nodejs
];
```

To update your local environment, run

```bash
nix-shell --run 'make -B .envrc'
```

Then initialize the Node project in the root folder

```
npm init -y
```

## Setup lerna

Installing lerna for managing multiple front end packages is not a necessity, but the reason I do it is because it doesn't really make sense to make a full Single Page App architecture inside a Multi Page App in my opinion. An SPA is headless by nature.

I use the templating from Haskell as much as possible and make Elm elements for specific parts of the app requiring extra interactivity. Writing http operations into an app component is often a waste of time when you can insert data directly into HTML and render it directly from the server.

With Lerna, I can easily manage several widgets doing far different jobs without being dependent on eachother.

Setting up lerna is luckily simple enough:

```bash
npm install lerna

```

Then initialize it to create a `lerna.json` file and a packages directory.

```bash
npx lerna init
```

In the root `package.json` file, add these scripts:

```json
"scripts": {
    ... 
    "bootstrap": "npm install && lerna run bootstrap",
    "start": "lerna run start --stream",
    "build": "lerna run build --stream"
},
```

That is really all for setting up lerna. The `bootstrap` script is nice for installing all necessary dependencies. `start` is for running all packages simultaneously with hot reloading in development. `build` is for building an optimized, minified build for every package.

## Getting the Haskell template ready

Let's start with the Haskell template where everything will start.

Go to `Web/View/Static/Welcome.hs` and remove all the html inside the `VelcomeView` and write it into this:

```hs
instance View WelcomeView where
    html WelcomeView = [hsx|
        <h1>User notes</h1>
        <div id="user-notes">Elm app not loaded 💩</div>
        <script src="packages/user-notes/index.js"></script>
    |]
```

If your IHP app is not already running, start it with `./start` and see the output on `localhost:8000`.

As you see, Elm has not been loaded, because we haven't written any Elm yet. Let's do that now.

## Making the Elm widget

Create a new package folder, initiate it as it's own node project and create the necessary source files.

```
mkdir packages/user-notes
cd packages/user-notes
touch index.js Main.elm
npm init -y
```

Install `node-elm-compiler` for compiling and `elm-hot` for hot reloading in development. Parcel is a "zero config" javascript bundler doing minification. You could use the elm-cli alone, but I find Parcel provides some niceties like good production minification and good hot reloading functionality.

```
npm install node-elm-compiler parcel-bundler
npm install elm-hot --save-dev
```

Add the `start` and `build` scripts into the **user-notes** `package.json`:

```json
  "scripts": {
    "start": "parcel watch index.js --out-dir ../../static/packages/user-notes",
    "build": "parcel build index.js --out-dir ../../static/packages/user-notes"
  },
```

The `index.js` initializes the Elm file into the `user-notes` id in the html.

```javascript
import { Elm } from "./Main.elm";

Elm.Main.init({
  node: document.querySelector("#user-notes"),
});
```

Finally, lets' insert some Elm into `Main.elm`!

```elm

module Main exposing (main)

import Browser
import Html exposing (Html, p, text)


type alias Model =
    {}


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
    p [] [ text "Hello, Elm 🌳🚀" ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( {}
    , Cmd.none
    )
```

You should now be able to cd back into the root of the project and run `npm start` in one terminal and `./start` in another terminal.

There you should have it! Elm in IHP with hot reloading and the Elm debugger. Beautiful!

## Build for production

When pushing you IHP app to production, you need to make sure that it builds the Elm applications.

Go to the `Makefile` in the project root and append this line to the list of `JS_FILES`:

```Makefile
JS_FILES += static/packages/user-notes/index.js
```

and the build script at the bottom of the Makefile

```Makefile
static/packages/user-notes/index.js:
	NODE_ENV=production npm ci
	NODE_ENV=production npm build
```

It should now be ready to ship to for example IHP Cloud.
