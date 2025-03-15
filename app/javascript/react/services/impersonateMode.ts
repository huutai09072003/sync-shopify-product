export const impersonateMode = (): boolean => {
  return (
    (document.getElementById("shopify-app-init")?.dataset.impersonateMode || "false") === "true"
  );
};
