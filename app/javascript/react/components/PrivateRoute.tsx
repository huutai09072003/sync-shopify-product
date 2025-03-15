import React, { useEffect } from "react";
import { Navigate } from "react-router-dom";
import createApp from "@shopify/app-bridge";
import { Redirect } from "@shopify/app-bridge/actions";

import { useGetShopPaidInGoodStandingQuery } from "~/redux/slices/apiSlice";
import { impersonateMode } from "~/services/impersonateMode";

export default function PrivateRoute({ children }) {
  const { data: { isPaidInGoodStanding } = { isPaidInGoodStanding: true } } =
    useGetShopPaidInGoodStandingQuery();
  const isImpersonateMode = impersonateMode();

  const handleUpgradingCharge = () => {
    const { apiKey, host, upgradingChargePath } =
      document.getElementById("shopify-app-init")?.dataset || {};

    if (!apiKey || !host || !upgradingChargePath) {
      console.error("Missing apiKey or host or upgradingChargePath");
      return;
    }

    const app = createApp({
      apiKey: apiKey,
      host: host,
    });
    const redirect = Redirect.create(app);
    redirect.dispatch(Redirect.Action.APP, upgradingChargePath);
  };

  useEffect(() => {
    if (!isPaidInGoodStanding && !isImpersonateMode) {
      handleUpgradingCharge();
    }
  }, [isPaidInGoodStanding, isImpersonateMode]);

  if (isPaidInGoodStanding || isImpersonateMode) {
    return children;
  }

  return <Navigate to="/subscription" />;
}
