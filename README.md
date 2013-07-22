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

parser = PEG.buildParser "start = 'a' / 'b' / 'c' / 'd' { return 'd' } / 'e' 'f'",
  plugins: [overrideAction]
  overrideActionPlugin:
    rules:
      start: [
        () -> "b"
        "return 'a';"
        '__ignore__'        
        undefined
        '__$__'
      ]

parser.parse 'a' # 'b'
parser.parse 'b' # 'a'
parser.parse 'c' # '' , normally would return 'c'
parser.parse 'd' # 'd'
parser.parse 'e' # 'e', normally would return ['e', '']
```


## License

[Apache 2.0](LICENSE)
