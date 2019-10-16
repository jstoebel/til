Let’s say you have a generated type from Apollo like this one:

```typescript
export interface Person {
  __typename: "Person";
  id: number;
  firstName: string
  lastName: string
}
```
And you have another type that will need to be one of the fields in `Person`

What type should the field be? Its tempting to set it to `string` and be done with it. But what happens if field is set to a value that doesn’t belong `Person`? You’d get `undefined` and there's likely to be a runtime error. A better type would be `'id' | 'firstName' | 'lastName'` But this is a quickly growing codebase, and you know that things will change. `Person` is an automatically generated type, so you don't want to have to edit anything else when `Person` changes either. You want a type that automatically derives its values from the keys of `Person`. Here's how to do that.

`type Field = keyof Person`
that sets `Field` to `"__typename" | 'id' | 'firstName' | 'lastName'`. If `Person` changes its fields so does this type.

But it gets better. What if you want to filter out `__typename`? There’s another type called `Exclude` for that `Exclude<keyof Person, '__typename'>` Basically that means, "anything thats satisfies the first type but not the second"