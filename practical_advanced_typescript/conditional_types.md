Generics let us pass in types are arguments to generate new types based on them. Typescript also lets us apply additional logic to determine type dynamically

For example:

```
type ArrayFilter<T> = T extends any[] ? T : never;
```

effectivly says that ArrayFilter must be given some kind of array for its generic. All other types are mapped on to `never` which can't have anthing assigned to it. If I pass a union type, like 

```
type StringsOrNumbers = ArrayFilter<string | number | string[] | number[]>;
```

that will be reduced down to `never | never | string[] | number[]`

But the compiler is smart! I knows that nothing can be assigned to `never` meaning that effectivly the type will be ` string[] | number[]`. Neat!

There's more! I can use the type of a function's input to dynamically tell the compiler what type is returned:

```
interface Book {
  id: string;
  tableOfContents: string[];
}

interface Tv {
  id: number;
  diagonal: number;
}

interface IItemService {
  getItem<T>(id: T): Book | Tv;
}

let itemService: IItemService; 
```

Here I have two types of items, `Tv`s and `Book`s. I've got a function called `getItem` on `IItemService` and I'm telling the compiler it will return either a `Book` or `Tv`

But I can do better than that. Since `Book`s have an id of `string` type and `Tv`s `number`s we can use what's provided to `getItem` to infer the return type

```
interface IItemService {
  getItem<T>(id: T): T extends string ? Book : Tv;
}
```
here is use logic saying if the provided argument is of type `string` or extends `string` its a `Book`, otherwise, its a `Tv`

But what happens if completly different type is given? `Tv` would mistakenly by infered. I can lock things down like so

```
interface IItemService {
  getItem<T extends string | number>(id: T): T extends string ? Book : Tv;
}
```

Now arguments extending `string` or `number` are the only ones allowed.



