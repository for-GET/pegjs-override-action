let _ = require('lodash');
let PEG = require('pegjs');
let plugin = require('./');

describe('example1', function() {
  it('should work', function() {
    let parser = PEG.buildParser("start = 'a' / 'b' / 'c' / 'd' { return 'd' } / 'e'", {
      plugins: [plugin],
      overrideActionPlugin: {
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
        }
      }
    });

    expect(parser.parse('a')).toEqual('b');
    expect(parser.parse('b')).toEqual('a');
    expect(parser.parse('c')).toEqual('c');
    expect(parser.parse('d')).toEqual('d');
    expect(parser.parse('e')).toEqual(_.VERSION);
  });
});
