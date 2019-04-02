Chipmunk
========

.. image:: https://travis-ci.org/mlibrary/chipmunk.svg?branch=master
    :target: https://travis-ci.org/mlibrary/chipmunk
.. image:: https://coveralls.io/repos/github/mlibrary/chipmunk/badge.svg?branch=master
    :target: https://coveralls.io/github/mlibrary/chipmunk?branch=master
.. image:: https://img.shields.io/badge/API_docs-rubydoc.info-blue.svg
    :target: https://www.rubydoc.info/github/mlibrary/chipmunk
.. image:: https://readthedocs.org/projects/chipmunk/badge/?version=latest
    target: https://chipmunk.readthedocs.io/en/latest/?badge=latest

----

Chipmunk is a Rails-based ruby application implementing a RESTful interface. It handles core
CRUD operations, upload workflows, querying, and validation for dark digital preservation
repositories.


Digital Preservation Characteristics
------------------------------------

For further description of these terms, see
`this document <https://tools.lib.umich.edu/confluence/display/LIT/Digital+Preservation+Principles>`_.

- Enforced validation of content
- Storage auditing:

  - fixity of individual objects
  - fixity of the entire repository

- Content stored as regular files recoverable from disk
- Access-control based on associations between users and their content
- Preservation copy is held
- Does not contain metadata, but holds references to external metadata


Overview and Usage
------------------

User's make use of the purpose-build chipmunk-client to upload BagIt bags they have prepared for
ingest. The client uses standard HTTP verbs to request the server accept the upload. Upon receipt,
the server enforces consistency of the package via purpose-built validations.

Clients also have the ability to download packages or individual files in packages.

Fixity can be audited by admins via this same interface.


More Information
----------------

.. toctree::
    :maxdepth: 2
    :caption: Contents:

    contributing
    endpoints
    workflows
    API Reference <https://www.rubydoc.info/github/mlibrary/chipmunk>

