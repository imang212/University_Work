import eslint from '@eslint/js'
import tseslint from 'typescript-eslint'

export default tseslint.config(eslint.configs.recommended, tseslint.configs.recommended, {
  rules: {
    'prefer-const': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-expressions': 'off',
    '@typescript-eslint/no-unused-vars': [
      'warn',
      {
        argsIgnorePattern: '^_',
      },
    ],
  },
})
