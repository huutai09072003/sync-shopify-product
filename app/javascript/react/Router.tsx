import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Provider } from "react-redux";

import { store } from "./redux/store";
import Dashboard from "./pages/Dashboard";
import Products from "./pages/ShopifyProducts/LocalShopifyProductsIndex";
import Backgrounds from "./pages/Backgrounds";
import Settings from "./pages/Settings";
import Help from "./pages/Help";
import EditProduct from "./pages/EditProduct";
import BackgroundDetail from "./pages/BackgroundDetail";
import Subscription from "./pages/Subscription";
import { RouterWrapper } from "./components/RouterWrapper";

import "./styles/global.scss";
import PrivateRoute from "./components/PrivateRoute";

export default function Router() {
  const basename = document.getElementById("shopify-app-init")?.dataset.basename || "";

  return (
    <Provider store={store}>
      <RouterWrapper>
        <BrowserRouter basename={basename}>
          <Routes>
            <Route
              path="/"
              element={
                <PrivateRoute>
                  <Dashboard />
                </PrivateRoute>
              }
            />
            <Route
              path="/products"
              element={
                <PrivateRoute>
                  <Products />
                </PrivateRoute>
              }
            />
            <Route
              path="/products/:id/edit"
              element={
                <PrivateRoute>
                  <EditProduct />
                </PrivateRoute>
              }
            />
            <Route
              path="/background_collections"
              element={
                <PrivateRoute>
                  <Backgrounds />
                </PrivateRoute>
              }
            />
            <Route
              path="/background_collections/:slug"
              element={
                <PrivateRoute>
                  <BackgroundDetail />
                </PrivateRoute>
              }
            />
            <Route
              path="/background_collections/:id/edit"
              element={
                <PrivateRoute>
                  <BackgroundDetail />
                </PrivateRoute>
              }
            />
            <Route
              path="/settings"
              element={
                <PrivateRoute>
                  <Settings />
                </PrivateRoute>
              }
            />
            <Route
              path="/help"
              element={
                <PrivateRoute>
                  <Help />
                </PrivateRoute>
              }
            />
            <Route path="/subscription" element={<Subscription />} />
          </Routes>
        </BrowserRouter>
      </RouterWrapper>
    </Provider>
  );
}
