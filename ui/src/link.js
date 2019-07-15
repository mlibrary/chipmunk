/** @jsx jsx */
import { jsx } from '@emotion/core'
import { Link as RouterLink } from "react-router-dom";

import {
  Link as UmichCoreLink,
  LINK_STYLES
} from "@umich-lib/core"

/*
  The Design System Link can't use your router library Link,
  so it expsoes LINK_STYLES to compose the DS Link with
  your routing Link.

  The Router Link is only for internal links.

  The DS Link can be used for external links.
*/
function Link({ to, kind = 'default', ...other }) {
  /*
    The check if the href is an internal link.
  */
  if (to.startsWith('/')) {
    return (
      <RouterLink
        to={to}
      ><span css={{
        display: 'inline-block',
        ...LINK_STYLES[kind]
      }} {...other} /></RouterLink>
    )
  }

  // A regular anchor link. Probably an external link.
  return (
    <UmichCoreLink href={to} {...other} kind={kind} />
  )
}

export default Link
