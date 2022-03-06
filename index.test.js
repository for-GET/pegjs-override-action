let _ = require('lodash');
let plugin = require('./');

let actionFun = function(fun) {
  fun = plugin.funToString(fun);
  eval(`fun = function(__result){${fun}}`);
  return fun;
};


describe('override action plugin', function() {
  describe('basics', function() {
    it('should export 2 functions', function() {
      expect(plugin).toEqual(expect.any(Function));
      expect(plugin.use).toEqual(expect.any(Function));
    })
  });


  describe('errors', function() {
    it('should throw an error if no plugin options are defined', function() {
      expect(function() {
        plugin.use({}, {});
      }).toThrow;
    });


    it('should throw an error when alternatives.length doesnt match', function() {
      let ast = {
        rules: [{
          type: 'expression',
          name: 'start',
          expression: {
            type: 'choice',
            alternatives: []
          }
        }]
      };

      let options = {
        overrideActionPlugin: {
          rules: {
            start: [
              undefined
            ]
          }
        }
      };

      expect(function() {
        plugin(ast, options);
      }).toThrow();
    });
  });


  describe('success', function() {
    let fun = function() {
      return '0';
    };

    // FIXME flaky job
    let funBody = "\n      return '0';\n    ";
    // FIXME end

    let ast = {
      rules: [{
        type: 'expression',
        name: 'start',
        expression: {
          type: 'named',
          name: 'start rule',
          expression: {
            type: 'choice',
            alternatives: [{
              type: 'action'
            }]
          }
        }
      }]
    };

    describe('code', function() {
      let expectedResult = {
        rules: [{
          type: 'expression',
          name: 'start',
          expression: {
            type: 'named',
            name: 'start rule',
            expression: {
              type: 'choice',
              alternatives: [{
                type: 'action',
                code: funBody
              }]
            }
          }
        }]
      };

      it('should accept a function', function() {
        let options = {
          overrideActionPlugin: {
            rules: {
              start: [
                fun
              ]
            }
          }
        };

        let result = plugin(_.cloneDeep(ast), options);
        expect(result).toEqual(expectedResult);
      });


      it('should accept a functions body', function() {
        let options = {
          overrideActionPlugin: {
            rules: {
              start: [
                funBody
              ]
            }
          }
        };

        let result = plugin(_.cloneDeep(ast), options);
        expect(result).toEqual(expectedResult);
      });
    });


    describe('initializer', function() {
      let expectedInitializerResult = {
        initializer: {
          type: 'initializer',
          code: `(function(){${funBody}})();`
        },
        rules: ast.rules
      };

      it('should accept a function', function() {
        let options = {
          overrideActionPlugin: {
            initializer: fun
          }
        };

        let result = plugin(_.cloneDeep(ast), options);
        expect(result).toEqual(expectedInitializerResult);
      });


      it('should accept a function body', function() {
        let options = {
          overrideActionPlugin: {
            initializer: `(function(){${funBody}})();`
          }
        };

        let result = plugin(_.cloneDeep(ast), options);
        expect(result).toEqual(expectedInitializerResult);
      });
    });
  });


  describe('.action$', function() {
    it('should let a string alone', function() {
      expect(actionFun(plugin.action$)('test')).toEqual('test');
    });

    it('should join an array without any separator', function() {
      expect(actionFun(plugin.action$)(['te', 'st'])).toEqual('test');
    });

    it('should handle mixed values', function() {
      expect(actionFun(plugin.action$)([['t', ['', 'e']], 'st'])).toEqual('test');
    });
  });


  describe('.actionIgnore', function() {
    it('should return empty string', function() {
      expect(actionFun(plugin.actionIgnore)('test')).toEqual('');
    });
  });
});
