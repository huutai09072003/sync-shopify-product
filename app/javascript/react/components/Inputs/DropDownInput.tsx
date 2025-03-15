import React, { useEffect, useRef, useState } from "react";

type itemType = {
  value: number | string;
  label: string;
};

type dropDownInputProps = {
  id: string;
  name?: string;
  inputLabel: string;
  value: string | number | null;
  items: itemType[];
  onSelectItem: (value: string | number) => void;
};

export default function DropDownInput(props: dropDownInputProps) {
  const { id, name = id, inputLabel, value, items, onSelectItem } = props;
  const label = items.find((item) => item.value === value)?.label;

  const [isDropDownOpen, setIsDropDownOpen] = useState<boolean>(false);

  const wrapperRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) {
        setIsDropDownOpen(false);
      }
    };

    document.addEventListener("click", handleClickOutside);

    return () => {
      document.removeEventListener("click", handleClickOutside);
    };
  }, []);

  return (
    <div className="o-form__item">
      <div
        ref={wrapperRef}
        id={id}
        className={`o-form-dropdown ${isDropDownOpen ? "is-open" : ""} ${label ? "has-value" : ""}`}
        onClick={() => setIsDropDownOpen(!isDropDownOpen)}
      >
        <label htmlFor={id} className="o-form-dropdown__label">
          {inputLabel}
        </label>

        <input id={id} name={name} className="o-form-dropdown__input" placeholder={inputLabel} />

        <div className="o-form-dropdown__text">{label || "Select"}</div>

        <div className="o-form-dropdown__icon">
          <svg viewBox="0 0 24 24">
            <path
              fill="#000000"
              d="M7.41,8.58L12,13.17L16.59,8.58L18,10L12,16L6,10L7.41,8.58Z"
            ></path>
          </svg>

          <svg viewBox="0 0 24 24">
            <path
              fill="#000000"
              d="M7.41,8.58L12,13.17L16.59,8.58L18,10L12,16L6,10L7.41,8.58Z"
            ></path>
          </svg>
        </div>

        <div className="o-form-dropdown__content">
          <ul className="o-form-dropdown__menu">
            {items.map((item) => (
              <li key={item.value} onClick={() => onSelectItem(item.value)}>
                {item.label}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
