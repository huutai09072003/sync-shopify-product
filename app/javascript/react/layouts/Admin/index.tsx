import React from "react";

import "./styles.scss";
import { Frame } from "@shopify/polaris";

interface IProps {
  children?: React.ReactNode;
  title?: string | React.ReactNode;
  subnav?: React.ReactNode;
  cta?: React.ReactNode;
  className?: React.ReactNode;
}

export default function Admin({ title, children, subnav, cta, className }: IProps) {
  const { basename = "", shopOrigin = "" } =
    document.getElementById("shopify-app-init")?.dataset || {};

  return (
    <div className="admin-container">
      {basename.length ? (
        <div className="o-callout o-callout--action o-callout-dismissable o-callout--color-primary o-callout--shadow">
          <p>
            Logged in as: {shopOrigin} |{" "}
            <a style={{ color: "#fff" }} href="/logout">
              Log out
            </a>
          </p>
        </div>
      ) : (
        ""
      )}
      <Frame>{children}</Frame>
    </div>
  );
}
