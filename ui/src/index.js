import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter, Route } from "react-router-dom";
import { Margins, UniversalHeader, Heading, GlobalStyleSheet, SPACING } from "@umich-lib/core";
import ArtifactSearch from "./artifact_search";
import ArtifactView from "./artifact_view";
import errorMessage from "./error_message";

const API_URL = process.env.REACT_APP_API_URL;
const REPO_NAME = process.env.REACT_APP_REPO_NAME;

function App() {
  return (
    <div>
      <GlobalStyleSheet/>
      <UniversalHeader/>

      <Margins>
        <main style={{
          maxWidth: '38rem'
        }}>
          <Heading level={1} size="3XL" style={{
            marginTop: SPACING['2XL'],
            marginBottom: SPACING['XL']
          }}>{REPO_NAME}</Heading>
          <BrowserRouter>
            <Route path="/" exact component={SearchWrapper}/>
            <Route path="/artifacts/:id" component={DirectArtifact}/>
          </BrowserRouter>
        </main>
      </Margins>
    </div>
  );
}

function SearchWrapper() {
  return (
    <ArtifactSearch api={API_URL} />
  );
}

function DirectArtifact({ match }) {
  return (
    <ErroringArtifact id={match.params.id}/>
  );
}

class ErroringArtifact extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      error: undefined
    }
  }

  render() {
    return (
      <ArtifactView
        api={API_URL}
        id={this.props.id}
        onError={e => { this.setError(e) }}
        error={this.state.error}
      />
    );
  }

  setError(code) {
    this.setState({ error: errorMessage(code, this.props.id) });
  }
}

const rootElement = document.getElementById("root");
ReactDOM.render(<App />, rootElement);
