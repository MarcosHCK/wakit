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
import { type FormErrors, type FormRulesRecord, type UseFormReturnType } from '@mantine/form'
import { useEffect } from 'react'

export function useFormQuery<Values extends Record<string, unknown>,
                             TransformedValues = Values>
 (form: UseFormReturnType<Values, TransformedValues>, queryResult: Values): void;

export function useFormQuery<Values extends Record<string, unknown>,
                             TransformedValues = Values,
                             R extends FormErrors | Promise<FormErrors> = FormErrors>
 (form: UseFormReturnType<Values, TransformedValues, R>, queryResult: Values): void;

export function useFormQuery<Values extends Record<string, unknown>,
                             TransformedValues = Values,
                             Rules extends FormRulesRecord<Values> = FormRulesRecord<Values>>
 (form: UseFormReturnType<Values, TransformedValues, Rules>, queryResult: Values): void;

export function useFormQuery<Values extends Record<string, unknown>,
                             TransformedValues = Values>
 (form: UseFormReturnType<Values, TransformedValues>, queryResult: Values)
{

  useEffect (() =>
    {

      if (undefined === queryResult)
        return

      if (false === form.initialized)

        form.initialize (queryResult)
      else
        form.setInitialValues (queryResult)

    }, [form, queryResult])
}