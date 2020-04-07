---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Slaying a UI antipattern with TypeScript and React (part 2)",
  "description": "This time we are folding data based on external data in a neat way.",
  "image": "/images/article-covers/slay-dragon.jpg",
  "published": "2020-04-10",
  "draft": true,
  "slug": "slaying-a-ui-antipattern-with-typescript-part-2"
}
---

In my [previous post](/blog/slaying-a-ui-antipattern-with-typescript), I promised to build on the RemoteData type based on a popular Elm pattern. Read it first to understand the **why** and the **wtf** of it. 

**Use the code from the [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-77dci) from the previous post as a starter code.**

What we are doing today is making the switch statement in **Main** into a thing of functional beauty.

```tsx
return foldRemoteData(
  () => <FetchPosts getPosts={getPosts} />,
  () => <Loading />,
  (error: Error) => <Failure error={error} />,
  (data: Post[]) => <BlogPosts data={data} />
)(posts);
```

What it does is simply make a less verbose version of the switch statement rendering all the relevant views in an intuitive order.

We can first do an easy refactor and split out the views into simple functions.

```tsx
function FetchPosts({ getPosts }: { getPosts: () => void }) {
  return (
    <div style={{ textAlign: "center" }}>
      <div>Not asked for posts yet</div>
      <button onClick={getPosts}>Fetch Posts</button>
    </div>
  );
}

function Loading() {
  return <div>Loading</div>;
}

function Failure({ error }: { error: Error }) {
  return <div>Error: {error.message}</div>;
}

function BlogPosts({ data }: { data: Post[] }) {
  return (
    <div>
      {data.map(post => (
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
```

## The implementation

Let us dive in and make the function. This fold function is a general function for all RemoteData queries.

```tsx
function foldRemoteData<R, E, D>(
  notAsked: () => R,
  loading: () => R,
  failure: (error: E) => R,
  success: (data: D) => R
): (data: RemoteData<E, D>) => R {
  return (remote: RemoteData<E, D>) => {
    switch (remoteData.type) {
      case "NOT_ASKED":
        return notAsked();
      case "LOADING":
        return loading();
      case "FAILURE":
        return failure(remote.error);
      case "SUCCESS":
        return success(remote.data);
    }
  };
}
```

The function is heavily based on [gcantis Flow port of RemoteData](https://medium.com/@gcanti/slaying-a-ui-antipattern-with-flow-5eed0cfb627b). I made it a bit more general.

What you see is a **higher order function**. Don't be afraid. It just means a function that takes in or returns a function.



```tsx
function Loading() {
  return <div>Loading</div>;
}

function Failure({ error }: { error: Error }) {
  return <div>Error: {error.message}</div>;
}

function BlogPosts({ data }: { data: Post[] }) {
  return (
    <div>
      {data.map(post => (
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
```