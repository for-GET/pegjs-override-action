let _ = require('lodash');
let PEG = require('pegjs');
let plugin = require('./');

describe('example2 - convenience makeGenerate', function() {
  it('should work', function() {
    let generate = plugin.makeGenerate({
      PEG,
      grammar: "start = 'a' / 'b' / 'c' / 'd' { return 'd' } / 'e'",
      initializer: "var _ = require('lodash');",
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

    let parser = generate({
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
