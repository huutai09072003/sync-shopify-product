import React from "react";
import { SaveBar as ShopifySaveBar, useAppBridge } from "@shopify/app-bridge-react";

type Props = {
  onSave?: () => void;
  onDiscard?: () => void;
  isLoading?: boolean;
};

export default function SaveBar(props: Props) {
  const { onSave, onDiscard, isLoading = false } = props;

  const shopify = useAppBridge();

  return (
    <ShopifySaveBar id="save-bar">
      <button
        type="submit"
        variant="primary"
        onClick={() => {
          onSave && onSave();
        }}
        loading={isLoading ? "" : undefined}
      />
      <button
        type="button"
        onClick={() => {
          onDiscard && onDiscard();
          shopify.saveBar.hide("save-bar");
        }}
        disabled={isLoading}
      />
    </ShopifySaveBar>
  );
}
