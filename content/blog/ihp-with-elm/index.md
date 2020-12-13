---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "How to setup IHP with Elm",
  "description": "Get Elm with hot reloading on top of IHP, the new framework that makes Haskell a cool kid in web dev.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-13",
  "draft": false,
  "slug": "ihp-with-elm",
  tags: [],
}
---

Elm was my gateway drug in to type-safe functional programming. It's such a good tool for making robust frontends. Writing big projects in React and TypeScript honestly bums me out because of it.

I have always wanted have to have the equivalent type-safe joy on the backend like I have with Elm.

Now I have it all, with SSR included and an amazing developer experience 😍

**IHP is a new web framework that has opened a wide door for the web development community to get into Haskell.** Like Rails and Laravel, it's great for quick prototyping, well documented and easy to use.

It even has the pipe operator (`|>`) included making it even more similar to the Elm syntax.

**Disclaimer: This tutorial should work for Mac and Linux. If you develop on Windows, it will might not work without some tweaks on your own**

## Thing I don't use Elm for in IHP

IHP gives you HTML templating (HSX) with pure functions, very similar to Elm. In that regard it's partially overlapping with Elm.

It can be a blurry line for beginners, so here are my recommendations for how to set those lines.

- Use HSX for **basic HTML**, even if it requires a couple of lines of JavaScript. I would for example write a basic hamburger menu in HSX/HTML.
- Use HSX for **forms**. Forms are pretty much always a bigger pain written in app code. If you have been living in the Single Page App world for a while, you will realize forms written in normal HTML is not that bad. IHP gives you a convenient way of writing forms with server-side validation.
- Use Elm for the **advanced UI stuff** requiring heavy use of DOM manipulation. Elm shines in writing user interfaces with high complexity. If the lines of JavaScript are getting too many, turn to Elm!
- Do you want the content to have **SSR** for search engine optimization? Use HSX.

So unless you really want to write a full Single Page App, Elm should be used with restraint in IHP, for only specific supercharged parts of the site.

**Most sites are actually better off outputting just HTML and CSS.**

[Dill](https://dill.network), my first IHP app has no Single Page App functionality at all. Not even a bundler like Webpack or Parcel. It's pure Haskell templates basically written in HTML, CSS and a litte JavaScript. (There _are_ a couple of JS libraries included like Turbolinks)

## Create a new IHP Project

If you haven't installed IHP already, make sure you do. [It's surprisingly easy to get going](https://ihp.digitallyinduced.com/Guide/installation.html).

Start a fresh IHP project for this tutorial. Luckily, it couldn't be easier as soon as IHP is properly installed.

```bash
ihp-new ihp-with-elm
```

To verify the app is working, cd into the `ihp-with-elm` folder and run `./start`.

## Update .gitignore

Let's update `.gitignore` as soon as possible to avoid pushing unwanted stuff into git.

```bash
.cache
elm-stuff
static/elm
```

## Initialize node and elm

In your `default.nix` file in the root folder, add `Node.js` and `elm` to `otherDeps`:

```nix
otherDeps = p: with p; [
    # Native dependencies, e.g. imagemagick
    nodejs elmPackages.elm
];
```

To update your local environment, close the server **(ctrl+c)** and run

```bash
nix-shell --run 'make -B .envrc'
```

Then initialize the Node project and elm at the project root.

```bash
npm init -y
elm init
```

For this tutorial, we will rename the `src` folder that elm generated into `elm`.

```bash
mv src elm
```

Set the source directories folder to **"elm"** in `elm.json`.

```json
{
  "type": "application",
  "source-directories": ["elm"],
  ...
```

## Getting the Haskell template ready

Let's start writing the Elm entrypoint into the Haskel template.

Go to `Web/View/Static/Welcome.hs` and replace all the html inside the HSX in `VelcomeView`:

```hs
instance View WelcomeView where
    html WelcomeView = [hsx|
        <h1>User notes</h1>
        <div class="elm">Elm app not loaded 💩</div>
        <script src="elm/index.js"></script>
    |]
```

If your IHP app is not already running, run it with `./start` and see the output on `localhost:8000`.

![Elm not running](/images/archive/ihp-with-elm/elm-not-loaded.jpg)

As you see, Elm has not been loaded, because we naturally haven't written any Elm code yet. Let's close the server **(ctrl+c)** and do that now.

## Setting up Elm

Install `node-elm-compiler` for compiling and `elm-hot` for hot reloading in development. `parcel-bundler` is a "zero config" JavaScript bundler.

```bash
npm install node-elm-compiler parcel-bundler
npm install elm-hot --save-dev
```

You could do it all without a bundler like Parcel. IHP discourages bundlers, and I agree that it's not always necessary.

Still, Parcel provides valuable niceties like tight production minification and good hot reloading in development, so I prefer to use Parcel when things get a bit more advanced.

Create `index.js` and `Main.elm` in the elm folder:

```bash
touch elm/index.js elm/Main.elm
```

The `elm/index.js` should look like this to initialize the Elm file.

```javascript
import { Elm } from "./Main.elm";

Elm.Main.init({
  node: document.querySelector(".elm"),
});
```

Finally, lets' insert the code for `elm/Main.elm`!

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

Add the `start` and `build` scripts into the `package.json`:

```json
  "scripts": {
    ...
    "start": "parcel watch elm/index.js --out-dir static/elm",
    "build": "parcel build elm/index.js --out-dir static/elm"
  },
```

You should now be able to run `npm start` in one terminal and `./start` in another terminal.

There you should have it! Elm in Haskell with hot reloading and the Elm debugger is ready for you in the bottom right corner. Beautiful!

![Elm running](/images/archive/ihp-with-elm/elm-loaded.jpg)

## Build for production

When pushing your IHP app to production, you need to make sure that it builds the Elm applications.

Go to the `Makefile` in the project root and append this line to the list of `JS_FILES`:

```makefile
JS_FILES += static/elm/index.js
```

And put this at the bottom of the Makefile.

```makefile
static/elm/index.js:
	NODE_ENV=production npm ci
	NODE_ENV=production npm run build
```

It should now be ready to ship to production for example to IHP Cloud.

For a complete overview of what has been done, see the [diff on my demo-repo](https://github.com/kodeFant/ihp-with-elm/commit/485726d51b0c167e27e660d9696f0d289378314a).

## Bonus: Run IHP and the frontend in one command

Running two commands to start up the service can be difficult for a very lazy developer.

`concurrently` is a tool that lets you spawn and kill multiple commands as one.

Install it as a developer dependency through npm:

```bash
npm install concurrently --save-dev
```

Then replace the `start` script in `package.json` and add accordingly:

```json
  "scripts": {
    ...
    "run-dev-elm": "parcel watch elm/index.js --out-dir static/elm",
    "run-dev-ihp": "./start",
    "start": "concurrently --raw \"npm:run-dev-*\"",
    ...
  },
```

With that you can now run both the IHP app and the JavaScript simultaneously with this single command.

```bash
npm start
```

And quit with **(ctrl+c)** as always.

## Next up

I want to take this application further in future posts showing you how to interact between IHP and Elm, and how use Elm within protected boundaries (requiring authentication). Stay tuned if these are topics that intrigue you 😊
