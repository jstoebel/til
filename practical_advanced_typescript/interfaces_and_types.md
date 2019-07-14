types and interfaces work the same in many respects but not always.

A type can be a union of two other types/interfaces.
```
type Pet = Dog | Cat
```

But an interface is a contract that an object must implement. It can't be "one or the other"

Also: if I mention an interface of the same name twice they are merged. Similar to in Ruby when I open up a module twice

```
interface Dog {
  name: string
}

interface Dog {
  color: string
}

const dog: Dog = {
  name: 'buttons',
  color: 'black'
}
```

but types don't allow this. You can only declare a type once in a given name space. This is a good thing! It means that if we want to leave an `interface` open for adding new properties, we can do so and if we want to disallow such behavior we can use type.

If I was a library author, I would strongly consider using `interface` if I want to let consumers extend my library without having to import the type and using the `extends` key word. But if I'm writing types in my own code and want to avoid collisions, I should use `type` to have the complier catch them for me.