---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "100 days of Haskell, day 1",
  "description": "The intimidating power of Haskell shall be mine in 100 days.",
  "image": "images/article-covers/hundred-days-haskell.png",
  "published": "2020-08-20",
  "draft": false,
  "slug": "hundred-days-of-haskell",
  tags: [],
}
---

During the last couple of years, I have taught myself a fair bit of programming languages like JavaScript, PHP, TypeScript, Elm, Dart, Elixir and some Python and Java.

Elm, a language written in Haskell, has become my favorite language so far. It made me appreciate functional programming and strict static typing. I even found the quality of my JavaScript code improving (at least in my opinion 😄).

I recently learned Elixir and Phoenix for doing FP on the server and made a pet project with it. It was a great experience, but I still find myself missing the strict compiler guarantees. I tried the Elixir Dialyzer for typings. It's good, but it is not as bullet proof as Elm and Haskell types.

I could gladly continue writing apps in Elixir, but I would like to compare it with Haskell before I decide my favorite backend language.

_**By the way,** I am eagerly following [Gleam](https://gleam.run/), a statically typed functional language that compiles to Erlang. If you find it as interesting as I do, you could [sponsor it on Github](https://github.com/sponsors/lpil) to give the author time to develop it._

## Intimidating boredom

I am one of those programmers who have tried starting to learn Haskell a couple of times, but failed.

**Haskell feels intimidating, but I don't beliveve it really is that hard.**

I think the main reason I flee from it is that none of the learning resources captivate me. The coding tutorials are mostly teaching me to write small programs I have little interests in.

Making tic tac toe in the REPL is probably fun if you have all the free time in the world, but I want to make real applications, and I want to become productive as soon as possible. Some guides even do lots of examples with advanced non-practical math stuff. I'm just don't care about doing math exercises with Haskell. I think many web developers can relate.

With Elixir there are so many awesome resources teaching you how to build complex web services that are directly transferable to real-life projects.

## Inspired by the new "Haskell on Rails"

I was actively looking for a good opinionated "batteries included" web framework for Haskell before learning Elixir/Phoenix with no luck.

As soon as I was productive in Phoenix, I stumbled upon [Integrated Haskell Platform (IHP)](https://ihp.digitallyinduced.com/). IHP is a newly released opinionated MVC Web Framework similar to Phoenix and Ruby on Rails. It has even been battle tested professionally for a couple of years before it was released to the public.

I had a great time going through the [IHP tutorial](https://ihp.digitallyinduced.com/Guide/index.html), and it re-sparked my interest for Haskell. The tutorial guides you through making a working blog with comments quite easily.

Inspired by the project, I bought myself a new Haskell book. I think I already regret that buy 😄 It looks just as uninspiring as every other guide (no real web applications), but I might give it a try.

I will probably mainly use IHP to boost this Haskell challenge to make web stuff.

## One hour of Haskell a day

I believe continuity is the key to learning difficult things.

Fear of public humiliation is also a good motivator, and therefore **I make a public commitment to write Haskell code every day for 100 days and tweet about it**.

I had great success with my **#100DaysOfCode** challenge two years ago. I skilled fast and landed my current job shortly after. This contributed to cementing my strong passion for programming. Haskell seems like a perfect excuse to challenge myself again.

Some tracks I might pursue are:

- A basic Todo app in IHP. Boring, but good for doing the basics
- Rewriting the backend of my pet project app, [Dill](http://dill.network/), currently written with Hasura/NodeJS. I have actually rewritten 95% of it in Elixir/Phoenix (but not yet replaced the current tech). I am taking my time to make it the way I want, so I might rewrite it again in Haskell.
- Practicing language basics when needed
- Suggestions?

I will tweet about the challenge every day with the hashtags [#100DaysOfHaskell](https://twitter.com/hashtag/100daysOfHaskell?src=hashtag_click) and [#100DaysOfCode](https://twitter.com/search?q=%23100DaysOfCode&src=hashtag_click).

Feel free to [follow me on Twitter](https://twitter.com/larsparsfromage) if you are interested in my Haskell journey 😊
