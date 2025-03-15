import React, { useEffect, useState } from "react";
import { TwitterPicker } from "react-color";

const defaultColors = [
  "#f44336",
  "#e91e63",
  "#9c27b0",
  "#673ab7",
  "#3f51b5",
  "#2196f3",
  "#03a9f4",
  "#00bcd4",
  "#009688",
  "#4caf50",
  "#8bc34a",
  "#cddc39",
  "#ffeb3b",
  "#ffc107",
  "#ff9800",
  "#ff5722",
  "#795548",
  "#9e9e9e",
  "#ffffff",
  "#000000",
];

type colorPickerProps = {
  id: string;
  value: string;
  onSetColor: (value: string) => void;
};

export default function ColorPicker(props: colorPickerProps) {
  const { id, value, onSetColor } = props;

  const [isShowPicker, setIsShowPicker] = useState(false);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      const pickerElement = document.querySelector(`#${id}`);
      if (pickerElement && !pickerElement.contains(e.target as Node)) {
        setIsShowPicker(false);
      }
    };

    document.addEventListener("click", handleClickOutside);

    return () => {
      document.removeEventListener("click", handleClickOutside);
    };
  }, []);

  useEffect(() => {
    const tickElement = `
      <div
        style="display:flex; align-items:center; justify-content:center; position:absolute; width:100%; height:100%;"
      >
        <div
          style="display:flex; align-items:center; justify-content:center; width: 21px; height: 21px; border-radius: 50%; background-color: #00000026;"
        >
          <i class="o-icon-tick" style="color: #FFFFFF;"></i>
        </div>
      </div>`;

    if (document.querySelectorAll(".twitter-picker span div")) {
      const swatchArr = document.querySelectorAll(".twitter-picker span div");
      swatchArr.forEach((swatch) => {
        if (swatch.getAttribute("title") === value) {
          swatch.innerHTML = tickElement;
        }
      });
    }
  }, [isShowPicker]);

  const handleChangeColor = (color: string) => {
    onSetColor(color);
    setIsShowPicker(false);
  };

  return (
    <div id={id} style={{ position: "relative" }}>
      <div
        style={{
          width: 42,
          height: 42,
          backgroundColor: value,
          borderRadius: 10,
          border: "1px solid #CFCFCF",
          cursor: "pointer",
        }}
        onClick={() => setIsShowPicker(!isShowPicker)}
      ></div>

      {isShowPicker && (
        <TwitterPicker
          colors={defaultColors}
          width={240}
          onChange={({ hex }) => handleChangeColor(hex)}
          color={value}
          styles={{
            default: {
              card: {
                position: "absolute",
                zIndex: 50,
                top: 52,
              },
              body: {
                padding: "18px 0px 18px 18px",
              },
              swatch: {
                border: "1px solid #CFCFCF",
                borderRadius: 11,
                margin: "0px 11px 11px 0px",
                width: 42,
                height: 42,
              },
            },
          }}
        />
      )}
    </div>
  );
}
