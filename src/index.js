import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter, Route } from "react-router-dom";
import { Margins, UniversalHeader, Heading, GlobalStyleSheet, SPACING } from "@umich-lib/core";
import ArtifactSearch from "./artifact_search";
import ArtifactView from "./artifact_view";
import StatusReport from "./status_report";
import errorMessage from "./error_message";

export const API_URL = process.env.REACT_APP_API_URL;
export const APP_URL = process.env.REACT_APP_APP_URL || API_URL;
export const REPO_NAME = process.env.REACT_APP_REPO_NAME;

function App() {
  return (
    <div>
      <GlobalStyleSheet/>
      <UniversalHeader/>

      <Margins>
        <main>
          <Heading level={1} size="3XL" style={{
            marginTop: SPACING['2XL'],
            marginBottom: SPACING['XL']
          }}>{REPO_NAME}</Heading>
          <BrowserRouter>
            <Route path="/" exact component={SearchWrapper}/>
            <Route path="/artifacts/:id" component={DirectArtifact}/>
            <Route path="/status" render={() => <StatusReport api={API_URL} />}/>
          </BrowserRouter>
        </main>
      </Margins>
    </div>
  );
}

function SearchWrapper() {
  return (
    <div style={{
        maxWidth: '38rem'
    }}>
      <ArtifactSearch api={API_URL} />
    </div>
  );
}

function DirectArtifact({ match }) {
  return (
    <div style={{
        maxWidth: '38rem'
    }}>
      <ErroringArtifact id={match.params.id}/>
    </div>
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

