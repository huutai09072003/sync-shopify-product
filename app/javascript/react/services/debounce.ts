const debounce = <F extends (...args: any[]) => void>(
  func: F,
  delay: number = 300,
): ((...args: Parameters<F>) => void) => {
  let timeoutId: NodeJS.Timeout;

  return function (...args: Parameters<F>) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
};

export default debounce;
