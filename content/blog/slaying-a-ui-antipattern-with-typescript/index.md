---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Slaying a UI antipattern with TypeScript and React",
  "description": "Fetch data like a knight in functional armor using a powerful Elm pattern.",
  "image": "/images/article-covers/anti-pattern.jpg",
  "published": "2020-03-26",
  "draft": false,
  "slug": "slaying-a-ui-antipattern-with-typescript"
}
---

Kris Jenkins made a great library in Elm called [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/). It makes data fetching more predictable and maintainable.

RemoteData is a nice data structure for external data. It returns one of of the following values, here shown in the Elm version:

```elm
type RemoteData err data
    = NotAsked
    | Loading
    | Failure err
    | Success data
```

With data like this, a developer is forced to handle the view for every case.

**No more postponing the loading and error views for "later".**

Here is an example of a view function in Elm returning something for every case. Ignoring any of them will prevent the app from compiling:

```elm
view : Model -> Html msg
view model =
  case model.blogPosts of
    NotAsked -> text "Initialising."

    Loading -> text "Loading."

    Failure err -> text ("Error: " ++ toString err)

    Success blogPosts -> postList blogPosts
```

Like many of us, you might be stuck with React and TypeScript at best in certain projects. Luckily, this pattern is just as easy to implement with TypeScript.

In this first tutorial about RemoteData, we are building it with no direct dependencies other than TypeScript and React.

**Throughout this series, we will make a TypeScript equivalent of this minimalistic [Elm blog fetcher](https://codesandbox.io/s/remotedata-elm-example-ktmt1).**

## The antipattern

[Kris Jenkins wrote a great article](http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html) explaining this antipattern of not handling views for every state of data fetching.

Very shortly outlined from the article, this is the antipattern we want to handle:

```javascript
var data = {
  loading: true,
  blogPosts: []
};
```

When the data is loading, the empty list of blogPosts shouldn't even be a possible state to access. [Impossible states should actually be impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8).

Free standing loading states could work fine in a very small app. As complexity grows, it will become a growing pain point.

It will be just another switch to remember to turn on and off at the right time.

## Begin with the data structure

Let's do a super simple example. 


Make a new React app with TypeScript and clear out the the entry file, which might be named **index.tsx**.

We already know the general data structure of this app. It's just displaying a list of blog posts.

We start with creating a **Post** type in addition to the **RemoteData** one.

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

The interesting part is of course the RemoteData type. It should be returned from a fetch function and this whole value should go directly into the state.

The **E** (error) and **D** (data) types are generic types that will be specified as we implement it.

## Fetch data

Then create a function for fetching the data.

```tsx
// Retrieve blog posts with the fetch returning a RemoteData value

async function fetchPosts(): Promise<RemoteData<Error, Post[]>> {
  try {
    const response = await fetch("https://jsonplaceholder.typicode.com/posts");

    if (!response.ok) throw await response.json();

    const data = await response.json();

    return { type: "SUCCESS", data: data };
  } catch (e) {
    return { type: "FAILURE", error: e };
  }
}
```

Throwing errors loose into the world is no good. It's better to catch them and return the data in an orderly fashion.

Pay attention to the return type in the function above.

```tsx
RemoteData<Error, Post[]>
```

The generic **E** and **D** types are now defined with specific types.

## The State

To avoid introducing too many conepts in this article, I'll just use the useState hook for setting the posts state. It's of course considered forbidden magic as it's not immutable.

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

The default value is the initial **NOT_ASKED** value.

The **getPosts** function should instantly set a loading state when initializing the data fetching. The fetchPosts function will then decide the final state in the RemoteData lifecycle.

## The view

Now to the final part: To be able to show the blog posts in the view, you make a case for every possible outcome of the RemoteData type.

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

In cases where data is fetched automatically on page load, you can return the same view on both **LOADING** and **NOT_ASKED**.

- **See the [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-77dci) for a complete example.**




## Next up

**In the [part 2](/blog/slaying-a-ui-antipattern-with-typescript-part-2), we are going to lay out the rendering of the RemoteData view a bit more elegantly than the switch statement.**

Here is a teaser:

```tsx
return foldRemoteData(
  posts,
  () => <FetchPosts getPosts={getPosts} />,
  () => <Loading />,
  (error) => <Failure error={error} />,
  (data) => <BlogPosts data={data} />
);
```

If you like this pattern, make it your own. Or if you are a regular JavaScript user, there are several resources showing you how to solve it without TypeScript. Here are some examples:

- [Slaying a UI Antipattern in React](https://medium.com/javascript-inside/slaying-a-ui-antipattern-in-fantasyland-907cbc322d2a)
- [Slaying a UI Antipattern with Flow](https://medium.com/@gcanti/slaying-a-ui-antipattern-with-flow-5eed0cfb627b)
