/** @jsx jsx */
import { jsx } from '@emotion/core'
import React from "react";
import FileList from "./file_list";
import {
  Alert,
  Heading,
  Loading,
  SPACING,
  Z_SPACE
} from "@umich-lib/core";

import Link from './link'

class ArtifactView extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      id: null,
      isError: false,
      prevFetch: ""
    };
  }

  render() {
    if (this.props.error) {
      return (
        <Alert intent="error">{this.props.error}</Alert>
      );
    } else if (this.isErrorOrEmpty()) {
      return null;
    } else if (this.isLoaded()) {
      return (
        <div css={{
          ...Z_SPACE['8'],
          padding: SPACING['L']
        }}>
          { this.props.permalink
            ? <Link
                to={this.props.permalink + this.props.id}
                kind="description"
                css={{
                  marginBottom: SPACING['M']
                }}
              >
                <Heading level={2} size="S">{this.props.id}</Heading>
              </Link>
            : <Heading level={2} size="S">{this.props.id}</Heading> }
          <FileList
            base={this.apiPath("v1/packages", this.state.artifactResponse.bag_id)}
            files={this.state.artifactResponse.files}
          />
        </div>
      );
    } else {
      this.findArtifact();
      return (
        <Loading/>
      );
    }
  }

  isErrorOrEmpty() {
    return (this.isError()
            || this.props.id === ""
            || typeof this.props.id === "undefined");
  }

  isError() {
    return (this.state.isError && this.isLoaded());
  }

  isLoaded() {
    return (this.state.id === this.props.id);
  }

  findArtifact() {
    if (!this.fetchHasBeenRun()) {
      this.fetchCurrentArtifact().then(response => {
        if (this.responseSucceeded(response)) {
          this.handleSuccess(response);
        } else {
          this.handleError(response.status);
        }
      });
    }
  }

  fetchHasBeenRun() {
    return (this.state.prevFetch === this.props.id);
  }

  fetchCurrentArtifact() {
    return fetch(this.apiPath("v1/bags", this.props.id)).then(data => {
      this.setState({ prevFetch: this.props.id });
      return data;
    });
  }

  apiPath(path, item) {
    if (this.props.api) {
      return this.props.api + path + "/" + item;
    } else {
      return path + "/" + item;
    }
  }

  responseSucceeded(response) {
    return (response.status === 200);
  }

  handleSuccess(response) {
    response.json().then(responseBody => {
      this.addResponseToState(responseBody);
    }, () => {
      this.handleError(501);
    });
  }

  addResponseToState(response) {
    this.setState({
      artifactResponse: response,
      id: this.props.id,
      isError: false
    });
  }

  handleError(code) {
    if (this.props.onError) this.props.onError(code);
    this.setState({
      id: this.props.id,
      isError: true
    });
  }
}

export default ArtifactView;
