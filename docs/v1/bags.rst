v1/bags
=======

.. http:get:: /v1/bags
    :deprecated:

    List all bags. No pagination is provided in this version.
    *This method is deprecated and will be removed in v2.*

    :reqheader Authorization: Bearer token

    :resheader Content-Type: application/json
    :resjson uuid bag_id: bag's id
    :resjson string user: Owning user's username
    :resjson enum content_type: The content type of the object.
    :resjson string external_id: The package's id in its external service
    :resjson url upload_link: Rsync link client should use to upload package
    :resjson filepath storage_location: The location of the bag on disk. This
      field is only shown to admins.
    :resjson boolean stored: Whether the package has been stored for preservation.
    :resjson date created_at: Datetime when the object was created
    :resjson date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated

.. http:get:: /v1/bags/(uuid:bag_id)
    :deprecated:

    Show a specific bag.
    *This method is deprecated and will be removed in v2.*

    :reqheader Authorization: Bearer token
    :parameter uuid bag_id: Bag's id

    :resheader Content-Type: application/json
    :resjson uuid bag_id: bag's id
    :resjson string user: Owning user's username
    :resjson enum content_type: The content type of the object.
    :resjson string external_id: The package's id in its external service
    :resjson url upload_link: Rsync link client should use to upload package
    :resjson filepath storage_location: The location of the bag on disk. This
      field is only shown to admins.
    :resjson boolean stored: Whether the package has been stored for preservation.
    :resjson array files: The list of files in the bag.
    :resjson date created_at: Datetime when the object was created
    :resjson date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated
    :statuscode 403: User does not own the resource, and is not an admin.
    :statuscode 404: Not found

.. http:get:: /v1/bags/(uuid:bag_id)/events
    :deprecated:

    List all events for the given bag. No pagination is provided in this version.
    *This method is deprecated and will be removed in v2.*

    :reqheader Authorization: Bearer token
    :parameter uuid bag_id: Bag's id

    :resheader Content-Type: application/json
    :resjsonarr int id: The event's id
    :resjsonarr string type: The event's type.
    :resjsonarr string executor: The user's username
    :resjsonarr string outcome: The result of the invent, whether it succeeded
      or failed.
    :resjsonarr string detail: Detailed information about the event.
    :resjsonarr date date: When the event was created

    :statuscode 200: Success
    :statuscode 401: Unauthenticated
    :statuscode 403: User does not own the resource, and is not an admin.
    :statuscode 404: Not found

