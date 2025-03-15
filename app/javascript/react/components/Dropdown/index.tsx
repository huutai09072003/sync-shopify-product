import React, { useCallback, useState } from "react";
import { ActionList, Button, Popover } from "@shopify/polaris";

import "./styles.scss";

export type DropdownItem = {
  id: number;
  value: string | number | null;
  label: string;
};

type Props = {
  options: DropdownItem[];
  selectedItem: DropdownItem;
  onSelect: (item: DropdownItem) => void;
};

export default function Dropdown(props: Props) {
  const { options, selectedItem, onSelect } = props;

  const [popoverActive, setPopoverActive] = useState(false);

  const togglePopoverActive = useCallback(
    () => setPopoverActive((popoverActive) => !popoverActive),
    [],
  );

  const activator = (
    <div className="popover">
      <Button onClick={togglePopoverActive} disclosure>
        {selectedItem.label}
      </Button>
    </div>
  );

  return (
    <Popover
      active={popoverActive}
      activator={activator}
      autofocusTarget="first-node"
      onClose={togglePopoverActive}
    >
      <ActionList
        actionRole="menuitem"
        items={options.map((item) => ({
          content: item.label,
          onAction: () => {
            onSelect(item);
            togglePopoverActive();
          },
        }))}
      />
    </Popover>
  );
}
