{
  _
  should
} = require './_utils'
plugin = require '../src/plugin'
actionFun = (fun) ->
  fun = plugin.funToString fun
  eval "fun = function(__result){#{fun}}"
  fun


describe 'override action plugin', () ->
  describe 'basics', () ->
    it 'should export 2 functions', () ->
      plugin.should.be.a 'function'
      plugin.use.should.be.a 'function'


  describe 'errors', () ->
    it 'should throw an error if no plugin options are defined', () ->
      should.Throw () -> plugin.use {}, {}


    it 'should throw an error when alternatives.length doesnt match', () ->
      ast =
        rules: [{
          type: 'expression'
          name: 'start'
          expression:
            type: 'choice'
            alternatives: []
        }]

      options =
        overrideActionPlugin:
          rules:
            start: [
              undefined
            ]

      should.Throw () -> plugin ast, options


  describe 'success', () ->
    fun = () -> "0"
    # FIXME flaky job
    funBody = '\n        return \"0\";\n      '
    # FIXME end

    ast =
      rules: [{
        type: 'expression'
        name: 'start'
        expression:
          type: 'choice'
          alternatives: [{
            type: 'action'
          }]
      }]

    expectedAst =
      rules: [{
        type: 'expression'
        name: 'start'
        expression:
          type: 'choice'
          alternatives: [{
            type: 'action'
            code: funBody
          }]
      }]

    expectedInitializerAst =
      initializer:
        type: 'initializer'
        code: funBody
      rules: ast.rules


    it 'should accept functions as code', () ->
      options =
        overrideActionPlugin:
          rules:
            start: [
              fun
            ]

      plugin(_.cloneDeep(ast), options).should.eql expectedAst


    it 'should accept body functions as code', () ->
      options =
        overrideActionPlugin:
          rules:
            start: [
              funBody
            ]

      plugin(_.cloneDeep(ast), options).should.eql expectedAst


    it 'should accept function as initializer', () ->
      options =
        overrideActionPlugin:
          initializer: fun

      plugin(_.cloneDeep(ast), options).should.eql expectedInitializerAst


    it 'should accept body functions as code', () ->
      options =
        overrideActionPlugin:
          initializer: funBody

      plugin(_.cloneDeep(ast), options).should.eql expectedInitializerAst


  describe '.action$', () ->
    it 'should let a string alone', () ->
      actionFun(plugin.action$)('test').should.eql 'test'

    it 'should join an array without any separator', () ->
      actionFun(plugin.action$)(['te', 'st']).should.eql 'test'

    it 'should handle mixed values', () ->
      actionFun(plugin.action$)([['t', ['', 'e']], 'st']).should.eql 'test'


  describe '.actionIgnore', () ->
    it 'should return empty string', () ->
      actionFun(plugin.actionIgnore)('test').should.eql ''
