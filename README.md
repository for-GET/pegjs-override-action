# PEGjs override action

Override action ([PEGjs](https://github.com/dmajda/pegjs) plugin)


## Reason

This plugin came to life, as part of a process of referencing basic PEGs and build structure outside of the PEGs. In essence, it gives the possibility for reusable PEGs.

E.g. [A collection of core PEGjs grammars (RFC, ISO, etc.)](https://github.com/andreineculau/core-pegjs)


## Usage

```bash
npm install pegjs-override-action
```

```coffee
peg = require 'peg'
overrideAction = require 'pegjs-override-action'

parser = PEG.buildParser "start = 'a' / 'b' / 'c' / 'd' { return 'd' } / 'e'",
  plugins: [overrideAction]
  overrideActionPlugin:
    initializer: "_ = require('lodash');"
    rules:
      start: [
        () -> "b"
        "return 'a';"
        undefined
        '__skip__' # equivalent to undefined atm
        () -> _.VERSION
      ]

parser.parse 'a' # 'b'
parser.parse 'b' # 'a'
parser.parse 'c' # 'c'
parser.parse 'd' # 'd'
parser.parse 'e' # e.g. 1.3.1
```

## Scopes and require paths

When defining an action as a function, it will be stringified and injected into a different scope, which breaks variable closure. Any data or functions that need to be shared between rule actions should be defined in your initializer block. When using `require` in your actions or initializer, it is a good idea to resolve an absolute path (e.g. using `require.resolve` as the code is also executed in a different path than where it is defined.


## License

[Apache 2.0](LICENSE)
