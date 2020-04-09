---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Slaying a UI antipattern with TypeScript and React (part 3)",
  "description": "How to typecheck data from an external source.",
  "image": "/images/article-covers/damsel-in-distress.jpg",
  "published": "2020-04-24",
  "draft": true,
  "slug": "slaying-a-ui-antipattern-with-typescript-part-3"
}
---

In [part 1](/blog/slaying-a-ui-antipattern-with-typescript) and [part 2](/blog/slaying-a-ui-antipattern-with-typescript-part-2) of this series, we made sure all the relevant views for fetching data are present on the front end. All thanks to a very simple data structure originally made for Elm.

One thing we need to cover for the app to have the benefits of an Elm app is decoding. If you want to make a safe app, I think you will learn to love this.

## Why not validate the backend?

**We do server side validation on web forms. Why doesn't the frontend validate what comes in from the backend?**

Elm actually forces you to do that, and it contributes to eliminating pretty much all runtime exceptions. When something doesn't check out, it fails fast and loud.

TypeScript lacks this feature as it only typechecks what happens in the source code. 

Luckily, a library like **Purify** or **fp-ts** can give you these guarantees with little extra effort.

## Purify the chaos

In this series we will use [Purify](https://gigobyte.github.io/purify/). I prefer it because it's a simple library that gives us functional data structures and does it well. It accepts TypeScript for what it is instead of trying to force it to be Haskell or Scala.

[fp-ts](https://gcanti.github.io/fp-ts/) almost gives you Haskell or Scala in TypeScript. It's powerful, but harder to learn and the documentation is not beginner friendly.

I get all I need from Purify and a utility library like [Remeda](https://github.com/remeda/remeda) (a Ramda-like for TypeScript). They both have pretty nice and simple documentation so another developer can get up to speed on your code pretty fast. 

If you need something even more functional and safe, just take the leap of faith and move on to [Elm](https://elm-lang.org/) already. 

- Use the [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-part-2-hlu4v?file=/src/index.tsx) from the previous post as a starter code

## Make a decoder and turn it into an interface

In the initial code, we have an interface of the **Post** type looking like this:

```tsx
interface Post {
  id: string;
  title: string;
  body: string;
}
```

Delete it. **Wait, what?**

As mentioned, it does not help us in typechecking external data. And a puny TypeScript typeguard is too weak to withstand the chaos outside your source code. 


So let's install Purify

```bash
yarn install purify-ts
```

and import the needed dependencies from **Codec** in **index.ts**

```jsx
import {
  Codec,
  string,
  array,
  GetInterface,
  number
} from "purify-ts/Codec"
```

Did you delete the **Post interface** yet? If not, do it now!

Then define this constant:

```tsx
const Post = Codec.interface({
  id: string,
  title: string,
  body: string
})
```

This gives you the decoder. To get the TypeScript interface back, just add this line below it:

```tsx
type Post = GetInterface<typeof Post>
```

That type does the exact same job as the TypeScript interface we deleted earlier and the errors should be gone.

Yes, the const and the type are both named **Post**. No worries, there is no naming conflict. TypeScript is smart enough to understand when to use a type and when to use a value.

Also add these lines right below.

```jsx
const PostList = array(Post)
type PostList = GetInterface<typeof PostList>
```

Replace all occurences of **Array<Post>** with **PostList** in the code. That lets us also decode an array of posts.

## To the hard part

Now, we only need to modify the **fetchPosts** function a bit.

```tsx
async function fetchPosts(): Promise<RemoteData<Error, PostList>> {
  const response = await fetch("https://jsonplaceholder.typicode.com/posts");
  try {
    if (!response.ok) throw await response.json();
    const data = await response.json();
    const decodedData = PostList.decode(data)
      .either(
        (err) => { return ({ type: "FAILURE", error: Error(err) } as RemoteData<Error, PostList>) },
        (successData) => { return ({ type: "SUCCESS", data: successData } as RemoteData<Error, PostList>) }
      )

    return decodedData

  } catch (e) {
    return { type: "FAILURE", error: e };
  }
}
```

Most of this function is similar to the previous series, but in the **decodedData** constant, there is some functional stuff going on. Don't worry if you don't get it all at first.

The **PostList.decode** function takes in the uncertain **data** value from the outside and finds out if the types checks out. It returns an **Either** value which can return one of the two values:

A **Left** value with an error message or a **Right** value with the correct and verified **PostList** value.

To turn these values into RemoteData values, we use the **.either** method to map both the left and right value into RemoteData values.

Now, you should have decoding enabled.

## Let's put it to the test

By running your code or this [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-part-3-9zrbd?file=/src/index.tsx) you can see the result:

![Screenshot of friendly error message](/images/archive/failing-decoder.jpg)

What 😱 Who wrote that nice error message??

The decoder of course, and it gives you a helpful error message pretty much like Elm would in this situation. 

**I have been deceiving you all along.** It turns out the **id** value never was a string after all, even though we declared it as a string already in the very first part of this series.

TypeScript didn't help you catch that. Purify did.

Let's turn the **id** into a number in the Codec, and we should be all good:

```tsx
const Post = Codec.interface({
  id: number,
  title: string,
  body: string
})
```

## What remains

Another improvement to resemble Elm is immutable state. A simple way is to use the [useImmer hook](https://github.com/immerjs/use-immer) instead of useState.

For more advanced state management, I think [Easy Peasy](https://easy-peasy.now.sh/) is a great alternative built on Redux, but with a simpler API. It's immutable with Immer by default. Another alternative is [xState](https://github.com/davidkpiano/xstate) for being very explicit about possible states.

These tools have great documentation and large communities, so I won't cover the usage of them in this series.

But to get the full benefits and power of Elm, it's best to use Elm. Try it out on a small component in your app and decide wether you like it.

## The End
