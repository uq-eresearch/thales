Thales User Guide
=================

Quick start
-----------

The Web application is running on <http://localhost:3000> (substitute
with the actual host name and port number it is running on.)

Sign in with your user name and password. Initially, it is set up with
a single user name of "root" with no password. The first thing you
should do is to set a password.

To create a new metadata record, select one of the "new" links from
the menu at the right side of the page.

Records
-------

### Publishing records

Thales is initially setup so the OAI-PMH feed tracks deleted records.

Records are created with an OAI-PMH publishing status of either "not
in feed" or "published record in the feed".

- Records that are "not in feed" can be changed to being a "published
  record in the feed".

- Records that are a "published record in the feed" record can be
  changed to being a "deleted record in the feed". But they can never
  be changed to "not in feed."

- Records that are a "deleted record in the feed" can be changed to
  being a "published record in the feed" (i.e. undeleting them). But
  they can never be changed to "not in feed".

That is, once a record has been published, it always remains in the
feed (either as a published record or as a deleted record).


Collection records
------------------





### Creating a new collection record

1. New collection record

2. Edit values

3. Click "Save"





Contact
-------

For more information, please contact [Hoylen Sue](mailto:h.sue@uq.edu.au)
or [The University of Queensland eResearch Lab](http://itee.uq.edu.au/~eresearch/).

Acknowledgements
----------------

This project is supported by the Australian National Data Service
([ANDS](http://www.ands.org.au/)). ANDS is supported by the Australian
Government through the National Collaborative Research Infrastructure
Strategy Program and the Education Investment Fund (EIF) Super Science
Initiative.
