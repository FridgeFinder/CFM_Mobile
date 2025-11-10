module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'quotes': ['error', 'single'],
    'max-len': ['error', {code: 100, ignoreStrings: true, ignoreTemplateLiterals: true}],
    'require-jsdoc': 'off',
    'valid-jsdoc': 'off',
    'indent': ['error', 2],
    'object-curly-spacing': ['error', 'never'],
    'comma-dangle': ['error', 'always-multiline'],
  },
};
