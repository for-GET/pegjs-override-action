{
  _
  should
} = require './_utils'
plugin = require '../src/plugin'

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
