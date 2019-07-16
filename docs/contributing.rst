Contributing
============

Development
-----------

- ``git clone https://github.com/mlibrary/chipmunk``
- ``bundle install``
- ``bundle exec rspec``

Running integration tests
-------------------------

This repository includes a Docker container that has all of the dependencies of the integration
tests pre-installed. You will need:

- Docker and Docker Compose
- The hathitrust/feed:jhove-1.6 and/or the hathitrust/feed:jhove-1.20 images. These can be
  built from the Dockerfiles in the official
  `HathiTrust Feed repository <https://github.com/hathitrust/feed/>`_. In the future, they
  may be uploaded to a public Docker registry.

Then you can launch the container with ``docker-compose run web bash``, which gives you a shell
within that container with your current source code mounted. From there, you can install gems
and run the specs as normal (``bundle install`` and ``bin/rspec``, respectively).

CLI / end-to-end testing
-----------------------

- Prerequisite: install ``rsync`` and set up the ability for the current user to use rsync over
  ssh to ``localhost`` (an ssh key is nice but not required).
- ``git clone``/``bundle install`` as usual
- Set up the authentication database: ``bundle exec rake keycard:migrate``
- Set up the authorization database: ``bundle exec rake checkpoint:migrate``
- Set up the database: ``bundle exec rake db:setup``
- Set up the repository and upload paths: ``bundle exec rake chipmunk:setup``
- Set up external validators in ``config/settings/development.local.yml`` (see
  example in ``development.yml``). For a simple test that doesn't require any
  pre-requisites, try using ``/bin/true``
- In another window, start the development server: ``bundle exec rails server``
- In another window, start the resque pool: ``bundle exec rake resque:pool``

With `chipmunk-client <https://www.github.com/mlibrary/chipmunk-client>`_:

- Configure ``chipmunk-client`` with the API key you got from ``bundle exec rake chipmunk:setup``
- (Optional) Bag some audio content: ``bundle exec ruby -I lib bin/makebag audio 39015012345678 /path/to/audio/material /path/to/output/bag``
- Try to upload a test bag: ``bundle exec ruby -I lib bin/upload spec/support/fixtures/audio/upload/good`` (or whatever bag you created before)
- Check the bag's status:

::

  curl -f -s -H "Authorization:Token token=YOUR_API_TOKEN" http://localhost:3000/v1/bags/EXTERNAL_ID | jq .

Which should result in something like:

::

  {
    "bag_id": "b2a07afc-800f-41c6-942d-91989aeed950",
    "user": "someuser",
    "content_type": "audio",
    "external_id": "EXTERNAL_ID",
    "upload_link": "localhost:/somewhere/chipmunk/incoming/b2a07afc-800f-41c6-942d-91989aeed950",
    "storage_location": "/somewhere/chipmunk/repo/storage/b2/a0/7a/b2a07afc-800f-41c6-942d-91989aeed950",
    "stored": true,
    "created_at": "2018-03-26 18:56:58 UTC",
    "updated_at": "2018-03-26 18:57:04 UTC"
  }

Then you can verify the bag is properly stored in the listed ``storage_location``.

Usage
-----

Server setup
^^^^^^^^^^^^

- (Optional) Set up a mysql database and configure appropriately in ``config/database.yml``
- Set the Rails secret key in ``config/secrets.yml`` or via ``$SECRET_KEY_BASE``
- Configure storage paths
- Configure external validators (see "Validators" below)
- Start Rails (``bundle exec rails server``)
- Start resque (``bundle exec rake resque:pool``)
- Create a user (current at the rails console)
- Ensure client can connect to rails server.

Client setup
^^^^^^^^^^^^

- In addition to the Rails server endpoint, the client must be able to connect
  via rsync over ssh to the configured rsync point in ``config/upload.yml``

Validators
----------

An external validator should accept as parameters:

- The external ID (i.e. a barcode or other identifier)
- The path to the bag

The validator should return zero if the bag is valid and non-zero if the bag is
not valid. Any output or errors will be captured for inspection by the client.
