import { useLocation, useNavigate } from "react-router";
import { useAppBridge } from "@shopify/app-bridge-react";

export const useGoBack = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const isInIframe = window.self !== window.top;
  const shopify = isInIframe ? useAppBridge() : undefined;

  const handleBackClick = async () => {
    try {
      if (shopify) {
        await shopify.saveBar.leaveConfirmation();
      }

      if (location.key !== "default") {
        navigate(-1);
      } else {
        navigate("/");
      }
    } catch (error) {
      console.error("Error in leave confirmation:", error);
    }
  };

  return { handleBackClick };
};
