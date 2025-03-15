import React, { useCallback, useEffect, useState } from "react";
import { ColorPicker, hexToRgb, HSBColor, hsbToHex, Popover, rgbToHsb } from "@shopify/polaris";

type PolarisColorPickerProps = {
  value: string;
  onSetColor: (value: string) => void;
};

export default function PolarisColorPicker(props: PolarisColorPickerProps) {
  const { value, onSetColor } = props;

  const firstInitColorRef = React.useRef(false);
  const [isShowPicker, setIsShowPicker] = useState(false);

  const hexToHSB = (hex: string): HSBColor => {
    const rgb = hexToRgb(hex);
    return rgbToHsb(rgb);
  };

  const [color, setColor] = useState<HSBColor>({
    hue: 0,
    brightness: 0,
    saturation: 0,
  });

  const handleSetColor = (color: HSBColor) => {
    setColor(color);
    const hex = hsbToHex(color);
    onSetColor(hex);
  };

  useEffect(() => {
    if (value && !firstInitColorRef.current) {
      // only set color for the first time
      setColor(hexToHSB(value));
      firstInitColorRef.current = true;
    }
  }, [value]);

  const toggleShowHidePicker = useCallback(
    () => setIsShowPicker((isShowPicker) => !isShowPicker),
    [],
  );

  const activator = (
    <div
      style={{
        width: 42,
        height: 42,
        backgroundColor: value,
        borderRadius: 10,
        border: "1px solid #CFCFCF",
        cursor: "pointer",
      }}
      onClick={toggleShowHidePicker}
    ></div>
  );

  return (
    <Popover
      active={isShowPicker}
      activator={activator}
      autofocusTarget="first-node"
      onClose={toggleShowHidePicker}
    >
      <ColorPicker onChange={handleSetColor} color={color} />
    </Popover>
  );
}
