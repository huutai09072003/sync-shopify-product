const generateIndividualQueryString = (searchParams, key, value) => {
  if (Array.isArray(value)) {
    value.map((value) => {
      generateIndividualQueryString(searchParams, `${key}[]`, value);
    });
  } else if (value !== null && typeof value === "object") {
    Object.entries(value)
      .map(([objKey, objValue]) => {
        generateIndividualQueryString(
          searchParams,
          `${key}[${objKey}]`,
          objValue
        );
      })
      .join("&");
  } else {
    searchParams.append(key, value);
  }
};

export default function generateQueryString(query) {
  const searchParams = new URLSearchParams();

  Object.entries(query || {}).map(([key, value]) => {
    generateIndividualQueryString(searchParams, key, value);
  });

  const params = searchParams.toString();
  return params.length ? `?${params}` : "";
}
