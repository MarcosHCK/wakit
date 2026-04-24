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
import { forwardRef } from 'react'
import { useImage } from '@wakit-example/hooks/useImage'

type Ct = HTMLImageElement
type Cp = React.DetailedHTMLProps<React.ImgHTMLAttributes<HTMLImageElement>, HTMLImageElement>

// eslint-disable-next-line react/display-name
export const AppIcon = forwardRef<Ct, Cp> ((props, ref) =>
{

  const img = useImage ('/favicon.ico')
  // eslint-disable-next-line @next/next/no-img-element
return <img alt='icon' {...props} ref={ref} src={img?.src} />
})