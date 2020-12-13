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

Elm was my gateway drug in to type-safe functional programming. It's such a good tool for writing a robust frontend that writing big projects in React makes me sad and bitter.

I have always wanted have to have the equivalent type-safe joy on the backend like I have with Elm. Now I have it all, with SSR included!

IHP is a new web framework that has opened a large gate for Haskell into the web development community. It's great for quick prototyping, well documented and easy to use. It even has the pipe operator `|>` included.

## Thing I don't use Elm for in IHP

IHP gives you HTML templating (HSX) with pure functions, very similar to Elm. In that regard it's partially overlapping with Elm. It can be a blurry line for beginners, but here are my recommendations for how to set those lines.

- Use HSX for **basic HTML**, even if it requires a couple of lines of JavaScript. I would for example write a basic hamburger menu in HSX/HTML.
- Use HSX for **forms**. Forms are pretty much always a bigger pain written in app technology. If you have been living in the Single Page App world for a while, you will realize forms written in HTML are not that bad. IHP gives you a convenient way of writing forms with server-side validation.
- Use Elm for the **advanced UI stuff** requiring heavy use of DOM manipulation. Elm shines in writing advanced user interefaces. If it's complex to write it HTML and a few lines of JS, Elm is the answer.
- Does the content need **SSR** for SEO purposes? Use HSX.

So unless you really want to write a full Single Page App, Elm should be used with restraint in IHP, for only specific supercharged elements.

Most sites are actually better off consiting of basically only HTML and CSS.

[Dill](https://dill.network), my first IHP app has no SPA tech at all. Not even a bundler like Webpack or Parcel. It's pure Haskell templates basically written in HTML, CSS and a litte JavaScript.

## Create a new IHP Project

If you haven't used IHP before, make sure you have it installed. [It's surprisingly easy to get going](https://ihp.digitallyinduced.com/Guide/installation.html).

Start a fresh IHP project for this tutorial. Luckily, it couldn't be easier as soon as IHP is properly installed.

```bash
ihp-new ihp-with-elm
```

To verify the app is working, `cd ihp-with-elm` and run `./start`.

## Update .gitignore

Let's update `.gitignore` as soon as possible to avoid pushing unwanted stuff into git.

```bash
.cache
elm-stuff
static/packages
```

## Install Node

In your `default.nix` file in the root folder, add `NodeJS` and `elm` to `otherDeps`:

```nix
otherDeps = p: with p; [
    # Native dependencies, e.g. imagemagick
    nodejs elmPackages.elm
];
```

To update your local environment, run

```bash
nix-shell --run 'make -B .envrc'
```

Then initialize the Node project and elm in the root folder

```bash
npm init -y
elm init
```

Set the source directories folder to "elm" which will be where we store the application logic soon.

```json
{
  "type": "application",
  "source-directories": ["elm"],
  ...
```

## Getting the Haskell template ready

Let's start writing the Elm entrypoint into the Haskel template.

Go to `Web/View/Static/Welcome.hs` and remove all the html inside the `VelcomeView` and write it into this:

```hs
instance View WelcomeView where
    html WelcomeView = [hsx|
        <h1>User notes</h1>
        <div class="elm">Elm app not loaded 💩</div>
        <script src="elm.js"></script>
    |]
```

If your IHP app is not already running, start it with `./start` and see the output on `localhost:8000`.

As you see, Elm has not been loaded, because we haven't written any Elm yet. Let's do that now.

## Making the Elm widget

Create a new folder named elm and some source files.

In short, do this:

```bash
mkdir elm
cd elm
touch index.js Main.elm
```

Install `node-elm-compiler` for compiling and `elm-hot` for hot reloading in development. Parcel is a "zero config" javascript bundler doing minification. You could use the elm-cli alone, but I find Parcel provides valuable niceties like good production minification and good hot reloading.

```
npm install node-elm-compiler parcel-bundler
npm install elm-hot --save-dev
```

Add the `start` and `build` scripts into the `package.json`:

```json
  "scripts": {
    "start": "parcel watch index.js --out-dir ../../static/elm",
    "build": "parcel build index.js --out-dir ../../static/elm"
  },
```

The `index.js` initializes elm on elements with.

```javascript
import { Elm } from "./Main.elm";

Elm.Main.init({
  node: document.querySelector(".elm"),
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

When pushing your IHP app to production, you need to make sure that it builds the Elm applications.

Go to the `Makefile` in the project root and append this line to the list of `JS_FILES`:

```makefile
JS_FILES += static/elm/index.js
```

And put this at the bottom of the file.

```makefile
static/elm/index.js:
	NODE_ENV=production npm run bootstrap
	NODE_ENV=production npm run build
```

**Make requires tab characters instead of 4 spaces in the second line. Make sure you’re using a tab character when pasting this into the file**

It should now be ready to ship to for example IHP Cloud.
