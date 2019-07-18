Typescript is a worry wort of a language. It tends to complain when ever there is a chance things can go wrong. This is often a welcome feature, especailly compared to its loosey-goosy cousin JavaScript. But there's a time and a place for relaxing standards at times. What if you genuinly don't know what a type will be ahead of time? `any` is how you tell the compiler to losen up a little, kick its shoes off and relax. When a type is assigned to `any` the  compiler will not object to any assumptions made about that type. The trade off here is that you are open to any number of run time errors. Just like regular JavaScript!

`unknown` is how you tell the compiler "I have no idea what this type will be! Proceed with caution." When Typescript is told that we don't know what a type is, it will be sure to complain about undue assumptions made about it. In fact, TS will not let you do _anything_ on an `unknown` type until you perform some kind of narrowing or casting on said object. For example:

```
let spam: unknown = service.fetch() // no clue what this will return!

if (typeof spam === 'string') {
  console.log(spam.toUpperCase()) // TS will allow this because you've ensured this code only runs when `spam` is a string
} 
```
