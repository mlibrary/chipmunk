Workflows
=========

Upload and Validation
~~~~~~~~~~~~~~~~~~~~~~~

This workflow allows a client to upload a new package, which is then validated.
The client polls the server for changes during the validation step.

.. uml::

    @startuml
    hide footbox
    Client -> Server: POST v1/requests
    Client <- Server: 201 or 303 Location: v1/requests/bag_id
    Client -> Server: GET v1/requests/bag_id
    Client <- Server: 200, includes upload link
    Client --> Server: Upload the package
    Client -> Server: POST v1/requests/bag_id/complete
    Client <- Server: 201 or 303 Location: v1/queue/queue_id
    Client -> Server: GET v1/queue/queue_id
    Client <- Server: 200; client expected to poll for status
    @enduml


Viewing Packages
~~~~~~~~~~~~~~~~

To list all of one's packages:

.. uml::

    @startuml
    hide footbox
    Client -> Server: GET v1/packages
    Client <- Server: 200
    @enduml

To display just a single package:

.. uml::

    @startuml
    hide footbox
    Client -> Server: GET v1/packages/bag_id
    Client <- Server: 200
    @enduml

To download files from a package:

.. uml::

    @startuml
    hide footbox
    Client -> Server: GET v1/packages/bag_id
    Client <- Server: 200; the body will contain the list of files
    Client -> Server: GET v1/packages/bag_id/file-path
    Client <- Server: 200; X-Sendfile header used
    @enduml

(Admin only) Audit of the full repository:

.. uml::

    @startuml
    hide footbox
    Client -> Server: POST v1/audits
    Client <- Server: 201 Location: v1/audits/id
    Client -> Server: GET v1/audits/id
    Client <- Server: 200; client expected to poll for status
    @enduml




