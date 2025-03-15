import React from "react";

import { Meta } from "~/types/model/Meta";

type PaginationType = Pick<
  Meta,
  "currentPage" | "nextPage" | "prevPage" | "totalPages" | "totalCount" | "displayingInfo"
>;
type PropsType = {
  onNavigate: (page: number) => void;
} & PaginationType;

export default function Pagination({
  currentPage = 1,
  nextPage = null,
  prevPage = null,
  totalPages = 1,
  totalCount = 0,
  displayingInfo = {
    from: 0,
    to: 0,
  },
  onNavigate,
}: PropsType) {
  const isShowPrevBtn = totalPages > 1 && prevPage !== null && currentPage > 1;
  const isShowNextBtn = totalPages > 1 && nextPage !== null && currentPage < totalPages;
  const isShowDisplayingInfo = displayingInfo.from !== 0 && displayingInfo.to !== 0;

  const navigateButtonsRenderer = () => {
    return Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
      <span
        key={page}
        className={`page ${page === currentPage ? "active" : ""}`}
      >
        {currentPage === page ? (
          page
        ) : (
          <a
            href="#"
            onClick={(e) => {
              e.preventDefault();
              onNavigate(page);
            }}
          >
            {page}
          </a>
        )}
      </span>
    ));
  };

  return (
    <>
      {isShowDisplayingInfo &&
        (totalPages === 1 ? (
          <p className="mt-4">
            <span className="pagy-info">
              Displaying <b>{totalCount}</b> items
            </span>
          </p>
        ) : (
          <p className="mt-4">
            <span className="pagy-info">
              Displaying items{" "}
              <b>
                {displayingInfo.from}-{displayingInfo.to}
              </b>{" "}
              of <b>{totalCount}</b> in total
            </span>
          </p>
        ))}

      {totalCount > 0 && (
        <div className="mt-4 mb-4 text-center">
          <div className="pic-it-pagination">
            {isShowPrevBtn && (
              <i className="o-icon-arrow-left" onClick={() => onNavigate(currentPage - 1)}></i>
            )}
            <nav className="pagy-nav pagination">{navigateButtonsRenderer()}</nav>
            {isShowNextBtn && (
              <i className="o-icon-arrow-right" onClick={() => onNavigate(currentPage + 1)}></i>
            )}
          </div>
        </div>
      )}
    </>
  );
}
