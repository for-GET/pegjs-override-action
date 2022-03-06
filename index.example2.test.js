let _ = require('lodash');
let PEG = require('pegjs');
let plugin = require('./');

describe('example2 - convenience makeBuildParser', function() {
  it('should work', function() {
    let buildParser = plugin.makeBuildParser({
      PEG,
      grammar: "start = 'a' / 'b' / 'c' / 'd' { return 'd' } / 'e'",
      initializer: "_ = require('lodash');",
      rules: {
        start: [
          function() {
            return 'b';
          },
          "return 'a';",
          undefined,
          undefined,
          function() {
            return _.VERSION;
          }
        ]
      },
      mixins: {} // list of default rules
    });

    let parser = buildParser({
      startRule: 'start',
      options: {}
    });

    expect(parser.parse('a')).toEqual('b');
    expect(parser.parse('b')).toEqual('a');
    expect(parser.parse('c')).toEqual('c');
    expect(parser.parse('d')).toEqual('d');
    expect(parser.parse('e')).toEqual(_.VERSION);
  });
});
