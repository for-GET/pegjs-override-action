# PEGjs override action

Override action ([PEGjs](https://github.com/pegjs/pegjs) plugin)


## Reason

This plugin came to life as part of a process of referencing basic PEGs
and build structure outside of the PEGs.
In essence, it gives the possibility for reusable PEGs.

E.g. [A collection of core PEGjs grammars (RFC, ISO, etc.)](https://github.com/for-GET/core-pegjs)


## Usage

```bash
npm install pegjs-override-action
```

See [index.example1.test.js](./index.example1.test.js)
and a convenient function `.makeBuildParser` in [index.example2.test.js](./index.example2.test.js).

## Scopes and require paths

When defining an action as a function,
it will be stringified and injected into a different scope,
which breaks variable closure.

Any data or functions that need to be shared between rule actions
should be defined in your initializer block.

When using `require` in your actions or initializer,
it is a good idea to resolve an absolute path
(e.g. using `require.resolve` as the code is also executed in a different path than where it is defined.

## License

[UNLICENSE](LICENSE)
