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
import { type Configuration } from 'webpack'
import { ManifestPlugin } from 'webpack'
import MiniCssExtractPlugin from 'mini-css-extract-plugin'

export const extensions = [ '.js', '.jsx', '.ts', '.tsx' ]

type Mode = NonNullable<Configuration['mode']>
const mode: Mode = 'development' as Mode

export async function createWebpackConfig ()
{

  const config: Configuration =
    {

      devtool: 'source-map',

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
          new ManifestPlugin ({ entrypoints: false,
                                filename: 'manifest.json' }),
          new MiniCssExtractPlugin ({ filename: '[name].css',
                                      chunkFilename: '[name].[contenthash].chunk.css' }),
        ],

      resolve: { extensions }
    };
return config
}