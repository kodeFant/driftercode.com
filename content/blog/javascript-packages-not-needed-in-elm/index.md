---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "Nice React libraries you don't need in Elm",
  "description": "A somewhat biased look at what Elm does out of the box.",
  "image": "images/article-covers/illustration-coding.jpg",
  "published": "2020-06-01",
  "draft": true,
  "slug": "functional-js-vs-ts",
  tags: [],
}
---

## Advanced State Management

### JavaScript

Redux, Easy Peasy, mobX, XState, but also possible with just React

### Elm

Supported by the language

## Static types

### JavaScript

TypeScript and Flow, not strictly enforced

## Elm

Strictly enforced in the language

## Tree shaking

## JavaScript

ParcelJS, Webpack. Depending on configuration and package support

## Elm

Featured in the language

## Immutable data

### JavaScript

ImmutableJS, Immer, PreludeJS

### Elm

The only option

## Convenient form handling

### JavaScript

Formik, React Hook Form

### Elm

Not really needed, except for maybe a validation library like elm-validate

## Routing

## JavaScript

React Router, Reach Router

## Elm

Officially maintained package

## Decoding incoming data

### JavaScript

io-ts, purify-ts

### Elm

Mandatory for IO with an [officially maintained package](https://package.elm-lang.org/packages/elm/json/latest/)

## State machines

### JavaScript

XState

### Elm

A natural way to structure your state. There also exists a library consisting of about [ten lines of code](https://github.com/the-sett/elm-state-machines/blob/1.0.1/src/StateMachine.elm).

### Currying

### JavaScript

Possible in JavaScript, but does not work well with TypeScript

### Elm

Of course

## Bonus: Things JavaScript does that Elm doesn't do

## Mutating values anywhere and any time

### JavaScript

Supported and widely used

### Elm

Not allowed

## null, the [billion dollar mistake](https://www.linkedin.com/pulse/20141126171912-7082046-tony-hoare-invention-of-the-null-reference-a-billion-dollar-mistake/)

### JavaScript

Supported and widely used

### Elm

Not a thing. A value can be 'Nothing' and must then be explicitly handled

## Run-time errors in production

### JavaScript

Everywhere

### Elm

Almost impossible

## NPM packages for everything

### JavaScript

Of course, NPM is made for JavaScript

### Elm

Has it's own package registry with strictly enforced semantic versioning, so breaking changes must be properly versioned.

You can also use NPM packages through ports or web components.
