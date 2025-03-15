import React from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";

import "./styles.scss";

type BackButtonProps = {
  shopify?: any;
};

export default function BackButton({ shopify }: BackButtonProps) {
  const navigate = useNavigate();
  const location = useLocation();

  const handleBackClick = async (e: React.MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();

    try {
      if (shopify) {
        await shopify.saveBar.leaveConfirmation();
      }

      if (location.key !== "default") {
        navigate(-1);
      }
    } catch (error) {
      console.error("Error in leave confirmation:", error);
    }
  };

  return (
    <nav className="view-section-bar__back o-breadcrumbs button-back-wrapper">
      <Link className="btn-white" to={"/"} onClick={handleBackClick}>
        <i className="o-icon-arrow-left" style={{ fontSize: "27px" }}></i>
      </Link>
    </nav>
  );
}
