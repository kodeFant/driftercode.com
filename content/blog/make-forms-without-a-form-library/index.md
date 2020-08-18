---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Ditch the form library with functional TypeScript",
  "description": "A form library is convenient, but replacing it with functional programming gives you more power.",
  "image": "images/article-covers/illustration-coding.jpg",
  "published": "2020-06-18",
  "draft": true,
  "slug": "make-forms-without-a-form-library",
  tags: [],
}
---

Making a form in a single page app with React alone is burdensome.

Libraries like Formik and React Hook Form takes care of a lot of the complexity, but they all have a learning curve.

The only certain thing about front-end development is that it's always changing, and new and better libraries will come.

Do you always need a form library to make your awesome form? Probably not.

I will show you how you can replace it with a functional library like [Remeda](https://remedajs.com/docs) or [Ramda](https://ramdajs.com/) and have full control of every aspect of your form.

## Choosing a functional library

I choose Remeda for functional utilities because it supports TypeScript by default. If you want to familiarize yourself with it, you could start with replacing JavaScript methods you already use: map, filter and reduce.

```jsx
const numbers = [1, 2, 3, 4, 5];

const double = numbers.map((number) => number * 2);
```

While this is not too bad, Remeda opens up

```jsx
import * as R from "remeda";

const numbers = [1, 2, 3, 4, 5];

const double = R.map(numbers, (number) => number * 2);
```
