{_, should} = require './utils'
plugin = require '../index.coffee' # dont prioritize the .js file

describe 'override action plugin', () ->
  describe 'basics', () ->
    it 'should export 2 functions', () ->
      plugin.should.be.a 'function'
      plugin.use.should.be.a 'function'


  describe 'errors', () ->
    it 'should throw an error if no plugin options are defined', () ->
      should.Throw () -> plugin.use {}, {}


    it 'should throw an errro when alternatives are required', () ->
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
            start: ""

      should.Throw () -> plugin ast, options


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
    safeFunBody = funBody.replace /\/\"/g, '\\\"'
    wrappedFunBody = "return (function() {\n  #{safeFunBody}\n}).apply(peg$overrideAction$scope);"
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
            code: wrappedFunBody
          }]
      }]
      initializer:
        type: 'initializer'
        code: 'peg$overrideAction$scope = (function() {\n  \n  return this;\n}).call({});'


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
