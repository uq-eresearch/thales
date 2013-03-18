Thales Development Guide
========================

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

[ANDS]: <http://www.ands.org.au> "Australian National Data Service"
[metadata store]: <http://www.ands.org.au/guides/metadata-stores-solutions.html#Types%20of%20metadata%20stores> "ANDS types of metadata stores"
[OAI-PMH]: <http://www.openarchives.org/pmh/> "Open Archives Initiative Protocol for Metadata Harvesting"
[RIF-CS]: <http://www.ands.org.au/resource/rif-cs.html> "Registry Interchange Format - Collections and Services"

### Purpose

This guide describes the import/export data format.

It is intended for people who develop software that interact with
Thales, and for developers working with the Thales source code.

### Related documents

The [Thales User Guide](thales-user-guide.md) describes how to use it
to create and modify metadata records.

The [Thales Administration Guide](thales-admin-guide.md) describes how
to setup and manage Thales.

The [Thales Installation Guide](thales-install-guide.md) describes how
to install Thales.


Thales metadata dump format
---------------------------

The Thales metadata dump format is the XML format the
`thales-admin.rb` program uses to export and import metadata records.

It is an XML file with the `db:records` element as the root
element. That element contains zero or more `db:record` elements.

A `db:record` element contains:

- `db:id` element (optional)
- `db:type` element (mandatory)
- `cs:data` element (mandatory)
- `db:oaipmh_status` element (optional)

The permitted values for the `db:type` element are:

- http://ns.research.data.uq.edu.au/2012/eResearch/type/collection
- http://ns.research.data.uq.edu.au/2012/eResearch/type/party
- http://ns.research.data.uq.edu.au/2012/eResearch/type/activity
- http://ns.research.data.uq.edu.au/2012/eResearch/type/service

The `cs:data` elements contains a sequence of `cs:prop` and/or `cs:link` elements.

The `cs:prop` element represents the values of _text properties_. It
has a `type` attribute indicating which property it is. The value is
represented as the element's contents.

The `cs:link` element represents the values of _link properties_. It
has a `type` attribute indicating which property it is. It has a `uri`
attribute containing the URI value. The description is represented as
the element's contents, if there is a description.

### Example

    <?xml version="1.0"?>
    <records xmlns="http://ns.research.data.uq.edu.au/2012/thales/db">
      <record>
        <id>urn:uuid:7d9127c5-b97e-4474-87a3-68f2c219c609</id>
        <type>http://ns.research.data.uq.edu.au/2012/eResearch/type/collection</type>
        <data xmlns="http://ns.research.data.uq.edu.au/2012/cornerstone">
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/subtype"
		        >http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/dataset</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/title">Test Data</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/web_page">http://www.example.com</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/contact_email">admin@example.com</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/description">Test data collection.</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/identifier">1234</prop>
          <link type="http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_FoR"
		        uri="http://purl.org/asc/1297.0/2008/for/010101">Algebra and Number Theory</link>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_text">Queensland</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_keyword">test</prop>
          <prop type="http://ns.research.data.uq.edu.au/2012/eResearch/property/temporal">2012/2013</prop>
        </data>
        <oaipmh_status>active</oaipmh_status>
      </record>
    </records>

#### Type attribute values for cs:prop and cs:link elements

These are the permitted values for the `type` attributes correspond to
the metadata properties support by Thales. For a high level
description of the properties, please see the
[Thales User Guide](thales-user-guide.md).

##### Common properties

Type attribute values for common properties:

Title
: http://ns.research.data.uq.edu.au/2012/eResearch/property/title

Alternative title
: http://ns.research.data.uq.edu.au/2012/eResearch/property/title_alt

Description
: http://ns.research.data.uq.edu.au/2012/eResearch/property/description

Identifier
: http://ns.research.data.uq.edu.au/2012/eResearch/property/identifier

Keyword
: http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_keyword

Field of Research
: http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_FoR

Socio-Economic Outcomes
: http://ns.research.data.uq.edu.au/2012/eResearch/property/tag_SEO

Contact email
: http://ns.research.data.uq.edu.au/2012/eResearch/property/contact_email

Web page
: http://ns.research.data.uq.edu.au/2012/eResearch/property/web_page

### Collection records

Type attribute values specific to collection record properties:

Temporal coverage
: http://ns.research.data.uq.edu.au/2012/eResearch/property/temporal

Spatial (geoname)
: http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_geoname

Spatial (point)
: http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_point

Spatial (polygon)
: http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_polygon

Spatial (text)
: http://ns.research.data.uq.edu.au/2012/eResearch/property/spatial_text

Access rights
: http://ns.research.data.uq.edu.au/2012/eResearch/property/rights_access

Rights statement
: http://ns.research.data.uq.edu.au/2012/eResearch/property/rights_statement

Licence
: http://ns.research.data.uq.edu.au/2012/eResearch/property/rights_licence

Creator of data
: http://ns.research.data.uq.edu.au/2012/eResearch/property/collection/createdBy

Manager of a data
: http://ns.research.data.uq.edu.au/2012/eResearch/property/collection/managedBy

Service to access data
: http://ns.research.data.uq.edu.au/2012/eResearch/property/collection/accessedVia

Data referenced in publication
: http://ns.research.data.uq.edu.au/2012/eResearch/property/collection/referencedBy

### Party records

Type attribute values specific to party record properties:

Name title
: "http://ns.research.data.uq.edu.au/2012/eResearch/property/name_title

Given name
: "http://ns.research.data.uq.edu.au/2012/eResearch/property/name_given

Family name
: "http://ns.research.data.uq.edu.au/2012/eResearch/property/name_family

Data created
: http://ns.research.data.uq.edu.au/2012/eResearch/property/party/creatorFor

Data managed
: http://ns.research.data.uq.edu.au/2012/eResearch/property/party/managerFor

Operates service
: http://ns.research.data.uq.edu.au/2012/eResearch/property/party/operatorFor

Participates in activity
: http://ns.research.data.uq.edu.au/2012/eResearch/property/party/participantIn

Author in publication
: http://ns.research.data.uq.edu.au/2012/eResearch/property/party/authorOf

### Activity records

Type attribute values specific to activity record properties:

Temporal coverage
: http://ns.research.data.uq.edu.au/2012/eResearch/property/temporal

Participant
: http://ns.research.data.uq.edu.au/2012/eResearch/property/activity/hasParticipant

Data produced
: http://ns.research.data.uq.edu.au/2012/eResearch/property/activity/producerFor

### Service records

Type attribute values specific to service record properties:

Operator
: http://ns.research.data.uq.edu.au/2012/eResearch/property/service/operatedBy

Data
: http://ns.research.data.uq.edu.au/2012/eResearch/property/service/providesAccessTo

#### Subtype property

All metadata records must have exactly one subtype property.

Permitted values for the subtype property depend on the type of metadata record.

For collection records, the following subtype values are allowed:

- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/collection
- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/collection/dataset

For party records, the following subtype values are allowed:

- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/party/person
- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/party/group
- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/party/position

For activity records, the following subtype values are allowed:

- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/activity/project
- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/activity/program

For service records, only the following subtype value is allowed:

- http://ns.research.data.uq.edu.au/2012/eResearch/subtype/service/report

Further information
-------------------

For further information on Thales, see the
[Thales project on GitHub](http://github.com/uq-eresearch/thales).
