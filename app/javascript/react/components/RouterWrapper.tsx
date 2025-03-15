import React, { useEffect } from "react";
import { useDispatch } from "react-redux";
import createApp from "@shopify/app-bridge";
import { Redirect } from "@shopify/app-bridge/actions";

import {
  apiSliceInvalidateTags,
  useGetShopPaidInGoodStandingQuery,
  useGetShopQuery,
} from "~/redux/slices/apiSlice";
import consumer from "~/services/consumer";
import {
  addIdToProductIdsThatIsRemovingTheBackgroundForTheImage,
  removeIdFromProductIdsThatIsRemovingTheBackgroundForTheImage,
  updateShop,
} from "~/redux/slices/shopSlice";
import { ShopChannelBroadcastType, ShopChannelData } from "~/types/model/ShopChannel";
import { impersonateMode } from "~/services/impersonateMode";

let shopSubscription: any;
let isCreatingRecurringApplicationCharge = false;

export function RouterWrapper({ children }: { children: React.ReactNode }) {
  const dispatch = useDispatch();

  const { data: shop } = useGetShopQuery();
  const { id: shopId } = shop || { id: 0 };
  const { data: { isPaidInGoodStanding } = { isPaidInGoodStanding: true } } =
    useGetShopPaidInGoodStandingQuery();
  const isImpersonateMode = impersonateMode();

  const handleUpgradingCharge = () => {
    // using approved_charge instead of paid_in_good_standing? for improved LCP performance
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

  if (!isPaidInGoodStanding && !isImpersonateMode && !isCreatingRecurringApplicationCharge) {
    isCreatingRecurringApplicationCharge = true;
    handleUpgradingCharge();
  }

  useEffect(() => {
    if (shopId !== 0) {
      shopSubscription = consumer.subscriptions.create(
        { channel: "ShopChannel", id: shopId },
        {
          connected() {
            console.debug("Connected to shop channel");
          },
          received({ type, data }: { type: ShopChannelBroadcastType; data: any }) {
            if (type === ShopChannelBroadcastType.BULK_ACTIVATE_STATUS) {
              const {
                bulkActivatingProducts,
                localShopifyProductOriginalIdsThatIsActivatingProduct,
                productIdsJustActivated,
              } = data as ShopChannelData["bulkActivateStatusData"];

              if (!bulkActivatingProducts) {
                const productDetailTags: { type: "Products"; id: number }[] =
                  productIdsJustActivated.map((id) => ({
                    type: "Products",
                    id,
                  }));

                dispatch(
                  apiSliceInvalidateTags([
                    ...productDetailTags,
                    { type: "Products", id: "LIST" },
                    { type: "ShopifyProducts", id: "LIST" },
                    { type: "LocalShopifyProducts", id: "LIST" },
                    { type: "Shop", id: "DETAIL" },
                  ]),
                );
              }

              dispatch(
                updateShop({
                  bulkActivatingProducts,
                  localShopifyProductOriginalIdsThatIsActivatingProduct,
                }),
              );
            }

            if (
              type ===
              ShopChannelBroadcastType.ADD_PRODUCT_ID_THAT_IS_REMOVING_THE_BACKGROUND_FOR_THE_IMAGE
            ) {
              const { productId } =
                data as ShopChannelData["addProductIdThatIsRemovingTheBackgroundForTheImage"];
              dispatch(addIdToProductIdsThatIsRemovingTheBackgroundForTheImage(productId));
            }

            if (
              type ===
              ShopChannelBroadcastType.REMOVE_PRODUCT_ID_THAT_IS_REMOVING_THE_BACKGROUND_FOR_THE_IMAGE
            ) {
              const { productId } =
                data as ShopChannelData["removeProductIdThatIsRemovingTheBackgroundForTheImage"];

              dispatch(
                apiSliceInvalidateTags([
                  { type: "Products", id: productId },
                  { type: "ProductImages", id: productId },
                ]),
              );
              dispatch(removeIdFromProductIdsThatIsRemovingTheBackgroundForTheImage(productId));
            }
          },
          disconnected() {
            console.debug("Disconnected from shop channel");
          },
        },
      );
    }

    return () => {
      if (!!shopSubscription) {
        shopSubscription.unsubscribe();
      }
    };
  }, [shopId]);

  return <>{children}</>;
}
