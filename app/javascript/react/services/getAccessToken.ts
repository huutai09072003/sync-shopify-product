import createApp from "@shopify/app-bridge";
import { getSessionToken } from "@shopify/app-bridge/utilities";

export const getAccessToken = async () => {
  const { apiKey, host, basename } = document.getElementById("shopify-app-init")?.dataset || {};

  if (!apiKey || !host || (basename && window.location.href.includes(basename))) {
    return;
  }

  const app = createApp({
    apiKey: apiKey,
    host: host,
  });
  return await getSessionToken(app);
};
