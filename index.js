let _ = require('lodash');

let pass = function(ast, options) {
  let myOptions = options.overrideActionPlugin;
  let {
    initializer,
    rules
  } = ast;
  let overrideInitializer = myOptions.initializer;
  let overrideRules = _.defaultTo(myOptions.rules, {});

  if (overrideInitializer) {
    if (_.isFunction(overrideInitializer)) {
      overrideInitializer = pass.funToString(overrideInitializer);
      overrideInitializer = `(function(){${overrideInitializer}})();`;
    }
    ast.initializer = {
      type: 'initializer',
      code: overrideInitializer
    };
  }

  if (_.isFunction(overrideRules)) {
    return overrideRules(ast, options);
  }

  _.forEach(rules, function(rule) {
    let newValue = overrideRules[rule.name];
    let newValueIsArray = Array.isArray(newValue);
    if (newValue == null) {
      return;
    }

    let ruleName = rule.name;
    if (rule.expression.type === 'named') {
      ruleName += ` \"${rule.name}\"`;
      rule = rule.expression;
    }
    if (newValueIsArray && (rule.expression.type === 'choice')) {
      let {alternatives} = rule.expression;
      if (alternatives.length !== newValue.length) {
        throw new Error(`Rule ${ruleName} mismatch (require ${alternatives.length} alternatives, got ${newValue.length} instead)`);
      }
      _.forEach(alternatives, function(alternative, alternativeIndex) {
        alternatives[alternativeIndex] = pass.overrideAction(alternative, newValue[alternativeIndex]);
      });
    } else if (!newValueIsArray) {
      rule.expression = pass.overrideAction(rule.expression, newValue);
    } else {
      throw new Error(`Rule ${ruleName} mismatch (requires no alternatives)`);
    }
  });

  return ast;
};


pass.use = function(config, options = {}) {
  if (_.isNil(options.overrideActionPlugin)) {
    throw new Error('Please define overrideActionPlugin as an option to PEGjs');
  }
  let stage = config.passes.transform;
  return stage.unshift(pass);
};


pass.funToString = function(fun) {
  let funToString = fun.toString();
  let bodyStarts = funToString.indexOf('{') + 1;
  let bodyEnds = funToString.lastIndexOf('}');
  return funToString.substring(bodyStarts, bodyEnds);
};


pass.action$ = function() {
  let join = function(arr) {
    return _.join(arr, '');
  };
  let recursiveJoin = function(value) {
    if (_.isArray(value)) {
      value = _.map(value, recursiveJoin);
      value = join(value);
    }
    return value;
  };
  return recursiveJoin(__result);
};


pass.actionIgnore = function() {
  return '';
};


pass.overrideAction = function(rule, code) {
  if (_.isFunction(code)) {
    code = pass.funToString(code);
  }
  if (code === '__$__') {
    code = pass.action$;
  }
  if (code === '__ignore__') {
    code = pass.actionIgnore;
  }
  if (_.isUndefined(code)) {
    return rule;
  }

  if (rule.type !== 'action') {
    rule = {
      type: 'action',
      expression: rule
    };
  }

  rule.code = code;
  return rule;
};


pass.makeGenerate = function({grammar, initializer, rules, mixins, PEG}) {
  mixins = _.defaultTo(mixins, []);
  rules = _.clone(rules);
  _.forEach(mixins, function(mixin) {
    _.defaults(rules, mixin);
  });

  let mod = function({startRule, options}) {
    options = _.defaultTo(options, {});
    _.assign(options, {
      allowedStartRules: [startRule],
      plugins: [pass],
      overrideActionPlugin: {
        initializer,
        rules
      }
    });

    let parser = PEG.generate(grammar, options);
    if (options.output === 'source') {
      return `(function(){
  let original = ${parser};
  let fun = original.parse;
  fun.SyntaxError = original.SyntaxError;
  fun.parse = original.parse;
  return fun;
})()\
`;
    }

    // FIXME pegjs should throw an exception if startRule is not defined
    let {SyntaxError, parse} = parser;
    parser = parse;
    parser._parse = parse;
    parser.SyntaxError = SyntaxError;

    parser.parse = function(input, options = {}) {
      _.defaults(options, {
        startRule
      });
      return parser._parse(input, options);
    };
    parser._ = {
      grammar,
      options
    };
    return parser;
  };

  mod._ = {
    grammar,
    initializer,
    rules
  };

  return mod;
};

module.exports = pass;
