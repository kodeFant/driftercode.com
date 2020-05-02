---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "How to use Elm as a state manager for React",
  "description": "Create an interface for sending messages between the two technologies.",
  "image": "images/article-covers/elm-in-react-state.png",
  "published": "2020-05-21",
  "draft": true,
  "slug": "elm-in-react-state-library",
  tags: [],
}
---

I think one of the hardest things to learn in Elm is dealing with incoming data and decoding it. 

There is a certain amount of boilerplate to it, but as most Elm developers, we embrace the boilerplate as the rewards outweigh the cost. 


As Elm creator Evan Czaplicki is often quoted by: [**There are worse things than being explicit**](https://twitter.com/czaplic/status/928359289135046656).

Libraries that reduce boilerplate often hits some annoying limitations when we meet the edge cases.

The upside to the little extra initial setup is that you get understandable error messages instead of crazy runtime errors when the incoming data structure does not match the expectations. Refactoring also becomes much easier.

## Using Elm as a intermediary Redux replacer

[Integrating Elm in JavaScript](blog/elm-in-react-with-parcel) is simple enough, and the Elm runtime is very lightweight. You could therefore use Elm as a state machine and React as as view renderer in your app as a permanent solution.

But I would rather see Elm consuming the whole app as the ultimate goal. That would shave off the considerable [bundle size of React](https://elm-lang.org/news/small-assets-without-the-headache) and ultimately you could delete most of the decoders we are about to create. 

