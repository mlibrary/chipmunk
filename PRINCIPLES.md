# University of Michigan Library Digital Preservation Principles

Noah Botimer, Aaron Elkiss, Kat Hagedorn, Sebastien Korner, Jeremy Morse, James Ottaviani, Chris Powell, Lance Stuchell, and John Weise

Introduction {#DigitalPreservationPrinciples-Introduction}
============

Executive Summary {#DigitalPreservationPrinciples-ExecutiveSummary}
-----------------

This document describes the most important digital preservation
characteristics of repository systems in operation at the University of
Michigan Library so that product owners and stakeholders can benefit
from this experience when designing new preservation repository systems.

University of Michigan Library Information Technology (LIT) has been
developing and operating digital preservation repositories for over 20
years. The repository services and their underlying systems were
designed to reflect emerging preservation principles while meeting
identified needs and providing desired services. Understanding the
decisions made in these services and systems is imperative for
formulating a strategy for future repository solutions and for engaging
with preservation partners in the Library, the University, and in the
broader academic community.

Background and Methodology {#DigitalPreservationPrinciples-BackgroundandMethodology}
--------------------------

The Preservation Principles investigation team convened in March 2018 to
review the repository systems in use since 1995 at the University of
Michigan Library:

University of Michigan digital collections

- Pre-DLXS digital collections, 1995-present
- Digital Library eXtension Service (DLXS) image and text collections, 1999 - present
- ObjectClass, under development
- Deep Blue Docs, 2006 - present
- HathiTrust, 2008-present
- Deep Blue Data, 2016 - present
- Fulcrum, 2016 - present
- Dark Blue, 2017 - present

For each system, we discussed the problem it was attempting to solve,
the history of how it was developed, and its preservation
characteristics. We discussed how each characteristic derived from the
needs of the system and the understanding of digital preservation at the
time that it was built.

We then identified a number of significant preservation characteristics
that were shared by multiple systems and that seemed important to
consider for the design of future repository systems. These
characteristics do not by themselves prescribe a preservation strategy
or dictate how a specific future system should be built, but they can
serve as a guide for developing such a strategy.

Catalog of Digital Preservation Characteristics {#DigitalPreservationPrinciples-CatalogofDigitalPreservationCharacteristics}
===============================================

The characteristics identified are collected in a catalog herein. They
are not prescriptive requirements that must be met by any future system,
nor is this an exhaustive description of all preservation
characteristics of every system LIT has built. Neither are all
characteristics exhibited by every system under discussion (some are, in
fact, mutually exclusive). Rather, this catalog is a summary of past
experience and a guide to important factors to consider when designing
future systems.

The characteristics are organized into the following categories:

-   Storage and Fixity: How the system deals with storage and file
    integrity at the lowest levels
-   Formats and Content: How the system deals with preserved content and
    specific file formats
-   Metadata: How the system deals with metadata about the preserved
    content
-   Sustainability: How the system stays viable over time

\

For each digital preservation characteristic, we give a brief
description, examples of how it appears in existing systems, and a
reflection on how it has worked in practice and when or how it might
apply to future systems.

Storage and Fixity {#DigitalPreservationPrinciples-StorageandFixity}
------------------

*These characteristics relate to how the system deals with storage and
file integrity at the lowest levels.*

### Ability to audit storage {#DigitalPreservationPrinciples-Abilitytoauditstorage}

*The system implements technical functions for ensuring repository
integrity and consistency subsequent to content ingest. This enables
long-term bit-level preservation and supports future preservation
actions including storage or format migrations.*

Implements:

-   Samvera-based systems (via Fedora) - on an object-by-object basis
-   Deep Blue Docs - with DSpace functionality
-   HathiTrust - home-grown audit scripts
-   Dark Blue - built-in individual object and whole-repository auditing

Does not implement:

-   DLXS - some checksum files, but they are known to be inaccurate
-   Pre-DLXS digital collections

\

Storage auditing is a core feature for bit-level preservation. At a
minimum, it ensures that any changes to preserved files are intentional
and take place within view of the system. Newer systems (HathiTrust,
Dark Blue) implement repository auditing in a scalable and sustainable
fashion. Vended systems (Fedora, DSpace) have some functionality for
this as well. Objects in DLXS had some checksum information stored with
the object, but these were not regularly checked and over time updates
to objects without corresponding checksum updates caused the checksums
to become unreliable. Although most of our systems do implement this
functionality, we do not regularly audit all repositories. There are
cases where we have not tuned the audits to reduce false alarms, and
because of this we do not always promptly follow up on problems. Over
time, this poses a risk to repository integrity.

### Storage Redundancy {#DigitalPreservationPrinciples-StorageRedundancy}

*The system ensures that multiple copies of the content are stored at
all times, using at least two different storage technologies/systems, so
that failure of one system does not result in loss of content.*

-   Samvera-based systems, DLXS, Deep Blue -- MiStorage with
    replication + IBM Spectrum Protect (formerly known as Tivoli Storage
    Manager (TSM))
-   HathiTrust -- replicated Isilon storage + TSM
-   Dark Blue -- MiStorage w/o replication & Amazon Web Services (AWS)
    backup

Along with fixity, storage redundancy is a key digital preservation
practice, and all of our repositories exhibit this characteristic. They
also incorporate technological diversity with separate storage
technologies in use for the online storage and the backup. Geographical
diversity is a bonus, but in the past we have not considered the risks
to the Ann Arbor area to be severe enough to warrant ensuring that all
content is backed up to a geographical area with a different risk
profile. Although all repositories have storage redundancy, only
HathiTrust has direct / unmediated access to the redundant copy.
Although all systems have some level of preservation storage redundancy,
only HathiTrust and DLXS currently have redundancy in their access
systems, largely due to design decisions in external software solutions
like Fedora and DSpace. Some content is now backed up to AWS in addition
to being stored on campus. Some unique, high-value content from
HathiTrust and DLXS is preserved via other organizations such as
(APTrust, DuraCloud Vault, CLOCKSS) as well, but to date organizational
diversity has not been a key consideration for most content.

### Self-Hosting {#DigitalPreservationPrinciples-Self-Hosting}

*The primary preservation functions are carried out on servers and
storage hosted on campus and managed by Library IT to ensure
transparency and appropriate configuration.*

-   Deep Blue Docs, Deep Blue Data, Fulcrum, DLXS -- Servers managed by
    LIT; primary and backup storage managed by ITS
-   HathiTrust -- Servers managed by LIT; primary storage managed by
    LIT, backup managed by ITS
-   Dark Blue -- Servers managed by LIT; primary storage managed by ITS,
    backup storage in AWS.

\

All servers for all preservation repositories are currently located on
premises and are managed by LIT. The storage is managed by MiStorage now
in most cases, but is still accessed via LIT servers and hosted on
campus premises. Most backups are currently on campus as well, although
Dark Blue is now being backed up to AWS and likely HathiTrust will be in
the future as well (in addition to an on-campus backup copy). We would
likely not consider an AWS-only storage solution sound preservation
strategy due to the lack of transparency and lack of explicit
preservation commitments on the part of Amazon, but it can still
function to help ensure storage redundancy and geographic and
technological diversity. For fully self-hosted servers and storage (such
as with HathiTrust) we can exercise close control to ensure storage is
managed in the best possible way for digital preservation. However,
there are many cases in which we are already relying on storage managed
elsewhere on campus for purposes that may not directly align with
digital preservation. This may point to a need to mitigate risk by
ensuring additional storage copies or additional technological
diversity.

### Content recoverable from the filesystem {#DigitalPreservationPrinciples-Contentrecoverablefromthefilesystem}

*The system stores content as regular files on disk in such a way that
recovery of the content and arrangement into conceptual objects requires
only an operating system that can interpret the filesystem and an
accurate description of the on-disk layout. This helps enable future
preservation actions such as storage or software migrations.*

 Implements:

-   Dark Blue - stored as bags on disk; bag metadata has barcodes.
-   HathiTrust - stored as flat zip + METS named with object ID
-   DLXS (TextClass) - all page images for a volume stored in a
    directory named with the item ID
-   DLXS (ImageClass) - individual images stored in directories under
    their collection identifier

Does not implement:

-   Samvera-based systems - files stored by checksum in ModeShape
    repository underlying Fedora.

Most of our repositories store content organized by object in
directories on disk with some kind of manifest. This helps decouple the
storage and preservation functions of the repository from other
functions such as ingest and access and minimizes risks to content
through software failure or obsolescence. Fedora plans to implement the
Oxford Common Filesystem Layout (OCFL) to help address this problem, and
it seems likely that we will implement OCFL for Dark Blue and
ObjectClass as well. The lack of implementation for Samvera-based
systems can be mitigated by extracting content and depositing as Bags,
as Fulcrum plans to do via APTrust later in 2019.

Formats and Content {#DigitalPreservationPrinciples-FormatsandContent}
-------------------

*These characteristics relate to how the system deals with preserved
content and specific file formats. There are two major axes: what kinds
of content systems accept for preservation, and how migrations are
managed in the system. Different kinds of content may be preserved and
managed in different ways within the same system.*

### Advisory content characterization or validation {#DigitalPreservationPrinciples-Advisorycontentcharacterizationorvalidation}

*The system provides some technical ability for characterization or
validation, but does not enforce normalization or validity either by
policy or technical control.*

-   Deep Blue Docs, Deep Blue Data: Self deposit, with guidelines
    indicating what content types can be preserved
-   ImageClass, Fulcrum (Assets): There were guidelines for file
    formats, and content was characterized at ingest time, but
    ultimately any well-formed content is preserved.

\

Several systems (Deep Blue Docs, Deep Blue Data, ImageClass, Fulcrum)
have recommendations or guidelines for deposit but ultimately accept
content even if it does not conform to the guidelines. Whether a system
enforces technical controls on content is primarily related to whether
the system accepts most or all content vs. whether the material can be
tightly controlled and validated prior to ingest into the system.
Repositories with self-deposit capabilities (Deep Blue) and repositories
that need to accept arbitrary born-digital material (Dark Blue) may be
able to provide only bit-level preservation on some material. Material
is sometimes explicitly tagged with the level of preservation that is
being provided for specific content (cf. Deep Blue preservation levels),
but this isn\'t always made visible to the depositor or to end-users.
Repositories with more tightly controlled kinds of content (e.g.,
HathiTrust) can afford to require format identification and validation
for all content, but this comes at the cost of substantially reduced
flexibility in what can be accepted. Repositories that create access
derivatives rather than providing the preservation copy directly do more
content validation, even if it is implicit -- if nothing else, the
preservation copy needs to be intact enough for the system to create
access derivatives.

### Enforced content normalization and validation {#DigitalPreservationPrinciples-Enforcedcontentnormalizationandvalidation}

*Policies and/or technical controls ensure consistency of what is
preserved in the repository, enabling future actions based on migration
policies at scale.*

-   HathiTrust - all digitized book content, normalized to all look the
    same for the most part; difficult to add support for new content
    models (e.g. EPUB)
-   Dark Blue - each content type must pass validation. some content
    types (digital forensics) allow more variation than others
    (audio/video)
-   DLXS (TextClass) - policies and procedures existed around
    normalization, but few technical controls to ensure them.
-   DLXS (ImageClass) - content is not normalized; presentation is
    normalized via format conversion and metadata mapping at access
    time.
-   Fulcrum (ebooks) - EPUB content is validated

\

Enforcement of content validation and file naming conventions typically
occurs at ingest time. In general, we have implemented some kind of
normalization for similar kinds of content within the bounds of a
repository. In some cases, there was normalization attempted but not
many technical controls to ensure the outcome of the normalization was
as expected. In TextClass, for the digitized books with page images,
there were strict policies around management and control of the file
naming, locations, and properties, but not always verification of those
properties. We believed at the time that we were adhering to certain
standards but had no way to test some of them in the earliest days.
ImageClass relies on mapping the preservation images to alternative,
normalized representations. Though ImageClass is very flexible, there
was an attempt to create one way of doing things. For example, metadata
mapping is highly configurable, and this feature is available to be
applied to every collection, in a consistent, documented way.

### Policy-based commitment to migration strategies {#DigitalPreservationPrinciples-Policy-basedcommitmenttomigrationstrategies}

*The repository has documented policies on supported file types and
preservation commitments, but does not implement support for migrations
within the scope of the system, so that effort isn\'t spent on
automating tasks that will be done rarely (if ever).*

-   Deep Blue Docs, Deep Blue Data, Fulcrum: Policies describe the level
    of preservation for various content types; the system ultimately
    accepts any content.
-   DLXS: Policies and practices for preservation and migration exist,
    but large variations exist in how content was managed over the
    years.

\

Some repositories specify a policy around what should be deposited or
what could be managed without technical controls to enforce those
policies. In many cases, technical controls might not even be fully
possible to implement - for example, administrative users can usually
bypass controls with various degrees of effort, and depositors could
submit material with misleading metadata. There is still a spectrum of
controls, and in general, newer repositories implement more of them.
However, understanding and implementation in newer repositories has lead
to changes in older repositories. For example, in DLXS, digital
preservation was always our intent. Over the years, our understanding,
and in some cases execution (e.g. HathiTrust), of digital preservation
evolved dramatically, while the policies and practices surrounding DLXS,
were not brought forward. There is a relationship between the diversity
of content the repository is expected to accept and the level of control
of management the repository can provide. Policies around preservable
content are more flexible than technological implementations but also
somewhat more risky in that policies might not always be followed.

### Controlled content migrations {#DigitalPreservationPrinciples-Controlledcontentmigrations}

*Policies as well as technical safeguards are in place to prevent
unexpected changes to content.*

-   HathiTrust - restricted write access to the repository; policies to
    prevent manual editing & procedures for automatic migration.
-   Dark Blue - controlled access to repository storage; migrations
    would be controlled similarly to HathiTrust.
-   Fulcrum - controlled access to admin features and ingest/update
    tools.

\

Newer repositories tend to have more tightly controlled access. For
example, in DLXS, all staff have write access to the repository, but are
expected to follow specific procedures when updating content. Not all
these procedures are well-documented, and the relatively wide access
combined with lack of documentation has led to some inconsistencies in
content over the years. HathiTrust and Dark Blue tightly control write
access to the underlying storage to try to ensure that all preservation
actions take place through the system, but this control is still
somewhat indirect. Fulcrum workflows favor a batch import script, which
allows for the highest degree of restriction on write access to the
repository, and also enforces consistency of practice. However, Hyrax's
GUI-based ingest tools still exist and allow the possibility for a
divergence of practice. While access to the GUI ingest is also
restricted, workflows and consistency of practice are still works in
progress, so currently Fulcrum is prone to the same limitations as DLXS
has had.

### Guarantee of comparability of access & preservation copies {#DigitalPreservationPrinciples-Guaranteeofcomparabilityofaccess&preservationcopies}

*Policies and technical controls ensure that the access copy reflects
the preservation copy to maintain parity and detect anomalies with the
preservation copy or derivative generation.*

-   DLXS (TextClass), HathiTrust - access copy derived on-demand
-   Deep Blue Docs, Deep Blue Data - preservation copy is delivered
    directly (no separate access copy)
-   Dark Blue - preservation copy available to re-derive access copy
-   DLXS (ImageClass) - preservation copy available to re-derive access
    copy
-   Fulcrum - Formats that are viewable in the UI: preservation copy
    available to re-derive access copy. Other formats: preservation copy
    is delivered directly (no separate access copy.

\

In some cases such as TextClass and HathiTrust this means that the
access copies are derived on demand, since the preservation format and
technology used to deliver the content are amenable to it. In other
cases such as AV material stored in Dark Blue, it means that the goal is
to store the preservation copy in such a way that it is accessible and
that we can re-verify and re-derive access copies when needed. This
means ensuring stable identifiers and links to the preservation copy as
well as occasional verification that the preservation copy is intact.
For some formats, this might require making an explicit commitment to
preserve software and workflows necessary to re-generate derivatives.

Metadata {#DigitalPreservationPrinciples-Metadata}
--------

*These characteristics relate to how the system deals with metadata
about the preserved content.*

Overview of descriptive metadata storage scenarios for the systems
considered:

::: {.table-wrap}
+---------+---------+---------+---------+---------+---------+---------+
| \       | **Creat | **Manag | **Prese | **Acces | **Store | **Manag |
|         | ed      | ed      | rvation | s       | d       | ed/sour |
|         | by**    | in**    | storage | storage | with    | ced/ori |
|         |         |         | **      | **      | object  | ginated |
|         |         |         |         |         | in      | in      |
|         |         |         |         |         | reposit | reposit |
|         |         |         |         |         | ory?**  | ory?**  |
+---------+---------+---------+---------+---------+---------+---------+
| **Hathi | partner | Zephir  | snapsho | Solr    | no      | no      |
| Trust** | institu |         | t       |         |         |         |
|         | tions/p |         | in METS |         |         |         |
|         | ublishe |         |         |         |         |         |
|         | rs      |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| **Image | collect | MySQL   | MySQL   | MySQL   | no      | no      |
| Class** | ion     |         |         |         |         |         |
|         | manager |         |         |         |         |         |
|         | s/conte |         |         |         |         |         |
|         | nt      |         |         |         |         |         |
|         | vendors |         |         |         |         |         |
|         | /publis |         |         |         |         |         |
|         | hers    |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| **TextC | collect | Catalog | XML     | XPat    | yes     | no      |
| lass**  | ion     |         |         |         |         |         |
|         | manager |         |         |         |         |         |
|         | s/conte |         |         |         |         |         |
|         | nt      |         |         |         |         |         |
|         | vendors |         |         |         |         |         |
|         | /publis |         |         |         |         |         |
|         | hers    |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| **Deep  | deposit | DSpace/ | DSpace/ | Solr    | yes     | sometim |
| Blue    | or      | postgre | postgre | (??)    |         | es      |
| Docs**  | or      | s       | s       |         |         |         |
|         | content |         |         |         |         |         |
|         | source  |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| **Deep  | deposit | Samvera | Fedora  | Solr    | yes     | sometim |
| Blue    | or      | /       |         |         |         | es      |
| Data**  | or      | Fedora  |         |         |         |         |
|         | content |         |         |         |         |         |
|         | source  |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
| **Fulcr | publish | Samvera | Fedora  | Solr    | yes     | ?       |
| um**    | er      | /       |         |         |         |         |
|         | or      | Fedora  |         |         |         |         |
|         | content |         |         |         |         |         |
|         | source  |         |         |         |         |         |
+---------+---------+---------+---------+---------+---------+---------+
:::

\

### Descriptive metadata interoperability with other current systems {#DigitalPreservationPrinciples-Descriptivemetadatainteroperabilitywithothercurrentsystems}

*The choice of descriptive metadata elements are driven by needs around
interoperability with external systems.*

-   Fulcrum - Metadata is stored internally as RDF and will be mapped to
    other schema for external uses (e.g. Crossref).
-   HathiTrust - MARC records rather than custom metadata
-   DLXS (ImageClass, TextClass) - flexible metadata mapping is
    beneficial for metadata aggregation and facilitates searching across
    collections.

\

Interoperable metadata typically benefits reusability while constraining
flexibility. HathiTrust benefits from the reusability of MARC metadata
in a variety of contexts, but is currently struggling with the issue of
how to store and make use of other kinds of metadata that doesn\'t align
well with MARC. In Samvera-based systems, RDF and Linked Data have the
potential to allow us to benefit from standard vocabularies while
allowing substantial flexibility and extensibility, but current use is
limited and internal-facing only.

### Descriptive metadata managed in external system {#DigitalPreservationPrinciples-Descriptivemetadatamanagedinexternalsystem}

*Descriptive metadata is managed separately from preservation storage of
content, either to avoid implementation of functionality that already
exists elsewhere or to allow descriptive metadata to vary independently
from content.*

-   Dark Blue (ArchivesSpace, Aleph)
-   HathiTrust (Zephir)
-   DLXS (TextClass) - (Aleph, Headra)
-   DLXS (ImageClass) - metadata is created and managed in a variety of
    other systems, typically housed with the source of the content, such
    as any one of the LSA museums.

\

This approach contrasts with storing and managing descriptive metadata
in the system. Although HathiTrust, Dark Blue, and TextClass do not
manage descriptive metadata directly, objects in those repositories
still contains a static snapshot of the metadata at the time of deposit.
They also contain links to the canonical location of descriptive
metadata, either explicitly in the case of HathiTrust and Dark Blue or
implicitly via the identifier in TextClass. When metadata already exists
externally, this avoids the need to duplicate it inside the repository
and keep it synchronized with the external source. It also minimizes the
need to change objects in the repository if the metadata changes much
more frequently than the content.

### Descriptive metadata managed within system {#DigitalPreservationPrinciples-Descriptivemetadatamanagedwithinsystem}

*Descriptive metadata is managed in the same system as the content to
enable greater flexibility and so that metadata is preserved more
directly alongside the content.*

-   Fulcrum
-   Deep Blue Data
-   Deep Blue Docs

\

This choice is often made if the system is self-deposit. Storing
metadata directly in the system potentially allows creation and editing
of that metadata in the system, which can simplify the deposit and
administration workflow for self-deposit. (While Fulcrum currently
allows editing of metadata directly within the system, local practice is
evolving to discourage this.) This choice might also be made if the
metadata is idiosyncratic to specific kinds of objects or requires
specialized management not available in other systems. Storing the
metadata within the system increases the complexity of the repository,
but has the benefit of keeping everything related to an object in a
single location.

### Choice of preserved metadata driven by access needs {#DigitalPreservationPrinciples-Choiceofpreservedmetadatadrivenbyaccessneeds}

*Technical and descriptive metadata is only explicitly preserved with
the content if it is needed when accessing the object, which aids in
reducing demands on storage and in metadata processing.*

-   Fulcrum (EPUB) - no additional technical metadata beyond Hyrax
    defaults; no structural metadata to describe the contents of the
    EPUB or how it links to other objects in the repository.
-   HathiTrust - minimal technical metadata stored in the METS;
-   DLXS - technical metadata is typically in the image file headers
    only

This contrasts with the approach of extracting and storing as much
technical metadata as possible, which is not typically an approach our
systems have taken. Generally, we have assumed that if tools are
available to extract technical metadata at ingest time that the tools
will still be available and that the preservation files will still be
accessible. This approach does perhaps point to a need to preserve tools
that can extract metadata on a long-term basis, or at least to monitor
their ongoing viability. Given the continual decrease in the cost of
storage, it may be less important now than in the past. There could
still be a preservation role for this approach, though \-- a system
could extract and store only those technical characteristics deemed
\"significant\" enough to be worth preserving across format migrations.

### Unified search {#DigitalPreservationPrinciples-Unifiedsearch}

*Content is stored in such a way to enable indexing and search of
content and metadata across the repository as well as metadata across a
large collection of material.*

-   DLXS (TextClass, ImageClass) - All collections stored/indexed via
    the same method to enable search across collections (by class)
-   HathiTrust - All content indexed the same way into the same search
    index.
-   Deep Blue Docs - Full text search across all indexable content types
-   Samvera-based systems - common methods for full-text indexing (even
    if not used)
-   Dark Blue - no search, but there is a consistent interface for
    accessing objects should that feature be needed in the future.

\

This is more about whether a system is amenable to standard search and
indexing techniques without re-engineering the repository than whether
the system currently provides search capability. This issue was one
major reason for the creation of DLXS - pre-DLXS digital collections had
no particular level of consistency across collections, so it was
impossible to provide unified search across those collections. To
provide this characteristic, systems should store objects so they are
individually accessible and can be indexed in a consistent way. Objects
must also be accessible either via the filesystem or via an API in a way
that is amenable to batch or offline processing. Unified search
capability is now so common that it\'s hard to envision building a
system that could not support this.

Sustainability {#DigitalPreservationPrinciples-Sustainability}
--------------

*The attributes that characterize and behaviors that maintain the
viability of a system over time.*

### Low cost {#DigitalPreservationPrinciples-Lowcost}

*Implementation decisions are made with the explicit purpose of lowering
the cost per TB of preserved content.*

-   Dark Blue - single-instance MiStorage with AWS
-   DLXS, Deep Blue Docs, Deep Blue Data - MiStorage

\

The initial storage systems for our repositories were bespoke and
relatively expensive. As appropriately redundant storage becomes more
commodified we can take advantage of that. In particular, we have
migrated more and more repositories into campus storage rather than
self-managed storage explicitly to lower cost both of hardware and staff
time to manage storage. Dark Blue is currently serving as a pilot of
lower-cost backup options, but HathiTrust will be moving in that
direction as well.

### Scalability {#DigitalPreservationPrinciples-Scalability}

*Implementation decisions are made to allow very large amounts of
content to be handled in the system.*

-   HathiTrust - 16 million items, can ingest multiple TB/50,000+volumes
    per day, can audit fixity of entire repository on a quarterly basis;
    can reindex repository in a few weeks.
-   DLXS - designed to enable scaling of digital collection deployment,
    operation, and maintenance. Automation and coordination with content
    sources facilitate this as well.
-   Deep Blue Docs - use of APIs and integration with ArchiveMatica
    allows for batch ingest to be managed by the content provider (on an
    as needed basis).

\

Scaling up was important with DLXS and more so with HathiTrust (one of
the largest digital libraries in the world.) Scalability is less of a
concern to more \"boutique\" repositories like Fulcrum, and there is a
question of whether Samvera-based repositories can scale to large
amounts of content. While Dark Blue is initially more of a boutique
repository, design decisions such as storage and ingest architecture
were made to enable future scalability.

### Re-use of platform/infrastructure {#DigitalPreservationPrinciples-Re-useofplatform/infrastructure}

-   All of our repositories run on Linux servers and almost all use
    MySQL in some capacity.
-   Deep Blue Docs is the outlier here in terms of technology: DSpace
    (Java) with Postgres. There is some comfort gained by the fact there
    are a large number of DSpace repositories in the world.
-   DLXS - same code, multiple digital collections - initial development
    of TextClass was to move from developing one-off collections to
    shared code between collections.
-   Samvera / Fedora - there are large amounts of shared code being
    co-developed with other institutions, even if there is some
    customized to each system.
-   Dark Blue - also uses Ruby and Rails, although it doesn\'t use any
    Samvera components.
-   Access layers like the Michigan Daily Digital Archives and Middle
    English Dictionary also use Blacklight (with Ruby and Rails),
    although they do not use Fedora as the backend, as is typical with
    other Samvera-based applications.

\

The original goal of DLXS was moving towards reusability within the
organization. Linux & MySQL are already standard for our repositories.
We have moved towards standardization of infrastructure as we work on
new repository projects: Ruby and Rails for code; Blacklight and Solr
for discoverability; Samvera and Fedora where there are needs around
metadata management in the system or more elaborate front ends. Deep
Blue is being migrated to Samvera. ObjectClass will also use these
components. HathiTrust will likely be rewritten in the next few years to
use Rails and Blacklight. We are also paying attention to the emerging
OCFL standard, which Fedora and likely Dark Blue will adopt, and
HathiTrust could adopt as well.

### Community Partnership {#DigitalPreservationPrinciples-CommunityPartnership}

*Development of the service involves working together with other
institutions to improve the quality of long-term preservation.*

-   Fedora/Samvera-based systems: community is a major factor behind
    adoption
-   DLXS: open source with the exceptions of XPat, which required
    purchase of a license, and paid support (optional). Engaged with
    adopters regularly, occasionally received code contributions,
    consulted on priorities.
-   HathiTrust: in terms of content, policies, and programs, albeit not
    currently for code
-   DSpace: open source

\

Community engagement is perhaps the most nebulous of these principles in
that the rest are first-order attributes of the technology or service,
and the benefits of community engagement are primarily supportive, or
second-order. For example, participating in defining formats and
standards is useful for both maintaining parity with other
implementations and connections with those institutions that have
similar needs. Helping to define and adhering to a standard is largely
an investment, rather than a direct goal. Certainly, there are occasions
where a reference implementation is sufficient to reduce development
cost, but the overriding value is in the alignment with others and the
prospective interchange of content, implementation, vocabulary, and
expertise.

Participating in the initiatives (and using the software) listed above
is consistent with the public good mission of the University. Whether in
terms of providing leadership, ensuring that our needs are visible,
developing open source software, or simply using a given tool, the
presence of the University is notable. We seek to invest our resources
wisely into communities that can benefit from that investment, as we
enjoy the rewards of collaborative endeavors, both individually and
organizationally.
