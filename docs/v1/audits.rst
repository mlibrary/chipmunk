v1/audits
=========

An audit is a check of the entire repository to ensure that it is intact. This
is typically described as testing the fixity of all of the repository's content.

.. http:get:: /v1/audits

    List all audits. No pagination is provided in this version.

    :reqheader Authorization: Bearer token

    :resheader Content-Type: application/json
    :resjsonarr int id: The audit's id
    :resjson string user: Owning user's username
    :resjsonarr int successes: The number of successful events thus far in
      this audit.
    :resjsonarr int failures: The number of failed events thus far in
      this audit.
    :resjsonarr int packages: The total number of packages in this audit.
    :resjsonarr date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated

.. http:post:: /v1/audits

    Audit the system; the logical audit is represented by the created resource.

    :reqheader Authorization: Bearer token

    :statuscode 201: Includes Location header with url to resource, /audits/id.
    :statuscode 401: Unauthenticated
    :statuscode 403: User is not an administrator.

.. http:get:: /v1/audits/(id)

    Show a specific audit. The audit may be completed, or it may still be in progress;
    compare the total count of successful and failed events against the count of
    packages being audited to determine if the audit is complete.

    :resheader Content-Type: application/json
    :resjson int id: The audit's id
    :resjson string user: Owning user's username
    :resjson array successes: An array of successful :doc:`events <events>`.
    :resjson array failures: An array of failed :doc:`events <events>`.
    :resjson int packages: The total number of packages in this audit.
    :resjson date updated_at: Datetime when the object was last changed

    :statuscode 200: Success
    :statuscode 401: Unauthenticated
    :statuscode 403: User does not own the resource, and is not an admin.
    :statuscode 404: Not found

