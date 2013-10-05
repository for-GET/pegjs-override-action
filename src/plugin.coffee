toString = {}.toString


isFunction = (obj) ->
  toString.call(obj) is '[object Function]'


exports = module.exports = pass = (ast, options) ->
  myOptions = options.overrideActionPlugin
  initializer = ast.initializer
  overrideInitializer = myOptions.initializer
  rules = ast.rules
  overrideRules = myOptions.rules or {}

  if overrideInitializer
    overrideInitializer = exports.funToString overrideInitializer  if isFunction overrideInitializer
    ast.initializer = {
      type: 'initializer'
      code: overrideInitializer
    }

  return overrideRules ast, options  if isFunction overrideRules

  for rule, ruleIndex in rules
    newValue = overrideRules[rule.name]
    newValueIsArray = Array.isArray newValue
    continue  unless newValue?

    ruleName = rule.name
    if rule.expression.type == 'named'
      ruleName += " \"#{rule.name}\""
      rule = rule.expression
    if newValueIsArray and rule.expression.type is 'choice'
      alternatives = rule.expression.alternatives
      if alternatives.length isnt newValue.length
        throw new Error "Rule #{ruleName} mismatch (alternatives #{alternatives.length} != #{newValue.length}"
      for alternative, alternativeIndex in alternatives
        alternatives[alternativeIndex] = exports.overrideAction alternative, newValue[alternativeIndex]
    else if not newValueIsArray
      rule.expression = exports.overrideAction rule.expression, newValue
    else
      throw new Error "Rule #{ruleName} mismatch (needs no alternatives)"
  ast


exports.use = (config, options = {}) ->
  unless options.overrideActionPlugin?
    throw new Error 'Please define overrideActionPlugin as an option to PEGjs'
  stage = config.passes.transform
  stage.unshift pass


exports.funToString = (fun) ->
  fun = fun.toString()
  bodyStarts = fun.indexOf('{') + 1
  bodyEnds = fun.lastIndexOf '}'
  fun.substring bodyStarts, bodyEnds


exports.action$ = () ->
  join = (arr) -> arr.join ''
  recursiveJoin = (value) ->
    if Array.isArray value
      value = value.map recursiveJoin
      value = join value
    value
  recursiveJoin __result


exports.actionIgnore = () ->
  ''


exports.overrideAction = (rule, code) ->
  code = exports.funToString code  if isFunction code
  code = exports.action$  if code is '__$__'
  code = exports.actionIgnore  if code is '__ignore__'
  return rule  if code is undefined
  if rule.type isnt 'action'
    rule = {
      type: 'action'
      expression: rule
    }

  rule.code = code
  rule
