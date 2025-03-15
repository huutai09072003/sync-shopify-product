import React from "react";
import { Spinner as PolarisSpinner, SpinnerProps } from "@shopify/polaris";

import "./styles.scss";

interface PropsType {
  children: React.ReactNode;
  loading: boolean;
  containerClassName?: string;
  loadingMarkClassName?: string;
}

export default function Spinner({
  children,
  loading,
  containerClassName = "",
  loadingMarkClassName = "",
  ...spinnerProps
}: PropsType & SpinnerProps) {
  return (
    <div className={`spinner-loading-parent--relative ${containerClassName}`}>
      {children}
      <div
        className={`spinner-loading-mark ${loading ? "" : "hide-spinner"} ${loadingMarkClassName}`}
      >
        <div className="spinner-loading">
          <PolarisSpinner {...spinnerProps} />
        </div>
      </div>
    </div>
  );
}
