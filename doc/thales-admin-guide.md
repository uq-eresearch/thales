Thales Administration Guide
===========================

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

This guide describes how to setup Thales and manage users using the
Web interface; import and export metadata records using the command
line program; and access the machine readable OAI-PMH feed.

It is intended for people who manage the application.

### Related documents

The [Thales User Guide](thales-user-guide.md) describes how to use it
to create and modify metadata records.

The [Thales Installation Guide](thales-install-guide.md) describes how
to install Thales.

The [Thales Development Guide](thales-devel-guide.md) describes the
import/export file format.

Initial setup
-------------

### Overview

The initial set up of Thales involves:

- Logging in and setting the password.
- Configuring the metadata feed
- Creating extra users (optional)
- Populating the metadata store by either:
    - Importing metadata records, and/or
    - Creating them using the Web interface (see the [Thales User Guide](thales-user-guide.md).)
  
### First login

The default username is `root` and there is no password. The very
first step should be to set a password on the root account:

1. Login using the username 'root'.
2. Click on "Administration".
3. Click on the "root" user.
4. Click the "Edit user" button.
5. Enter a password into the "Password" and the "Confirm password" text fields.
6. Click the "Save user" button.

### Configuring the metadata feed

Thales publisheds the metadata records as a feed of [RIF-CS] formatted
records over [OAI-PMH]. The parameters of this feed needs to be
configured.

1. Click on "Administration".
2. Click on "Settings" (in the right side-navigation).
3. Click the "Edit settings" button.
4. Change the OAI-PMH and RIF-CS settings.
5. Click the "Save settings" button.

The [OAI-PMH] feed will be available at <http://localhost/oaipmh> and
<https://localhost/oaipmh> (replacing "localhost" with the correct
hostname.)


#### Parameters for OAI-PMH

The _repository name_ and _administrator email_ appears in the
response to the OAI-PMH _identify_ command.

The OAI-PMH version 2.0 specification says the repository name is "a
human readable name for the repository."

The OAI-PMH version 2.0 specification says the administrator email is
"the email address of an administrator of the repository."

#### Parameters for RIF-CS

The _group_ and _originating source_ are values that appear in the
header of every RIF-CS record.

The RIF-CS XML Schema says the group is "a string available for
grouping of repository objects, typically by organisation."

The RIF-CS XML Schema says the originating source is "a string or URI
identifying the entity holding the managed version of the registry
object metadata. For example in a federated aggregation context this
must identify the original repository or owning institution from which
the metadata was harvested *not* the aggregator from which it was
harvested."


OAI-PMH feed
------------

The [OAI-PMH] feed is available at:
[http://localhost/oaipmh](http://localhost/oaipmh?verb=Identify) and
[https://localhost/oaipmh](https://localhost/oaipmh?verb=Identify).

Note: replace "localhost" with the domain name of the server where
Thales has been installed.

Thales provides a feed of [RIF-CS] formatted metadata records using
the [OAI-PMH] metadata format prefix of `rif`. For example, to obtain
all the metadata records the following OAI-PMH query can be used:

<http://localhost/oaipmh?verb=ListRecords&metadataPrefix=rif>

Note: If there are no records in Thales, a noRecordsMatch error will
be returned.

User management
---------------

### Creating a new user

1. Click on "Administration".

2. Click the "New user" button.

3. Fill in the form. The given name and username are mandatory.

4. Click the "Create user" button.

To abort the process and not create a new user, click the "Cancel"
button.

### Viewing a user's details

1. Click on "Administration".

2. Click on the name of the chosen user.

### Editing a user's details


1. Click on "Administration".

2. Click on the name of the chosen user.

3. Click the "Edit user" button.

4. Change the information on the form.

5. Click the "Save user" button.

To abort the editing operation (discarding any changes), click the
"Cancel" button.

### Deleting a user

1. Click on "Administration" in the menu at the right side of the
page.

2. Click on the name of the chosen user.

3. Click the "Delete user button.

4. Click the "OK" button to confirm the delete operation. 


Administration program
----------------------

The `thales-admin.rb` command line program (found in the `script`
directory) can be used to perform a number of administration tasks.

For a list of options, run:

    script/thales-admin.rb --help

### Adapter

It is important to specify the database adapter to
_thales-admin.rb_. The database adapter is a name of a configuration
found in `config/database.yml`, and determines which database to
connect to.

In the example commands, the production database adapter will be used.

### Exporting metadata records

The export action dumps all the metadata records as XML. If an output
filename is provided, the XML is written to it; otherwise the XML is
outputted to stdout.

    script/thales-admin.rb -a production --export --output data.xml

The XML metadata dump format is described in the
[Thales Development Guide](thales-devel-guide.md).

All metadata records exported will contain the internal identifier for
the metadata record as its unique identifier.

### Importing metadata records

Metadata records can be imported from a file using the import action.

    script/thales-admin.rb -a production --import data.xml

#### Overwriting existing records

The metadata records in the XML metadata dump format can optionally
contain a unique identifier for the record. This is used to detect
importing of a metadata record that already exists in the
database. The rules are:

- If the record being imported does not have a unique identifier, the
  is treated as a new metadata record and a new internal identifier is
  generated for it.
  
- If the record being imported has a unique identifer that does not
  match any internal identifer, the record is treated as a new
  metadata record and the unique identifier is used as the internal
  identifier.

- If the imported record has a unique identifier that matches an
  existing internal identifer, it is considered the same metadata
  record.
  
   - If `--force` has not been specified, an error will be raised.
   
   - If `--force` has been specified, the imported record will replace
     the matching record.

#### OAI-PMH publish status of imported records

If the imported records contains an explicit OAI-PMH status, that
value will be used. If the imported record does not contain an
explicit OAI-PMH status, the default value will be used.

The default OAI-PMH publish status is "unpublished", unless the
`--oaipmh_default` argument is provided to specify a different
default.

    ./script/thales-admin.rb -a production --import data.xml --oaipmh_default active

If the `--oaipmh_force` argument is provided, that status value will
be used for all the imported records (the default and any explicit
status in the record will both be ignored).

    ./script/thales-admin.rb -a production --import data.xml --oaipmh_force deleted

The allowed values for `--oaipmh_default` and `--oaipmh_force` are:
`unpublished`, `active` and `deleted`.

#### Updating the timestamp

The `--touch` option updates the timestamp of all active metadata records.

    ./script/thales-admin.rb -a production --touch

This action is useful for forcing harvesters to re-harvest all the
metadata records.

### Purging database

To remove all records from the database use the `--delete` option:

    ./script/thales-admin.rb --adapter production --delete

The delete command can be combined with the import command. To delete
all records from the database and then import records from a file
(i.e. after running, the only records in the database will be the
imported ones):

    ./script/thales-admin.rb --adapter production --import filename.xml --delete

Warning: this command removes all trace of the old metadata records
and therefore the OAI-PMH feed will not contain any deletion records
for the old metadata records. If the feed claims to have "persistent"
support for deleted records and there were some records in the
database, this would violate that claim. But, the default claim is
there is only "transient" support for deleted records, and so that
claim will not be violated.

Further information
-------------------

For further information on Thales, see the
[Thales project on GitHub](http://github.com/uq-eresearch/thales).
