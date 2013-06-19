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

  rule.code = code
  rule


module.exports = pass = (ast, options) ->
  myOptions = options.overrideActionPlugin
  rules = ast.rules
  override = myOptions.rules or {}

  return override ast, options  if isFunction override

  for rule, ruleIndex in rules
    newValue = override[rule.name]
    newValueIsArray = Array.isArray newValue
    continue  unless newValue?

    if newValueIsArray and rule.expression.type is 'choice'
      alternatives = rule.expression.alternatives
      if alternatives.length isnt newValue.length
        throw new Error "Rule #{rule.name} mismatch (alternatives #{alternatives.length} != #{newValue.length}"
      for alternative, alternativeIndex in alternatives
        alternatives[alternativeIndex] = overrideAction alternative, newValue[alternativeIndex]
    else if not newValueIsArray
      rule.expression = overrideAction rule.expression, newValue
    else
      throw new Error "Rule #{rule.name} mismatch (needs no alternatives)"
  ast


module.exports.use = (config, options = {}) ->
  unless options.overrideActionPlugin?
    throw new Error 'Please define overrideActionPlugin as an option to PEGjs'
  stage = config.passes.transform
  stage.unshift pass
