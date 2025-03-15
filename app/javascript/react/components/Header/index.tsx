import React, { useEffect, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { Button } from "@shopify/polaris";
import { NavMenu } from "@shopify/app-bridge-react";

import Logo from "../Logo";
import { useGetShopQuery } from "~/redux/slices/apiSlice";
import "./styles.scss";
import { impersonateMode } from "~/services/impersonateMode";

const Header = () => {
  const [showFullMenu, setShowFullMenu] = useState(false);
  const isImpersonateMode = impersonateMode();
  const location = useLocation();
  const { pathname } = location;

  const { data: shop } = useGetShopQuery();
  const { shopifyProductCount, chargeName } = shop || { shopifyProductCount: 0, chargeName: null };

  useEffect(() => {
    if (chargeName !== null) {
      setShowFullMenu(true);
    }
  }, [chargeName]);

  const impersonateModePaths = [
    {
      path: "/",
      name: "Home",
    },
    {
      path: "/products",
      name: "My products",
      count: shopifyProductCount,
    },
    {
      path: "/background_collections",
      name: "Virtual showrooms",
    },
    {
      path: "/settings",
      name: "Settings",
    },
  ];

  const shopifyModePaths = showFullMenu
    ? [
        {
          path: "/products",
          name: "My products",
        },
        {
          path: "/background_collections",
          name: "Virtual showrooms",
        },
        {
          path: "/settings",
          name: "Settings",
        },
        {
          path: "/subscription",
          name: "Subscription",
        },
        {
          path: "/help",
          name: "Help",
        },
      ]
    : [];

  return (
    <>
      {isImpersonateMode ? (
        <header className="header">
          <div className="header-wrapper">
            <div className="header__logo left-header-wrapper">
              <Link to="/">
                <Logo />
              </Link>
            </div>

            <nav className="o-nav ml-auto center-header-wrapper">
              <ul style={{ overflowX: "auto", paddingBottom: "0px" }}>
                {impersonateModePaths.map(({ path, name, count }) => (
                  <li key={path}>
                    <Link
                      to={path}
                      className={
                        pathname === "/" && path === pathname
                          ? "is-active"
                          : pathname.startsWith(path) && path.length > 1
                          ? "is-active"
                          : ""
                      }
                    >
                      {name}
                      {count !== undefined ? <span className="products-count">{count}</span> : ""}
                    </Link>
                  </li>
                ))}
              </ul>
            </nav>

            <div className="right-header-wrapper">
              <Link to="/changelog">
                <Button icon={<i className="icon-Blog" />}>What's new</Button>
              </Link>

              <Link to="/help" className="ml-2">
                <Button icon={<i className="icon-QuestionMarkMajor" />} variant="primary">
                  Help
                </Button>
              </Link>
            </div>
          </div>
        </header>
      ) : (
        <NavMenu>
          {shopifyModePaths.map(({ path, name }) => (
            <Link
              key={path}
              to={path}
              className={
                pathname === "/" && path === pathname
                  ? "is-active"
                  : pathname.startsWith(path) && path.length > 1
                  ? "is-active"
                  : ""
              }
            >
              {name}
            </Link>
          ))}
        </NavMenu>
      )}
    </>
  );
};

export default Header;
