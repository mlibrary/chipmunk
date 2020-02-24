/** @jsx jsx */
import { jsx } from '@emotion/core'
import React, { Fragment } from 'react'
import Moment from 'react-moment'

import {
  COLORS
} from '@umich-lib/styles'

import Link from './link'

const FailedDeposit = {
  borderBottom: '0'
}

const ErrorMessage = {
  background: COLORS.orange[100],
  border: `1px solid ${COLORS.orange[200]}`,
  fontFamily: 'monospace',
  fontSize: '.8rem',
  overflowX: 'auto'
};

class ItemStatus extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isExpanded: false
    };
  }

  render() {
    // TODO: Add a toggle for error messages; expand-all/collapse-all for the table
    //const isExpanded = this.state.isExpanded;
    const artifact = this.props.item.package;
    const item = this.props.item;

    return (
      <Fragment>
        <tr id={"qi_" + item.id} style={item.error && FailedDeposit}>
          <td key="id"><Link to={"/artifacts/" + artifact.external_id}>{artifact.external_id}</Link></td>
          <td key="type" >{artifact.content_type}</td>
          <td key="bagid">{artifact.bag_id}</td>
          <td key="created"><Moment format="MM/DD/YYYY - h:mm a" date={item.updated_at} /></td>
          <td key="updated"><Moment format="MM/DD/YYYY - h:mm a" date={item.updated_at} /></td>
        </tr>
        { item.error &&
        <tr data-for-qi={"qi_" + item.id}>
          <td colspan="5">
            <pre style={ErrorMessage}>{item.error}</pre>
          </td>
        </tr>
        }
      </Fragment>
    );
  }
}

export default ItemStatus;
