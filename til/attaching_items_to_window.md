Typescript offers the ability to add some rules to how we interact with global variables such as `window`. To do do, you'll need to add this to `index.d.ts`

```typescript
export {};
declare global {
  interface Window {
    newField: SomeType
  }
}
```

For whatever reason, this file needs to be a module which is why we have `export {}`. Now you can have some confidence about how your legacy Javascript is interacting with `window`.