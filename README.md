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


## License

[Apache 2.0](LICENSE)
