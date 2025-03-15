import React, { useRef } from "react";

type textInputProps = {
  id: string;
  name?: string;
  value: string;
  label: string;
  onChangeText: (value: string) => void;
};

export default function TextInput(props: textInputProps) {
  const { id, name = id, value, label, onChangeText } = props;

  const inputRef = useRef<HTMLInputElement>(null);

  if (value) {
    inputRef.current?.classList.toggle("has-value", !!value);
  }

  const handleChangeInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;

    onChangeText(newValue);
    e.target.classList.toggle("has-value", !!newValue);
  };

  return (
    <div className="o-form__item">
      <div className="o-form__input-wrapper">
        <input
          ref={inputRef}
          id={id}
          type="text"
          name={name}
          autoComplete="off"
          className="o-form__input"
          onKeyDown={(e) => {
            if (e.keyCode === 13) {
              e.preventDefault();
            }
          }}
          value={value}
          onChange={handleChangeInput}
        />

        <label htmlFor={id} className="o-form__label">
          {label}
        </label>
      </div>
    </div>
  );
}
