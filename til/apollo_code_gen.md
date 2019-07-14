One exciting perk of using Apollo with Typescript is the ability to auto generate types for all of your queries and mutations. This is a huge win because 1) you won't have to manually write out types for the results you expect back and 2) you can know immediatly if any changes to your API will break your client. Have the TS compiler do that work for you!

What follows is not a tutorial on how to do this (there are plenty of those already). Instead I am writing out my notes on where I was confused and what solutions I found.

# The Apollo Config

You need a file in your root called `apollo.config.js`. For example:

```
module.exports = {
  client: {
    service: {
      name: 'myService',
      localSchemaFile: './src/graphql/schema.json', # <-- location of the schema you'll be downloading
    },
    includes: ['src/graphql/*.ts'], # <-- where apollo can find your queries and mutations.
  },
};
```

# Downloading the schema. 

You can have apollo make an introspection query to your service in order to get the schema:

```
./node_modules/.bin/apollo service:download --endpoint='https://my-service.com/query' src/graphql/schema.json
```

## Dealing with invalid schema

I spent a _lot_ of time stuck on this. It turned out that our schema had two interfaces that defined no fields. This isn't _wrong_ persay but Apollo didn't like it and complained. My work around was to use an older tool `apollo-codegen` which made no such complaint
```
apollo-codegen introspect-schema http://localhost:8080/graphql --output schema.json
```

Then I manually edited the schema, deleting the interfaces defining no fields. Once you have a schema that apollo likes, it will let you run an introspection against the exact same service without complaint ¯\\\_(ツ)\_/¯

# Generating the types

```
./node_modules/.bin/apollo codegen:generate src/graphql/types --target=typescript --outputFlat --passthroughCustomScalars
```

Two issues came up here for me. Local queries and put it somewhere covered in your `includes` field in your apollo config (`src/graphql` in the example above).

## Local Queries

Queries using the @client protocol to denote a query against the cache only. You need a schema that defines anything not already defined by the service. You'll likely be extending the `Query` or `Mutation` field to define this client only stuff. Call it something like `clientSchema.graphql` and but it in the same folds

## Custom scalars

Our service defined custom scalars, which is just a fancy way of saying types that graphql doesn't know out of the box. Examples included `Email`, `Time` and `Money`. If you don't provide the `--passthroughCustomScalars` flag, graphql won't know what to make of these types and simply assign them to `any` in TS land. Not very helpful! What I did was create an `index.d.ts` in the directory above my generated types and mapped these custom types to something Typescript can understand. Note that its not always possible to be perfect. An `Email` type? Typescript doesn't allow regex matches in type definition (thought that would be cool). The best we can do there is `string`. An `Integer` type? Javascript only knows about `number`s so that's what we're going with.

# Additional thoughts

We went back and forth on whether generated types should be commited in to source control. Ultimatly we decided to not commit them and treat them like build products. Developers are expected to run `npm run gen-schema` as a normal step to get their enviornment ready. The same is done prior to running `tsc` during the deployment process. This made the most sense to us because it didn't quite make sense to source control something that's coupled with something outside the codebase. Since the API could change at any time, developers would need to regenerate their types locally anyway, so why bother source controlling them?

The ideal solution we thought up, that didn't seem exactly neccisary right now was to have a jenkins task attached to the API. When ever a commit is added to master, jenkins regenerates types on the client and commits the changes to master (sort of like a weekly automatic bundle or npm update). Jenkins then runs the normal build process on the client so we can find out if the API broke anything on the client.