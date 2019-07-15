import React from "react";
import FileLink from "./file_link";
import { List } from "@umich-lib/core";

function FileList(props) {
  const files = props.files || [];
  const base = props.base || null;

  return (
    <List type="bulleted">
      {files.map(filename => (
        <li key={filename}><FileLink base={base}>{filename}</FileLink></li>
      ))}
    </List>
  );
}

export default FileList;
