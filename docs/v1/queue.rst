v1/queue
========

.. http:get:: /v1/queue

    List the current user's queue items. While the task a queue item represents is still
    processing, its status will be ``pending``. Completed, successful tasks will have status
    ``done``, and will have a reference to the created package. Unsuccessful tasks will have
    status ``FAILED``, and an array of errors.

    :reqheader Authorization: Bearer token
    :parameter id: Queue item's id. This id is not the same as the bag's id.

    :resheader Content-Type: application/json
    :resjsonarr id: Queue entry's id
    :resjsonarr string status: One of ``pending``, ``done``, or ``failed``
    :resjsonarr url request: Relative URL to the request
    :resjsonarr url package: Relative URL to the created package. This field is
      not present unless status is ``done``.
    :resjsonarr string_array error: An array of errors encountered while validating
      the bag. This field is not present unless the status is ``failed``.
    :resjsonarr date created_at: Datetime when the object was created
    :resjsonarr date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated

.. http:get:: /v1/queue/(id)

    Return a specific queue item. While the task the queue item represents is still processing,
    its status will be PENDING. Completed, successful tasks will have status DONE, and will
    have a reference to the created bag. Unsuccessful tasks will have status FAILED, and an
    array of errors.

    :reqheader Authorization: Bearer token
    :parameter id: Queue item's id. This id is not the same as the bag's id.

    :resheader Content-Type: application/json
    :resjson id: Queue entry's id
    :resjson string status: One of ``pending``, ``done``, or ``failed``
    :resjson url request: Relative URL to the request
    :resjson url package: Relative URL to the created package. This field is
      not present unless status is ``done``.
    :resjson string_array error: An array of errors encountered while validating
      the bag. This field is not present unless the status is ``failed``.
    :resjson date created_at: Datetime when the object was created
    :resjson date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated
    :statuscode 403: User does not own the resource, and is not an admin.
    :statuscode 404: Not found
