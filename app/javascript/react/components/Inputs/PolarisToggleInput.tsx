import { Text } from "@shopify/polaris";
import React from "react";

type toggleInputProps = {
  value: boolean;
  label?: string;
  onSetToggle: () => void;
  className?: string;
  isDisabled?: boolean;
  color?: string;
  size?: string;
  style?: React.CSSProperties;
};

export default function PolarisToggleInput(props: toggleInputProps) {
  const {
    label = "",
    value,
    onSetToggle,
    className = "",
    isDisabled = false,
    color,
    size,
    style = {},
  } = props;

  const toggleClasses = `o-toggle toggle-wrap ${value ? "is-checked" : ""} ${
    isDisabled ? "is-disabled" : ""
  }`;

  return (
    <div className={toggleClasses} onClick={onSetToggle}>
      <Text variant="bodyMd" as="p" tone={isDisabled ? "subdued" : undefined}>
        {label}
      </Text>
      <div className="o-toggle__button">
        <label className="o-toggle__label">{size !== "large" && <span>{label}</span>}</label>
        <input type="checkbox" className="o-toggle__input" disabled={isDisabled} />
      </div>
    </div>
  );
}
