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

In my [previous post](/blog/slaying-a-ui-antipattern-with-typescript), I promised to build on the RemoteData type based on the popular Elm pattern. Read it to understand the **why** and the **wtf** of it. 

**Use the code from the [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-77dci) from the previous post as a starter code.**

This time we will make the switch statement in the **Main** React component into a thing of beauty.


```tsx
return foldRemoteData(
  posts,
  () => <FetchPosts getPosts={getPosts} />,
  () => <Loading />,
  (error) => <Failure error={error} />,
  (data) => <BlogPosts data={data} />
);
```

What it does is simply make a less verbose version of the switch statement.

This way of doing it makes sense because the pattern has a somewhat logical order.

## Split the logic

First, we can do an easy refactor and split out the views into separate functions. Just because it's good to separate stuff into smaller functions.

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

## The implementation

Let us dive in and make the utility function for RemoteData. It might look weird, but just type it out yourself, and I think it will make sense to you.

```tsx
function foldRemoteData<R, E, D>(
  remoteData: RemoteData<E, D>,
  notAsked: () => R,
  loading: () => R,
  failure: (error: E) => R,
  success: (data: D) => R
): R {
  switch (remoteData.type) {
    case "NOT_ASKED":
      return notAsked();
    case "LOADING":
      return loading();
    case "FAILURE":
      return failure(remoteData.error);
    case "SUCCESS":
      return success(remoteData.data);
  }
}
```

The function is heavily based on [gcantis Flow port of RemoteData](https://medium.com/@gcanti/slaying-a-ui-antipattern-with-flow-5eed0cfb627b). 

I made the fold function a bit more general. I also ditched it being curried as it disabled type inference on the data and error types.

What you see is a **higher order function**. Don't be afraid. It just means a function that takes in or returns functions. You probably deal with it all the time.

Now, you can replace the switch statement with this **foldRemoteData** function.

```tsx
function Main(): JSX.Element {
  const [posts, setPosts] = useState<RemoteData<Error, Post[]>>({
    type: "NOT_ASKED"
  });

  const getPosts = () => {
    setPosts({ type: "LOADING" });
    fetchPosts().then(remoteData => setPosts(remoteData));
  };

  return foldRemoteData(
    posts,
    () => <FetchPosts getPosts={getPosts} />,
    () => <Loading />,
    (error) => <Failure error={error} />,
    (data) => <BlogPosts data={data} />
  );
}
```

Very sleek! If you like this pattern, but you prefer to use a library, there are alternatives:

- [devexperts/remote-data-ts](https://github.com/devexperts/remote-data-ts) (based on **fp-ts**)
- [abraham/remotedata](https://github.com/abraham/remotedata)

I currently prefer to just put the RemoteData type and the fold function into my own code. That's pretty much all I need, and there isn't much more to it.

The devexperts version seems to have some advanced utilites, but I wish there were any examples in the docs.

You can pretty easily make your own convenience functions as the pattern is really simple anyway.

- See the complete code on [CodeSandbox](https://codesandbox.io/s/remotedata-with-typescript-and-react-part-2-hlu4v?file=/src/index.tsx)

## Next up

**That's it for RemoteData, but the series goes on.**

I want to make this little TypeScript code into something that gives you similar advantages to what Elm delivers. That will require a few more steps.

Therefore I think we should cover **decoding the incoming data** in the next post.

If you don't know what decoding the data means, you probably don't do it 😁 It may not be a sexy topic, but it's one of those features in Elm that makes it almost impossible to get run-time exceptions in production. 

And with a functional library based on TypeScript, it's pretty easy. [Purify](https://gigobyte.github.io/purify/) to the rescue!