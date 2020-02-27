---
{
  "type": "blog",
  "author": Lars Lillo Ulvestad,
  "title": "My first steps into functional programming",
  "description": "After my first encounter with functional programming, I first felt lost. Then extremely empowered.",
  "image": "/images/article-covers/illustration-coding.jpg",
  "published": "2020-02-27",
  "draft": false
}
---

I had been working in journalism and communications a couple of years before I discovered JavaScript. This language introduced me to programming and made me so excited that I decided to switch careers.

I left my communications job in 2019 and went all-in on web development, JavaScript and React.

JavaScript was easy to grasp as I could write code and right away see what happened in the browser and the console.

## Then I was forced into Elm

As I landed my first (and current) day job as a developer, I quickly got some code to work with. In Elm 😓

I had barely started getting to know types from TypeScript, but the type system and syntax in Elm felt alien to me.

![Screenshot of friendly error message](/images/archive/elm-error-msg.png)

I couldn't do mutations. I felt caged in a sterile clean-room. I had to send a message to some massive update function thing and send my requested change into a modified copy of the state model.

And if I did something wrong, the app wouldn't even compile to sh*t.

**JavaScript never complained. And if it did complain, it did so silently, hidden away in the browser console.**

I felt puzzled and frustrated.

**But lucky for me, I had the attitude of wanting to learn why anyone would do it this way.**

## I first felt lost

I endured through it with the scarce selection of Elm resources. The good resources are really good, but the community is smaller than JavaScript and React. And 0.19 had just come with considerable breaking changes, so most tutorials were confusing.

Still, I was starting to get increasingly productive after a week or two.

**Most leading JavaScript influencers doesn't even mention Elm. At least not those who target beginners. They also barely scratch the surface on functional programming.**

I eventually left the Elm project to work on a new project in my consultancy firm. Safely back in React. I could mutate again like there was no tomorrow.

## Then I didn't want it any other way

My Elm mentor from the former project glanced at my screen while I was working in React, and he remarked, smugly:

**- Did you really miss working like that?**

I looked at my screen.

![Screenshot of unfriendly React message](/images/archive/react-runtime-error.png)

That error could never reach production in Elm. But it could creep up on any React project. Even written in TypeScript. And the error message above doesn't even point to the right line of code.

## Initial pain bearing sweet fruits

I am convinced that the functional programming paradigm leads to reliable code that is easy to refactor. Every programmer wants that, but not every programmer seems to believe it's a real thing.

Well, there is also a threshold to learning it. Not taking the leap of faith certainly feels like a safer choice. 

Functional programming differs from the procedural programming patterns. The learning curve can be a bit steep in the beginning. Even experienced programmers will need to invest time and energy in learning the patterns.

But every programmer wanting to grow should endure these initial pains. **Because it's the pains of personal growth.** 

Just look at this pure mathematical function i made to prove it:

```elm
programmerGrowth : 🐱 -> Maybe (Awesome 🦁)
programmerGrowth kitten =
    case kitten of
        LearningFP ->
          Just (Awesome 🦁)

        NotLearningFP ->
          Nothing
```

Even if you decide it's not for you, you will certainly become a better programmer it. How could you not?

## My learning path future

I have received some recommendations from colleagues that are far ahead of me in the FP game and I will pursue them.

I also realize that I will need to work with JavaScript and TypeScript a lot at work. 

I am therefore currently reading about FP in JavaScript, with the highly recommended [Professor Frisby's Mostly Adequate Guide to Functional Programming](https://mostly-adequate.gitbooks.io/mostly-adequate-guide/).

I am also planning to keep maintaining this site, written in Elm with the great [elm-pages](https://elm-pages.com), the Elm equivalent of GatsbyJS.

So more about my functional journey to come.