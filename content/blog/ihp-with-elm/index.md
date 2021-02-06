---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Part 1: How to setup IHP with Elm",
  "description": "Get Elm with hot reloading on top of IHP, the new framework that makes Haskell a cool kid in web dev.",
  "image": "images/article-covers/elm-in-ihp-part-1.jpg",
  "published": "2020-12-13",
  "draft": false,
  "slug": "ihp-with-elm",
  tags: [],
}
---

_This is **part 1** of the series [IHP with Elm](https://driftercode.com/blog/ihp-with-elm-series)_



[Elm](https://elm-lang.org/) was my gateway drug into type-safe functional programming. It's such a good tool for making robust frontends. Writing big projects in React and TypeScript honestly bums me out because of it.

I have always wanted have to have the equivalent type-safe joy on the backend like I have with Elm.

Now I have it all, with SSR included and an amazing developer experience 😍

**[IHP](https://ihp.digitallyinduced.com/) is a new web framework that has opened a wide door for the web development community to get into Haskell.** Like Rails and Laravel, it's great for quick prototyping, well documented and easy to use.

It even has the pipe operator (`|>`) included making it even more similar to the Elm syntax.

## Things I don't use Elm for in IHP

IHP gives you HTML templating (HSX) with pure functions, very similar to Elm. In that regard it's partially overlapping with Elm.

It can be a blurry line for beginners, so here are my recommendations for how to set those lines.

- Use HSX for **basic HTML**, even if it requires a couple of lines of JavaScript. I would for example write a basic hamburger menu in HSX/HTML.
- Use HSX for **forms**. Forms are pretty much always a bigger pain written in app code. If you have been living in the Single Page App world for a while, you will realize forms written in normal HTML are not that bad. IHP gives you a convenient way of writing forms with server-side validation.
- Elm is great for making **advanced custom form fields**
- Use Elm for the **advanced UI stuff** requiring heavy use of DOM manipulation. Elm shines in writing user interfaces with high complexity. If the lines of JavaScript are getting too many, turn to Elm!
- Do you want the content to have **SSR** for search engine optimization? Use HSX.

So unless you really want to write a full Single Page App, Elm should be used with restraint in IHP, for only specific supercharged parts of the site.

**Most sites are actually better off outputting just HTML and CSS.**

## Create a new IHP Project

If you haven't installed IHP already, make sure you do. [It's surprisingly easy to get going](https://ihp.digitallyinduced.com/Guide/installation.html).

After it's installed, you can now simply run this command:

```bash
ihp-new --elm ihp-with-elm
```

To verify the app is working, cd into the `ihp-with-elm` folder and run `./start`.

- **Read on to [part 2](blog/passing-flags-from-ihp-to-elm)** if you are interested in how you can send initial data from IHP and directly to Elm by writing as little JavaScript as possible.

## _Archived deprecated content_

_**NOTE:** This part of the series was formerly longer, but IHP has added official support for initializing Elm that is pretty much identical to part 1 of this series. 😀 I have archived the former content of this part into [this gist](https://gist.github.com/kodeFant/919f032de75c5bad40aa709183754a74). The gist can be useful if you want to implement Elm into an existing project._

_The only thing to note is that it doesn't remove dependencies you might not use like for example **jQuery**._