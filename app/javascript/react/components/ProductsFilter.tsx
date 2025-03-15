import React, { useEffect, useRef, useState } from "react";

import { GetProductsQuery } from "~/types/api/Query";

type filterItemsType = {
  id: number;
  label: GetProductsQuery["productFilter"];
};

const FILTER_ITEMS: filterItemsType[] = [
  {
    id: 1,
    label: "Most viewed",
  },
  {
    id: 2,
    label: "Least viewed",
  },
  {
    id: 3,
    label: "Recently added",
  },
];

type productsFilterProps = {
  onSetProductFilter: (label: GetProductsQuery["productFilter"]) => void;
  size?: string;
  isShowSortingText?: boolean;
};

export default function ProductsFilter(props: productsFilterProps) {
  const { onSetProductFilter, size = "large", isShowSortingText = false } = props;

  const [filterItem, setFilterItem] = useState<filterItemsType>({
    id: 0,
    label: "Most viewed",
  });
  const [isOpenDropdown, setIsOpenDropdown] = useState(false);

  const wrapperRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const handleClickOutFilter = (event: MouseEvent) => {
      if (
        wrapperRef.current &&
        !wrapperRef.current.contains(event.target as Node) &&
        isOpenDropdown
      ) {
        setIsOpenDropdown(false);
      }
    };
    document.addEventListener("click", handleClickOutFilter);

    return () => {
      document.removeEventListener("click", handleClickOutFilter);
    };
  }, [isOpenDropdown]);

  const handleFilterProduct = (item: filterItemsType) => {
    setFilterItem(item);
    setIsOpenDropdown(false);
    onSetProductFilter(item.label);
  };

  return (
    <>
      {isShowSortingText && !!filterItem.id && (
        <span id="product_filter_label" className="pr-2">
          Sorting by '{filterItem.label}'
        </span>
      )}

      <form className={`o-form o-form--${size}`}>
        <div className="o-form__item">
          <div
            id="productSortBy"
            className={`o-form-dropdown ${isOpenDropdown ? "is-open" : ""} ${
              filterItem.id ? "has-value" : ""
            }`}
            ref={wrapperRef}
          >
            <label
              htmlFor={`form_dropdown_${size}`}
              className="o-form-dropdown__label"
              onClick={() => setIsOpenDropdown(!isOpenDropdown)}
            >
              Filter by...
            </label>

            <input
              id={`form_dropdown_${size}`}
              type="text"
              name={`form_dropdown_${size}`}
              className="o-form-dropdown__input"
            />

            <div className="o-form-dropdown__text">
              {filterItem.id ? filterItem.label : "Filter by..."}
            </div>

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

            <div
              className="o-form-dropdown__content"
              style={{
                opacity: `${isOpenDropdown ? 1 : 0}`,
                visibility: `${isOpenDropdown ? "visible" : "hidden"}`,
              }}
            >
              <ul className="o-form-dropdown__menu">
                {FILTER_ITEMS.map((item) => (
                  <li key={item.label} onClick={() => handleFilterProduct(item)}>
                    {item.label}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </form>
    </>
  );
}
