Thales
======

Description
-----------

Thales is a Web application for managing metadata records about
collections. It is an editor for metadata records about collections
and related parties, activities and services - an information model
based on ISO 2146. It makes the metadata records available in the
_Registry Interchange Format - Collections and Services_ ([RIF-CS][])
format over an _Open Archives Initiative - Protocol for Metadata
Harvesting_ ([OAI-PMH][]) feed.

[RIF-CS]: http://www.ands.org.au/resource/rif-cs.html "RIF-CS"
[OAI-PMH]: http://www.openarchives.org/OAI/openarchivesprotocol.html "OAI-PMH"

Requirements
------------

Mandatory:

- Ruby (version 1.9.3 or later)
- Ruby on Rails (version 3.2.11 or later)
- [Bundler](http://gembundler.com) (or manage the gems manually)
- [PostgreSQL](http://www.postgresql.org/) (or another Ruby on Rails
  supported database)

Optional:

- [Ruby Version Manager (RVM)](https://rvm.io)

Installation
------------

1. Install Ruby and PostgreSQL. See
   [Installing Ruby and PostgreSQL on Fedora] for an example of how to
   do this.

1. Obtain a copy of the application:

        git clone https://github.com/uq-eresearch/thales.git

2. Change into the directory:

        cd thales

3. (Optional) If using RVM, create a project .rvmrc file:

        rvm --rvmrc --create ruby-1.9.3@thales

4. Install gems:

        bundle install

6. Configure connection between the application and PostgreSQL

    There are different ways of doing this. These instructions
    will assume PostgreSQL is running on the same machine as
    the Web application and a user name and password is used.
   
    a. Choose a database user name. These instructions uses "thales" as
       the database user name.

    b. Edit the PostgreSQL client authentication configuration
       file. The default allows local access (i.e. via Unix-domain
       sockets) for all users to all databases via peer authentication
       method (i.e. operating system user name matches the database
       user name).

        sudoedit /var/lib/pgsql/data/pg_hba.conf
		
	   Add the following line _before_ the other "local" entries.  It
	   allows local access (i.e. via Unix-domain sockets) to all
	   databases for the user "thales" if they can be authenticated
	   using the md5 method (i.e. can present a md5 digest of the
	   correct password).
	   
	        local  all   thales  md5

    c. Start PostgreSQL. If it is already running, restart it (so that
	   it loads the client authentication configuration file.)

        sudo service postgresql start

    d. Create the database user:

        sudo -u postgres psql
        postgres=# CREATE USER thales WITH CREATEDB PASSWORD 'p@ssw0rd';
        postgres=# \du
        postgres=# \q

    e. Edit configuration

    Edit _config/database.yml_ to set the username and password
    (for development, test and production environments) to the
    new PostgreSQL username and password.
	
	    vi config/database.yml

    Do this for the the three environments (development, test and production).
	
        ...
		username: thales
		password: p@ssw0rd
		...
		
7. Create, define and populate the database:

        rake db:create
        rake db:migrate
        rake db:seed

    After "rake db:migrate" has been run at least once, the rake
    targets of "db:setup" and "db:reset" can be used instead of the
    sequence of db:create, db:migrate and db:seed.

Operation
---------

1. Start PostgreSQL.

2. Start the Rails server (see [Starting the Rails server]).

3. Visit the start page <http://localhost:3000/> (replacing
   "localhost" with the correct hostname, if necessary.)  The initial
   account has the user name of "root" and no password.

4. Harvest from the OAI-PMH feed at <http://localhost:3000/oai>
   (replacing "localhost" with the correct hostname.)

### Managing the Rails server

#### Starting the Rails server

The rails server can be started using:

    rails server -d

Or use the helper script:

    script/server.sh start

#### Stopping the Rails server

The rails server can be stopped using:

    kill -s SIGINT processID

Where the _processID_ can be found in the file `tmp/pid/server.pid`.

Or use the helper script:

    script/server.sh stop

#### Other functions of the helper script

Run the helper script with `-h` (or `--help`) for more options.

    script/server.sh --help

To run the server with TLS/SSL, the server certificate needs to be
copied to _config/pki/server.crt_ and the unencrypted private key
copied to _config/pki/server.key_.

Installing Ruby and PostgreSQL on Fedora
----------------------------------------

This section describes how to install Ruby on a minimal installation
of [Fedora](https://fedoraproject.org) 18. It installs
[Ruby Version Manager (RVM)](https://rvm.io) for Ruby and uses the
PostgreSQL from the distribution. The steps will be
different for other environments.

These instructions assume you are using a non-root account and sudo.

1. Install packages needed by RVM

        sudo yum install postgresql-server
        sudo yum install git
        sudo yum install tar bzip2 make gcc gcc-c++
        sudo yum install zlib-devel openssl-dev
        sudo yum install readline-devel libyaml-devel libffi-devel \
                         libxml2-devel libxslt-devel postgresql-devel

    The first set is required for the distribution's installation of
    PostgreSQL. The second set is required to obtain the
    application. The third set is required for RVM. The fourth set is
    required for Bundler (and must be installed before RVM compiles
    Ruby). The fifth set is for other gems that the application needs.

2. Install [Ruby Version Manager](https://rvm.io/) and the latest
   stable Ruby (or explicitly specify `--ruby-1.9.3` to get that
   particular version of Ruby):

        curl -L https://get.rvm.io | bash -s stable --ruby
        . ~/.rvm/scripts/rvm

3. Initialize PostgreSQL:

        sudo postgresql-setup initdb

4. Configure firewalls

    Choose which TCP/IP port to run the Web application on (the
    default is 3000) and configure the firewall to allow access to
    that port.

    Fedora 18 uses [FirewallD] (instead of _iptables_ of previous
    releases).

        sudo firewall-cmd --list-all
		
        sudo firewall-cmd --add-port=3000/tcp
        sudo firewall-cmd --permanent --zone=public --add-port=3000/tcp

[Firewalld]: https://fedoraproject.org/wiki/FirewallD

#### Trouble shooting

##### ERROR: Gem bundler is not installed, run 'gem install bundler' first

The _zlib-devel_ and/or _openssl-devel_ packages were not installed
when Ruby was compiled, so _bundler_ was not installed. Install
these packages and reinstall Ruby.

        sudo yum install zlib-devel openssl-devel
        rvm list
        rvm uninstall ruby-1.9.3-p362 # using value obtained from list
        rvm install ruby-1.9.3-p362

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
