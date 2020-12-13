---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "How to setup IHP with Elm",
  "description": "Get Elm with hot reloading on top of IHP, the new framework that makes Haskell a cool kid in web dev.",
  "image": "images/article-covers/haskell-elm.png",
  "published": "2020-12-13",
  "draft": true,
  "slug": "things-i-dont-use-elm-for-in-ihp",
  tags: [],
}
---


IHP gives you HTML templating (HSX) with pure functions, very similar to Elm. In that regard it's partially overlapping with Elm.

It can be a blurry line for beginners, so here are my recommendations for how to set those lines.

- Use HSX for **basic HTML**, even if it requires a couple of lines of JavaScript. I would for example write a basic hamburger menu in HSX/HTML.
- Use HSX for **forms**. Forms are pretty much always a bigger pain written in app code. If you have been living in the Single Page App world for a while, you will realize forms written in normal HTML is not that bad. IHP gives you a convenient way of writing forms with server-side validation.
- Use Elm for the **advanced UI stuff** requiring heavy use of DOM manipulation. Elm shines in writing user interfaces with high complexity. If the lines of JavaScript are getting too many, turn to Elm!
- Do you want the content to have **SSR** for search engine optimization? Use HSX.

So unless you really want to write a full Single Page App, Elm should be used with restraint in IHP, for only specific supercharged parts of the site.

**Most sites are actually better off outputting just HTML and CSS.**

[Dill](https://dill.network), my first IHP app has no Single Page App functionality at all. Not even a bundler like Webpack or Parcel. It's pure Haskell templates basically written in HTML, CSS and a litte JavaScript. (There _are_ a couple of JS libraries included like Turbolinks)

## Next up

I want to take this application further in future posts showing you how to interact between IHP and Elm, and how use Elm within protected boundaries (requiring authentication). Stay tuned if these are topics that intrigue you 😊
