import React, { useState } from "react";
import { TextInput, Button } from "@umich-lib/core";

function SearchBar(props) {
  const [identifierQuery, setIdentifierQuery] = useState(props.value || "");
  const id = props.id || "the_only_search_field";

  function handleSubmit(e) {
    e.preventDefault();
    props.onHandleSubmit(identifierQuery);
  }

  return (
    <form onSubmit={handleSubmit}>
      <TextInput
        invalid={props.error ? true : false}
        invalidText={props.error}
        id={id}
        labelText="Artifact Identifier"
        value={identifierQuery}
        onChange={(e) => setIdentifierQuery(e.target.value)}
        type="text"
        descriptionText="We'll use this to find and retrieve your artifact."
      />

      <Button type="submit" style={{ marginTop: '1rem' }}>Find</Button>
    </form>
  );
}

export default SearchBar;
