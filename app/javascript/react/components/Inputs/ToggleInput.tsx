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

export default function ToggleInput(props: toggleInputProps) {
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

  const toggleClasses = `o-toggle o-toggle--label ${color ? `o-toggle--color-${color}` : ""} ${
    size ? `o-toggle--${size}` : ""
  } ${value ? "is-checked" : ""} ${isDisabled ? "is-disabled" : ""}`;

  return (
    <div className={`o-form__item ${className}`} style={style}>
      <div className={toggleClasses} onClick={onSetToggle}>
        <div className="o-toggle__button">
          <input type="checkbox" className="o-toggle__input" disabled={isDisabled} />

          <label className="o-toggle__label">{size !== "large" && <span>{label}</span>}</label>
        </div>

        {size === "large" && (
          <div>
            <label className="o-toggle__text">{label}</label>

            <div className={`o-toggle__value ${value ? "" : "o-toggle__value--disabled"}`}>
              {value ? "Enabled" : "Disabled"}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
