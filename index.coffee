toString = {}.toString


isFunction = (obj) ->
  toString.call(obj) is '[object Function]'


funToString = (fun) ->
  fun = fun.toString()
  bodyStarts = fun.indexOf('{') + 1
  bodyEnds = fun.lastIndexOf '}'
  fun.substring bodyStarts, bodyEnds


overrideAction = (rule, code) ->
  return rule  if code is undefined
  code = funToString code  if isFunction code
  return rule  if code is '__skip__'
  if rule.type isnt 'action'
    rule = {
      type: 'action'
      expression: rule
    }

  wrappedCode = """
    return (function() {
      #{code}
    }).apply(peg$overrideAction$scope);
  """

  rule.code = wrappedCode
  rule


module.exports = pass = (ast, options) ->
  myOptions = options.overrideActionPlugin
  rules = ast.rules
  override = myOptions.rules or {}

  return override ast, options  if isFunction override

  ast.initializer ?=
    type: 'initializer'
    code: ''
  ast.initializer.code = """
    peg$overrideAction$scope = (function() {
      #{ast.initializer.code}
      return this;
    }).call({});
  """

  for rule, ruleIndex in rules
    console.log 123123  if rule.type is 'initializer'
    newValue = override[rule.name]
    continue  unless newValue?

    if rule.expression.type is 'choice'
      alternatives = rule.expression.alternatives
      unless Array.isArray newValue
        throw new Error "Rule #{rule.name} mismatch (needs alternatives)"
      if alternatives.length isnt newValue.length
        throw new Error "Rule #{rule.name} mismatch (alternatives #{alternatives.length} != #{newValue.length}"
      for alternative, alternativeIndex in alternatives
        alternatives[alternativeIndex] = overrideAction alternative, newValue[alternativeIndex]
    else
      rule.expression = overrideAction rule.expression, newValue
  ast


module.exports.use = (config, options = {}) ->
  unless options.overrideActionPlugin?
    throw new Error 'Please define overrideActionPlugin as an option to PEGjs'
  stage = config.passes.transform
  stage.unshift pass
