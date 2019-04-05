v1/events
=========

.. http:get:: /v1/events

    List all events. No pagination is provided in this version.

    :reqheader Authorization: Bearer token
    :parameter uuid bag_id: Bag's id

    :resheader Content-Type: application/json
    :resjsonarr int id: The event's id
    :resjsonarr string type: The event's type. Currently, the only type allowed
      is ``fixity check``.
    :resjsonarr string executor: The user's username
    :resjsonarr string outcome: The result of the invent, whether it succeeded
      or failed. Must be one of ``success`` or ``failed``.
    :resjsonarr string detail: Detailed information about the event.
    :resjsonarr date date: When the event was created

    :statuscode 200: Success
    :statuscode 401: Unauthenticated
    :statuscode 403: User does not own the resource, and is not an admin.
    :statuscode 404: Not found


