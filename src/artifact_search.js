import React from "react";
import SearchBar from "./search_bar";
import ArtifactView from "./artifact_view";
import errorMessage from "./error_message";

class ArtifactSearch extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      id: (props.value || ""),
      error: ""
    };
  }

  render() {
    return (
      <div>
        <SearchBar
          error={this.state.error}
          value={this.state.id}
          onHandleSubmit={(id) => { this.switchArtifact(id); }}
        />
        <br/>
        <ArtifactView
          api={this.props.api}
          id={this.state.id}
          onError={e => {this.setError(e)}}
          permalink="/artifacts/"
        />
      </div>
    );
  }

  switchArtifact(id) {
    this.setState({
      error: "",
      id: id
    });
  }

  setError(error) {
    this.setState({ error: errorMessage(error, this.state.id) });
  }
}

export default ArtifactSearch;
