I can map the properties of one type onto another, and modify them too. Here I am pulling in all of the properties from `Animal` but making them read only and optional

```
interface Animal {
  numLegs: number;
  hasHair: boolean;
}

interface ReadonlyAnimal {
  readonly [K in keyof Animal]+?: Animal[K]
}
```