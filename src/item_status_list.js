/** @jsx jsx */
import { jsx } from '@emotion/core'

import styled from '@emotion/styled'
import {
  COLORS
} from '@umich-lib/styles'

import ItemStatus from './item_status'

///////////////////////////////////////////
///// These are ripped off from the ResourceAccess component, which doesn't quite meet our need.
const FigureStyled = styled('figure')({
  overflowX: 'auto',
  overflowY: 'visible',
  margin: 0,
  padding: 0,
  'tr:not(:last-child)': {
    borderBottom: `solid 1px ${COLORS.neutral[100]}`
  }
})

const StyledTH = styled('th')({
  color: COLORS.neutral[300],
  borderBottom: `solid 2px ${COLORS.neutral[100]}`
})

const td_and_th = {
  padding: '0.5rem 0',
  textAlign: 'left',
  verticalAlign: 'top',
  '&:not(:last-child)': {
    paddingRight: '1rem'
  }
}

const TableStyled = styled('table')({
  borderCollapse: 'collapse',
  borderSpacing: '0',
  width: '100%',
  minWidth: '30rem',
  tableLayout: 'fixed',
  'tbody': {
    'tr:not(:last-child)': {
      borderBottom: `solid 1px ${COLORS.neutral[100]}`
    }
  },
  'td': td_and_th,
  'th': td_and_th
})
//////////////////////////////////////////////


const ItemStatusList = ({items}) => items.length === 0 ? <p>Nothing to list...</p> :
  <FigureStyled>
    <TableStyled>
      <thead>
        <tr>
          <StyledTH scope="col" width="25%" key="id">ID / Barcode</StyledTH>
          <StyledTH scope="col" width="10%" key="type">Type</StyledTH>
          <StyledTH scope="col" width="35%" key="bagid">Bag ID</StyledTH>
          <StyledTH scope="col" width="20%" key="created">Created</StyledTH>
          <StyledTH scope="col" width="20%" key="updated">Updated</StyledTH>
        </tr>
      </thead>
      <tbody>
        {items.map((item) => <ItemStatus key={item.id} item={item} />)}
      </tbody>
    </TableStyled>
  </FigureStyled>

export default ItemStatusList;
