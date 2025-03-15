import React from "react";

export type noticeDataType = {
  isShowNotice: boolean;
  message: string;
  type?: "error" | "success";
  duration?: number;
};

export const initialNoticeData = {
  isShowNotice: false,
  message: "",
};

type noticeProps = noticeDataType & {
  onSetShowNoticeFalse: () => void;
};

export default function Notice(props: noticeProps) {
  const { isShowNotice, onSetShowNoticeFalse, message, type, duration } = props;

  let typeClass = "o-callout--color-primary";
  if (type === "error") {
    typeClass = "o-callout--color-red";
  } else if (type === "success") {
    typeClass = "o-callout--color-green";
  }

  const noticeElement = document.querySelector(".callout-container");

  const handleShowNotice = () => {
    noticeElement?.classList.remove("hidden");
  };

  const handleHideNotice = () => {
    noticeElement?.classList.add("hidden");
  };

  if (isShowNotice) {
    handleShowNotice();
    if (duration) {
      setTimeout(() => {
        handleHideNotice();
        onSetShowNoticeFalse();
      }, duration);
    }
  }

  return (
    <div className="callout-container hidden">
      <div
        className={`o-callout o-callout--action o-callout--shadow js--callout-dismissable ${typeClass}`}
      >
        <p>{message}</p>
      </div>
    </div>
  );
}
