import { useMemo } from 'react'
import debounce from '~/services/debounce'

export const useDebounce = <F extends (...args: any[]) => void>(
  func: F,
  dependencies: any[],
  delay: number = 300
): ((...args: Parameters<F>) => void) => {
  // eslint-disable-next-line react-hooks/exhaustive-deps
  return useMemo(() => debounce<F>(func, delay), dependencies)
}
