/* Copyright (C) 2025-2026 MarcosHCK
 * This file is part of wakit.
 *
 * wakit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wakit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
import { defineConfig } from 'eslint/config'
import eslintPluginReact from '@eslint-react/eslint-plugin'
import globals from 'globals'
import importPlugin from 'eslint-plugin-import'
import js from '@eslint/js'
import promisePlugin from 'eslint-plugin-promise'
import typescriptEslint from '@typescript-eslint/eslint-plugin'
import typescriptParser from '@typescript-eslint/parser'

export default defineConfig (
[
  js.configs.recommended,
  eslintPluginReact.configs.recommended,
{

  files: [ '**/*.{js,jsx,ts,tsx}' ],

  languageOptions:
    {

      ecmaVersion: 'latest',

      globals:
        {
          ...globals.browser,
          ...globals.es2020,
          ...globals.node,
          React: 'readonly',
        },

      parser: typescriptParser,

      parserOptions:
        {
          ecmaFeatures: { jsx: true },
          project: './tsconfig.json'
        },
      sourceType: 'module',
    },

  plugins:
    {

      '@typescript-eslint': typescriptEslint,

      import: importPlugin,
      promise: promisePlugin,
    },

  rules:
    {

      ...js.configs.recommended.rules,
      ...typescriptEslint.configs.recommended.rules,
      ...importPlugin.configs.recommended.rules,
      ...promisePlugin.configs.recommended.rules,

      'no-redeclare': 'off',
      'no-undef': 'off',
      '@typescript-eslint/no-redeclare': 'error',
      
      '@typescript-eslint/no-unused-vars': [ 'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_'
        }],
    },

  settings:
    {

      'import/resolver':
        {

          node:
            {
              extensions: [ '.js', '.jsx', '.ts', '.tsx' ],
            },

          typescript:
            {
              alwaysTryTypes: true,
              project: './tsconfig.json',
            },
        },
    }
}])