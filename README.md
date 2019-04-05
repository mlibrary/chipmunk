[![Build Status](https://travis-ci.org/mlibrary/chipmunk.svg?branch=master)](https://travis-ci.org/mlibrary/chipmunk)
[![Coverage Status](https://coveralls.io/repos/github/mlibrary/chipmunk/badge.svg?branch=master)](https://coveralls.io/github/mlibrary/chipmunk?branch=master)
[![API Docs](https://img.shields.io/badge/API_docs-rubydoc.info-blue.svg)](https://www.rubydoc.info/github/mlibrary/chipmunk)
[![Documentation Status](https://readthedocs.org/projects/chipmunk/badge/?version=latest)](https://chipmunk.readthedocs.io/en/latest/?badge=latest)

# Dark Blue ("Project Chipmunk")

A Preservation-Focused Dark Repository for the University of Michigan

The documentation can be found [here](https://chipmunk.readthedocs.io/)

## Building Documentation Locally

### [RubyDoc.info](https://www.rubydoc.info/)

RubyDoc.info is an external host for javadoc-style documentation of your project's modules,
classes, and methods. It uses [yard](https://yardoc.org/) to build out the documentation
directly from your source code. It works minimally on ruby codebases out of the box, and
offers a comprehensive host of directives that can used in source code comments to further
improve the product.

RubyDoc.info updates automatically. You can compile and view the documentation locally
by running `bin/yard serve`, then viewing it in a browser.

### [ReadTheDocs](https://readthedocs.org/)

ReadTheDocs is a documentation host for those docs that are not specifically source code
annotations. Typically, this will include high-level descriptions, workflows, reasoning,
and those things that one usually finds in a README.

ReadTheDocs uses [sphinx](http://www.sphinx-doc.org/en/stable/) to build the documentation,
and will do so automatically. You can compile and view the documentation locally. Note
that this will require `python` to be installed; the version from your package manager is
sufficient.

#### [PlantUML](https://build-me-the-docs-please.readthedocs.io/en/latest/Using_Sphinx/UsingGraphicsAndDiagramsInSphinx.html#using-plantuml) Graphs

Both ReadTheDocs and the local sphinx instance can automatically
draw graphs from text using [PlantUML](http://plantuml.com/). Note that to build this locally,
the command `plantuml` needs to be on your path.

#### Describing HTTP

This repository is configured with the addon
[httpdomain](https://sphinxcontrib-httpdomain.readthedocs.io) which can be used to effectively
describe RESTful or other HTTP endpoints and APIs.

#### Build!

```
cd docs
pip install -r requirements.txt
make auto
# Then view it with a browser
```

