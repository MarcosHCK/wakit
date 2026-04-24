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
import { createWebpackConfig as _createWebpackConfig } from './webpack.base'
import { type Configuration } from 'webpack'
import { type Configuration as DevServerConfiguration } from 'webpack-dev-server'
import HtmlWebpackPlugin from 'html-webpack-plugin'

async function createWebpackConfig ()
{

  const entries = { 'app': './app.tsx' }
  const baseConfig = await _createWebpackConfig ()

  const config: Configuration =
    {

      ...baseConfig, entry: entries,
                     name: 'Standalone pages',

      output:
        {
          ...baseConfig.output,
        },

      plugins:
        [
          ...(baseConfig.plugins as []),

          ...Object.keys (entries).map (name => new HtmlWebpackPlugin ({
            chunks: [ name ],
            filename: `${name}.html`,
          })),
        ]
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