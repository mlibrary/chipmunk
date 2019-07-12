import React from "react";
import Link from "./link";

function FileLink(props) {
  const text = props.children;
  const href = props.base ? (props.base + "/" + text) : text;

  return (
    <Link to={href}>{text}</Link>
  );
}

export default FileLink;
