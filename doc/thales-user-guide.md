Thales User Guide
=================

Introduction
------------

Thales is a metadata record management Web application focusing on
research data collections. It allows metadata records to be created
and edited. The metadata records are published on an [OAI-PMH]
machine-readable feed in the [RIF-CS] format for other systems to
harvest.

Thales was developed for an Australian National Data Service ([ANDS])
funded metadata stores project. Currently, it is designed to be
deployed as an internal system where people using the Web interface
must have a login account. The only publically accessible feature is
the machine-readable feed. It was originally developed as a _local_
[metadata store] for manually edited metadata records; the
_institutional_ metadata store that harvests these metadata records
provided the publically accessible view of the metadata records.

This user guide describes how to create, edit, publish, view and
delete metadata records.  It also documents the data properties that
make up the metadata records.

[ANDS]: <http://www.ands.org.au> "Australian National Data Service"
[metadata store]: <http://www.ands.org.au/guides/metadata-stores-solutions.html#Types%20of%20metadata%20stores> "ANDS types of metadata stores"
[OAI-PMH]: <http://www.openarchives.org/pmh/> "Open Archives Initiative Protocol for Metadata Harvesting"
[RIF-CS]: <http://www.ands.org.au/resource/rif-cs.html> "Registry Interchange Format - Collections and Services"

### Metadata model

Thales supports metadata records based on [ISO 2146] and
[RIF-CS]. There are four types of metadata records:

- Data collections
: Research data.

- Parties
: People and groups associated with the research data.

- Activities
: Projects and programs that produced the research data.

- Services
: Mechanisms to access the research data.

[ISO 2146]: <http://www.iso.org/iso/catalogue_detail.htm?csnumber=44936> "ISO 2146:2010 : Information and documentation - Registry services for libraries andrelated organizations"

Operations
----------

### Creating records

To create a new metadata record:

1. Click on "Records".
2. Click on one of the "New ... record" options (in the right side-navigation).
3. Enter the metadata information.
4. Publish the metadata record by changing the OAI-PMH publish status
   to "Publish". By default the record is not published in the feed.
   See [Changing the publish status] below for a description of the publishing statuses.
5. Click the "Create record" button.

To abort the process and not create a new record, click the "Cancel"
button.

### Editing records

1. Click on "Records".
2. Click on the title of the chosen metadata record.
3. Click the "Edit record" button.
4. Modify the values.
5. Click the "Save record" button.

To abort the editing operation (discarding any changes), click the
"Cancel" button.

### Changing the publish status

The publishing status of records can be changed.

1. Click on "Records".
2. Click on the title of the chosen metadata record.
3. Click the "Edit record" button.
4. At the bottom of the form, change the OAI-PMH publish status.
5. Click the "Save record" button.

Thales is initially setup so the OAI-PMH feed tracks deleted
records. There are three possible states for a record: "not in feed,"
"published record in the feed" and "deleted record in the feed." The
states follow these rules:

- Records are created with an initial OAI-PMH publishing status of
  either "not in feed" or "published record in the feed".

- Records that are "not in feed" can be changed to being a "published
  record in the feed".

- Records that are a "published record in the feed" record can be
  changed to being a "deleted record in the feed". But they can never
  be changed to "not in feed."

- Records that are a "deleted record in the feed" can be changed to
  being a "published record in the feed" (i.e. undeleting them). But
  they can never be changed to "not in feed".

So once a record has been published, it always remains in the feed
(either as a published record or as a deleted record). Users cannot
remove all traces of a published record from the feed (although this
can be done by an administrator.)

### Viewing records

#### Browsing

1. Click on "Records".
2. Click on the title of a record.

#### Searching

1. Click on "Records".
2. Type search terms into the search text field.
3. Click the "Search" button or press the return key.

Note: currently the search term is only searched for in the metadata
record titles.

### Deleting records

1. Click on "Records".
2. Click on the title of the chosen metadata record.
3. Click the "Delete record" button.
4. Click the "OK" button to confirm the delete operation.

Deleted records will no longer appear in the in the Web user
interface, but will remain in the OAI-PMH feed as a deleted record.

To have the record appear as a deleted record in the OAI-PMH feed, but
keep the record in the Web user interface, change its publish status
to "deleted record in the feed."

Users cannot remove all traces of a published record from the feed
(although this can be done by an administrator.)

Data elements
-------------

### General

#### Record types

Following the [RIF-CS] model, there are four types of metadata records:

- Collection records
- Party records
- Activity records
- Service records

[RIF-CS]: <http://www.ands.org.au/resource/rif-cs.html> "Registry Interchange Format - Collections and Services"

#### Text properties and link properties

Each record is made up of property values, which were inspired by
properties from [RIF-CS] and [Atom-RDC].

[Atom-RDC]: <http://uq-eresearch-spec.github.com/atom-rdc/> "Atom representation of Research Data Context"

There are two types of properties:

- Text properties have values which are arbitrary strings. Just type
  the string into their text fields.

- Link properties have values which consist of a mandatory URI plus
  and optional description. Type the URI, optionally followed by
  spaces and the description, into the text field.

  Link property are usually displayed as a hyperlink to the URI.
  If a description is provided, it is used as the anchor text.
  If there is no description, the URI is used as the anchor text.

#### Related records

At the bottom of each form, there is a section for "related records."

These properties are link properties where the URI must be an
identifer from another metadata record. If that metadata record
exists, the value of its title is displayed (and any description in
the link property is ignored).

If that metadata record does not exist (i.e. a record with a matching
identifier cannot be found) the reference is invalid.  It will be
displayed as an external link (highlighted in yellow), using the
description as the anchor text (if available). An invalid reference
will appear in the RIF-CS as a `relatedInfo` instead of a
`relatedObject`--usually this is not desirable, so make sure the
reference is valid.

Currently, there is no user interface to make populating related
records easy, so the identifiers should be manually copied from the
other record.

#### Repeatable properties

Repeatable data fields have a plus sign on the right. Click on the
plus sign to add additional fields. To delete a value, just remove all
the text from the text field (it will be ignored when the record is
saved).

### Common properties

These properties can appear in any of the metadata record types
(i.e. collection records, party records, activity records and service
records).

Title
: Main title for the record.

Alternative title
: Additional titles, if any.

Description
: Text describing the entity.

Identifier
: Value identifying the entity. This is
a text property, but often identifiers values will be URIs. When
generating RIF-CS, the type of identifier will be automatically
determined from its value (e.g. those starting with
'http://orcid.org/' as an [ORCID iDs](http://www.orcid.org/)).

Keyword
: Short terms describing the entity. Free text.

Field of Research
: FoR codes.  Link property that expects URIs starting with
'http://purl.org/asc/1297.0/2008/for/' followed by the FoR number. An
optional description can be provided.  For example,
"http://purl.org/asc/1297.0/2008/for/010101 Algebra and Number
Theory".

Socio-Economic Outcomes
: SEO codes. Link property that expects URIs starting with
'http://purl.org/asc/1297.0/2008/seo/' followed by the SEO number. An
optional description can be provided. For example,
"http://purl.org/asc/1297.0/2008/seo/950404 Religion and Society".

Contact email
: An email address.

Web page
: A URI.


### Collection records

These properties appear in collection records.

Collection subtype
: The kind of collection: either a collection or a dataset. See the
ANDS
[Content Providers Guide](http://ands.org.au/guides/cpguide/cpgcollection.html)
for details.

Temporal coverage
: The time covered by the data collection. Either a single datetime or
two datetimes separated by a slash character. The datetimes can be
year, year-month, year-month-day, and can include a time
component. For example, "2013", "2012-03, "2013-03-14", "1968/2008",
"2012-01/2012-12", "2013-03-14T17:00Z", "2013-03-14T09:00Z/2013-03-14T17:00Z".

Spatial (geoname)
: A geoname URI (not yet supported in the RIF-CS). For example, "http://www.geonames.org/2152274/ Queensland".

Spatial (point)
: Longitude and latitude separated by a comma. For example,
"153.015183,-27.500028".

Spatial (polygon)
: Sequence of space separated coordinates; coordinates are longitude
and latitude pairs separated by a comma. For example, "138,-9.13
-9.13,-9.13 153.6,-9.13 -29.2,-9.13 153.6,-9.13 -29.2,-9.13 138,-9.13
-9.13,-9.13 138,-9.13".

Spatial (text)
: Free text names.

Access rights
: Corresponds to the RIF-CS access rights data element.

Rights statement
: Corresponds to the RIF-CS rightsStatement data element.

Licence
: Corresponds to the RIF-CS licence data element.

Related records:

- Creator of data: identifier of a party record
- Manager of a data: identifer of a party record
- Service to access data: identifier of a service record
- Data referenced in publication: URI

### Party records

These properties appear in party records.

Name title
: Title for the person's name. For example, Mr, Mrs, Miss, Dr.

Given name
: Given name(s). Multiple names should be provided in the order of
first name followed by middle name(s).

Family name
: Surname.

Related records:

- Data created: identifier of a collection record
- Data managed: identifier of a collection record
- Operates service: identifier of a service record
- Participates in activity: identifier of an activity record
- Author in publication: URI

Note: the title property is present in party records, but is currently
not used in the RIF-CS output. If present, it is used for display
purposes. If it is not present, the given name and surname are
displayed.

### Activity records

These properties appear in activity records.

Temporal coverage
: The time covered by the activity. Either a single datetime or two
datetimes separated by a slash character. (See temporal coverage in
collection records for examples).

Related records:

- Participant: identifier of a party record
- Data produced: identifier of a collection record

### Service records

These properties appear in service records.

Related records:

- Operator: identifier of a party record
- Data: identifier of a collection record

Further information
-------------------

For further information on metadata about research data collections,
please see the ANDS
[Content Providers Guide](http://www.ands.org.au/guides/content-providers-guide.html).
