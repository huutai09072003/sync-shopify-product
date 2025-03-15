import React, { useCallback, useState } from "react";
import { Button, IconSource, Popover, ActionList } from "@shopify/polaris";
import { HorizontalDotsMinor } from "@shopify/polaris-icons";

import "./styles.scss";

type Props = {
  buttons: { label: string; icon?: IconSource; onClick: () => void }[];
};

export default function MoreActionDropdown(props: Props) {
  const { buttons } = props;
  const [popoverActive, setPopoverActive] = useState(false);

  const togglePopoverActive = useCallback(
    () => setPopoverActive((popoverActive) => !popoverActive),
    [],
  );

  const activator = (
    <div className="more-action-popover">
      <Button onClick={togglePopoverActive} icon={HorizontalDotsMinor} />
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
        items={buttons.map(({ icon, label, onClick }) => ({
          icon,
          content: label,
          onAction: () => {
            onClick();
            togglePopoverActive();
          },
        }))}
      />
    </Popover>
  );
}
