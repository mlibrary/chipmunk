v1/requests
===========

.. http:get:: /v1/requests

    List all requests. No pagination is provided in this version.

    :reqheader Authorization: Bearer token

    :resheader Content-Type: application/json
    :resjson uuid bag_id: bag's id
    :resjson string user: Owning user's username
    :resjson enum content_type: The content type of the object.
    :resjson string external_id: The package's id in its external service
    :resjson url upload_link: Rsync link client should use to upload package
    :resjson filepath storage_location: The location of the package on disk. This
      field is only shown to admins.
    :resjson boolean stored: Whether the package has been stored for preservation.
    :resjson date created_at: Datetime when the object was created
    :resjson date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated

.. http:post:: /v1/requests

    Create a new request. Admins may specify the user. For regular users,
    this field is ignored.

    :reqheader Authorization: Bearer token
    :reqjson uuid bag_id: bag's id
    :reqjson enum content_type: The content type of the object.
    :reqjson string external_id: The package's id in its external service

    :resheader Content-Type: application/json
    :resheader Location: The location of the resource, /requests/(uuid:bag_id)

    :statuscode 201: Includes Location header with url to resource, /requests/bag_id.
    :statuscode 303: The result of a duplicate request. Includes location header
      as with 201.
    :statuscode 401: Unauthenticated
    :statuscode 422: Malformed POST body

.. http:get:: /v1/requests/(uuid:bag_id)

    Show a specific request

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
    :statuscode 403: User does not own the request, and is not an admin.
    :statuscode 404: Not found

.. http:post:: /v1/requests/(uuid:bag_id)/complete

    Notify the server that a request's upload has been completed.  :reqheader Authorization: Bearer token

    :parameter uuid bag_id: Bag's id

    :resheader Content-Type: application/json
    :resheader Location: The location of the resource, /queue/(id)

    :statuscode 201: Includes Location header
    :statuscode 303: The result of a duplicate request. Includes location header
      as with 201.
    :statuscode 401: Unauthenticated
    :statuscode 422: Malformed POST body


