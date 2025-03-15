export function convertKeysToSnakeCase(obj) {
  if (obj === null || typeof obj !== "object") {
    return obj;
  }

  return Object.keys(obj).reduce((acc, key) => {
    const snakeCaseKey = key.replace(/[A-Z]/g, (match) => `_${match.toLowerCase()}`);
    acc[snakeCaseKey] = convertKeysToSnakeCase(obj[key]);
    return acc;
  }, {});
}

export function convertKeysToLowerCamelCase(obj) {
  if (obj === null || typeof obj !== "object") {
    return obj;
  }

  return Object.keys(obj).reduce((acc, key) => {
    const camelCaseKey = key.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
    acc[camelCaseKey] = convertKeysToLowerCamelCase(obj[key]);
    return acc;
  }, {});
}
