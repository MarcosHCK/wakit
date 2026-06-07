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
import { ManifestPlugin } from 'webpack'
import { TanStackRouterCodeSplitterWebpack } from '@tanstack/router-plugin/webpack'
import { type Configuration } from 'webpack'
import { type Configuration as DevServerConfiguration } from 'webpack-dev-server'
import HtmlWebpackPlugin from 'html-webpack-plugin'
import MiniCssExtractPlugin from 'mini-css-extract-plugin'

const extensions = [ '.js', '.jsx', '.ts', '.tsx' ] as const

type Mode = NonNullable<Configuration['mode']>
const mode: Mode = 'development' as Mode

export async function createWebpackConfig ()
{

  const entries = { 'app': './index.tsx' }

  const config: Configuration =
    {
    
      entry: entries,
      devtool: 'source-map',

      name: 'Standalone pages',

      optimization:
        {

          chunkIds: 'size',
          minimize: mode === 'production',
          moduleIds: 'size',
          removeAvailableModules: true,
          runtimeChunk: { name: 'runtime' },
          sideEffects: 'flag',

          splitChunks:
            {

              chunks: 'all',
              maxAsyncRequests: 6,
              maxInitialRequests: 4,
              minSize: 20000,
              maxSize: 244000,
            },

          usedExports: mode === 'production',
        },

      output:
        {
          clean: true,
          globalObject: 'this',
          filename: '[name].[contenthash:8].bundle.js',
          library: { name: '[name]', type: 'umd2' },
        },

      mode,

      module:
        {

          rules:
            [
              {
                test: /\.(css|pcss|postcss)$/,
                use:
                  [

                    MiniCssExtractPlugin.loader,

                    {

                      loader: 'css-loader',

                      options:
                        {

                          importLoaders: 1,

                          modules:
                            {
                              auto: true,
                              exportGlobals: true,
                              localIdentName: '[name]__[local]--[hash:base64:5]',
                              mode: 'local',
                            },
                        },
                    },
                    'postcss-loader',
                  ],
              },
              {
                exclude: /node_modules/,
                test: /\.(js|jsx)$/,
                use: 'babel-loader',
              },
              {
                exclude: /node_modules/,
                test: /\.(ts|tsx)$/,
                use: 'babel-loader',
              },
            ],
        },

      plugins:
        [

          TanStackRouterCodeSplitterWebpack (
            {

              autoCodeSplitting: true,
              generatedRouteTree: './routes.gen.ts',
              routesDirectory: './routes',
              target: 'react',
            }),

          new ManifestPlugin ({ entrypoints: false,
                                filename: 'manifest.json' }),
          new MiniCssExtractPlugin ({ filename: '[name].css',
                                      chunkFilename: '[name].[contenthash].chunk.css' }),

          ...Object.keys (entries).map (name => new HtmlWebpackPlugin (
            {
              chunks: [ name ],
              filename: `${name}.html`,
              template: './index.html',
              xhtml: true,
            }))
        ],

      resolve: { extensions: [ ...extensions ] },
    }

  const serverConfig: DevServerConfiguration =
    {

      client:
        {
          overlay:
            {
              errors: true,
              warnings: true,
            },
          progress: true,
        },

      hot: true,
      port: 43900,
    }

return { ...config, devServer: serverConfig }
}

export default createWebpackConfig