/** @jsx jsx */
import { jsx } from '@emotion/core'
import React from "react";
import {
  Loading,
  Tab,
  Tabs,
  TabList,
  TabPanel
} from "@umich-lib/core";

import ItemStatusList from './item_status_list'

class StatusReport extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isFetching: false,
      pending: [],
      failed: [],
      done: [],
    };
  }

  render() {
    const isFetching = this.state.isFetching;
    const pending = this.state.pending;
    const failed  = this.state.failed;
    const done    = this.state.done;

    return (isFetching ? <Loading/> :
      <Tabs>
        <TabList>
          <Tab>Failed ({failed.length})</Tab>
          <Tab>Pending ({pending.length})</Tab>
          <Tab>Done ({done.length})</Tab>
        </TabList>

        <TabPanel>
          <ItemStatusList items={failed} />
        </TabPanel>
        <TabPanel>
          <ItemStatusList items={pending} />
        </TabPanel>
        <TabPanel>
          <ItemStatusList items={done} />
        </TabPanel>
      </Tabs>
    );
  }

  componentDidMount() {
    this.fetchReport();
  }

  fetchReport() {
    this.setState({...this.state, isFetching: true});
    fetch(this.apiPath("v1/queue/status"))
      .then(response => response.json())
      .then(data => {
        this.setState({...data, isFetching: false});
      })
      .catch(e => {
        this.setState({...this.state, isFetching: false});
      });
  }

  apiPath(path) {
    if (this.props.api) {
      return this.props.api + path;
    } else {
      return path;
    }
  }
}

export default StatusReport;
