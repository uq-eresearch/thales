Thales
======

Overview
--------

Thales is a Web application for managing metadata records about
collections. It is an editor for metadata records about collections,
parties, activities and services - an information model based on ISO
2146. And it makes the metadata records available in the _Registry
Interchange Format - Collections and Services_ (RIF-CS) format over an
_Open Archives Initiative - Protocol for Metadata Harvesting_
(OAH-PMH) feed.

[1] http://www.ands.org.au/resource/rif-cs.html
[2] http://www.openarchives.org/OAI/openarchivesprotocol.html

Description
-----------


Requirements
------------

Mandatory:

- Ruby (version 1.9.3 or later)
- Ruby on Rails (version 3.2.11 or later)
- [Bundler](http://gembundler.com)
- PostgreSQL

Optional:

- [Ruby Version Manager (RVM)](https://rvm.io)

Installation
------------

1. Setup an environment with Ruby. See _Setup Ruby on Fedora_ (below)
for an example of how to do this.

1. Obtain a copy of the application:

        git clone https://github.com/uq-eresearch/thales.git

2. Change into the directory:

        cd thales

3. (Optional) If using RVM, create a project .rvmrc file:

        rvm --rvmrc --create ruby-1.9.3@thales

4. Install gems:

        bundle install

5. Initialize PostgreSQL:

        sudo postgresql-setup initdb

6. Configure connection between the application and PostgreSQL

   Choose a database user name. The default is "thales", but
   this can be changed.

   If necessary, edit the PostgreSQL client authentication
   configuration file. The default allows local access (i.e. via
   Unix-domain sockets) for all users to all databases via peer
   authentication method (i.e. operating system user name matches
   the database user name).

        sudoedit /var/lib/pgsql/data/pg_hba.conf

   Start PostgreSQL:

        sudo service postgresql start

   Create user:

        sudo -u postgres psql
        postgres=# CREATE USER thales WITH CREATEDB PASSWORD 'foobar';
        postgres=# \q

7. Edit configuration

   Edit _config/database.yml_ to set the username and password
   (for development, test and production environments) to the
   new PostgreSQL username and password.

8. Create database:

        rake db:create
        rake db:migrate
        rake db:seed

After "rake db:migrate" has been run at least once, the rake targets
of "db:setup" and "db:reset" can be used instead of the sequence of
db:create, db:migrate and db:seed.


### Setup Ruby on Fedora

Ruby runs on many different enviromnents and there are many different
ways of setting it up.

This section describes how to install Ruby on a minimal installation
of [Fedora](https://fedoraproject.org) 18 and using the [Ruby Version
Manager (RVM)](https://rvm.io). The steps might be different if you
are using a different setup.

1. Install packages needed by RVM

These packages are needed to build gems that are used by the
application. They must be installed _before_ RVM compiles Ruby.

- zlib-devel is needed by gem install (install before compiling Ruby)
- openssl-devel is needed by bundle (install before compiling Ruby)

        yum install

These packages are needed to install RVM and for RVM to compile Ruby.

        yum install tar bzip2 make gcc gcc-c++

These packages are required for the gems:

        yum install \
          readline-devel \
          zlib-devel \
          openssl-devel \
          libyaml-devel \
          libffi-devel \
          iconv-devel \
          libxslt-devel \
          sqlite-devel \
          postgresql-devel \
          postgresql-server

This package is required to obtain the application:

        yum install git

2. Install [Ruby Version Manager](https://rvm.io/) and the latest
   stable Ruby (or explicitly specify `--ruby-1.9.3` to get that
   version):

        curl -L https://get.rvm.io | bash -s stable --ruby
        . ~/.rvm/scripts/rvm

3. Configure firewalls

Thales runs on port 3000, but this can be changed.

Configure any firewalls to allow access to port 3000.

Fedora 18 uses _FirewallD_ (instead of _iptables_ of previous releases).
https://fedoraproject.org/wiki/FirewallD

        firewall-cmd --get-active-zones
        sudo firewall-cmd --list-all
        sudo firewall-cmd --add-port=3000/tcp

        sudo firewall-cmd --permanent --add-port=3000/tcp

#### Trouble shooting

ERROR: Gem bundler is not installed, run `gem install bundler` first

The _zlib-devel_ and/or _openssl-devel_ packages were not installed
when Ruby was compiled, so _bundler_ was not installed. Install
these packages and reinstall Ruby.

        sudo yum install zlib-devel openssl-devel
        rvm list
        rvm uninstall ruby-1.9.3-p362 # using value obtained from list
        rvm install ruby-1.9.3-p362


Operation
---------

1. Start the Rails server (see below).

2. Visit the start page _http://localhost:3000/_ 
   Replace "localhost" with the correct hostname, if necessary.

3. Harvest from the OAI-PMH feed at _http://localhost:3000/oai_

4. Stop the Rails server (see below).

### Managing the Rails server

#### Starting the rail server

The rails server can be started using:

    rails server -d

Or use the helper script:

    script/server.sh start

#### Stopping the rails server

The rails server can be stopped using:

    kill -s SIGINT processID

Where the _processID_ can be found in the file `tmp/pid/server.pid`.

Or use the helper script:

    script/server.sh stop

#### Other functions of the helper script

Run the helper script with `-h` (or `--help`) for more options.

    script/server.sh --help

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
