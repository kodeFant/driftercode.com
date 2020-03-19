---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Slaying a UI antipattern with TypeScript and React",
  "description": "Fetch data like a knight in functional armor using a powerful Elm pattern.",
  "image": "/images/article-covers/anti-pattern.jpg",
  "published": "2020-03-19",
  "draft": true,
}
---

Kris Jenkins made this great library in Elm called [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/) which makes data fetching more predictable and maintainable.

It basically creates a data structure for external data into four possible value types.

```elm
type RemoteData err data
    = NotAsked
    | Loading
    | Failure err
    | Success data
```

When rendering the UI, the developer will have to specify a view for all of those four cases. This forces the developer not to postpone making all the necessary views, like a loading screen when no data is fetched.

Here is a very simplified example of a view function returning something for every case.

```elm
view : Model -> Html msg
view model =
  case model.blogPosts of
    NotAsked -> text "Initialising."

    Loading -> text "Loading."

    Failure err -> text ("Error: " ++ toString err)

    Success blogPosts -> postList blogPosts
```

Like what you see? Consider [trying out Elm](https://elm-lang.org/) on your next frontend project.

Like many of us, you might be stuck with React and TypeScript at best in certain projects. Luckily, there are ways to utilize this pattern also in TypeScript.

In this tutorial, we are doing it with nothing more than TypeScript and React, but I might revisit it with a library like [fp-ts](https://gcanti.github.io/fp-ts/) later.

## The antipattern

[Kris Jenkins has written a great article](http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html) explaining the antipattern we are "slaying".

Very shortly outlined from the article, this is the antipattern we want to handle:

```javascript
var data = {
  loading: true,
  blogPosts: []
};
```

When the data is loading, the empty list shouldn't even be a possible state to access. [Impossible states should actually be impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8).

Free standing loading states could work fine in a very small app. As complexity grows, it will become a growing pain point.

## Begin with the data structure

Make a new React app with TypeScript and clear out the the entry file, which might be named **index.tsx**.

Make it look like this:

```tsx
import React, { useState } from "react";
import ReactDOM from "react-dom";

// TYPES

type RemoteData<E, D> =
  | { type: "NOT_ASKED" }
  | { type: "LOADING" }
  | { type: "FAILURE"; error: E }
  | { type: "SUCCESS"; data: D };

interface Post {
  id: string;
  title: string;
  body: string;
}

// VIEW

function Main(): JSX.Element {
  return <div>Hello World</div>;
}

ReactDOM.render(
  <div style={{ textAlign: "center" }}>
    <h1>Lorem Ipsum blog</h1>
    <Main />
  </div>,
  document.getElementById("root")
);
```

The interesting part is of course the RemoteData type. It should be returned from a fetch function and this whole value should go directly into the state. The **E** (error) and **D** (data) are generic types that will be more specific types when we implement it.

## Fetch data

Then insert a fetch function:

```tsx
// Retrieve blog posts with the fetch returning a RemoteData value

async function fetchPosts(): Promise<RemoteData<Error, Post[]>> {
  const response = await fetch("https://jsonplaceholder.typicode.com/posts");
  try {
    if (!response.ok) throw await response.json();
    const data = await response.json();
    return { type: "SUCCESS", data: data };
  } catch (e) {
    return { type: "FAILURE", error: e };
  }
}

// Main Component
```

Pay attention to the return type of the promise

```tsx
RemoteData<Error, Post[]>
```

This sets the data structure on the data fetching, the error is an **Error** type and the expected data is an array of Post.

## The State

To avoid introducing too many conepts, I'll just just the useState hook for setting the posts state.

```tsx
function Main(): JSX.Element {
  const [posts, setPosts] = useState<RemoteData<Error, Post[]>>({
    type: "NOT_ASKED"
  });

  const getPosts = () => {
    setPosts({ type: "LOADING" });
    fetchPosts().then(remoteData => setPosts(remoteData));
  };

  return <div>Hello World</div>;
}
```

I'm setting the same RemoteData type as in the fetch function, and the default value is the initial **NotAsked** value.

The getPosts function instantly sets a loading state, and then lets the fetchPosts decide the final state in the RemoteData lifecycle.

## The view

Now to the final part: To be able to show the blog posts in the view, you make a case for every patterns of the RemoteData type.

The main function will look like this:

```tsx
function Main(): JSX.Element {
  const [posts, setPosts] = useState<RemoteData<Error, Post[]>>({
    type: "NOT_ASKED"
  });

  const getPosts = () => {
    setPosts({ type: "LOADING" });
    fetchPosts().then(remoteData => setPosts(remoteData));
  };

  switch (posts.type) {
    case "NOT_ASKED":
      return (
        <div style={{ textAlign: "center" }}>
          <div>Not asked for posts yet</div>
          <button onClick={getPosts}>Fetch Posts</button>
        </div>
      );
    case "LOADING":
      return <div>Loading</div>;
    case "FAILURE":
      return <div>Something went wrong 😨</div>;
    case "SUCCESS":
      return (
        <div>
          {posts.data.map(post => (
            <article
              key={post.id}
              style={{
                border: "1px solid darkgray",
                margin: "1rem",
                padding: "1rem"
              }}
            >
              <h2>{post.title}</h2>
              <div dangerouslySetInnerHTML={{ __html: post.body }}></div>
            </article>
          ))}
        </div>
      );
  }
}
```

In cases where data is fetched automatically on page load, you can return the same view on both **LOADING** on **NOT_ASKED**.

See the [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-77dci) for a complete example.
