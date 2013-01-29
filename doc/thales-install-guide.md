Thales Installation Guide
=========================

Requirements
------------

Mandatory:

- Git
- [PostgreSQL](http://www.postgresql.org/) (or another Ruby on Rails
  supported database)
- Ruby (version 1.9.3 or later)
- [Bundler](http://gembundler.com) (or manage the gems manually)

Bundler will be used to install the required gems, such as: _Ruby on
Rails_ (3.2.11), _nokogiri_, _pg_ and _ruby-oai_.

Optional:

- [Ruby Version Manager (RVM)](https://rvm.io)

Installation
------------

### Common to both development and production installations

1. Install the required software: Git, PostgreSQL, Ruby and
   Bundler. See [Installing software on Fedora] for an example of how
   to do this.

1. Obtain a copy of the application:

        git clone https://github.com/uq-eresearch/thales.git

2. Change into the directory:

        cd thales

3. (Optional) If using RVM, create a project .rvmrc file:

        rvm --rvmrc --create ruby-1.9.3@thales

4. Install gems:

        bundle install

    This will install Ruby on Rails, as well as the other required
	gems.
	
6. Configure the connection between the application and PostgreSQL

    There are different ways of doing this. These instructions will
    assume PostgreSQL is running on the same machine as the Web
    application and a user name and password is used.  Another common
    method is to use the same database username as the login
    username. See the
    [PostgreSQL documentation on client authentication](http://www.postgresql.org/docs/9.2/interactive/client-authentication.html)
    for more details.
	
   
    a. Choose a database user name. These instructions uses "thales" as
       the database user name.

    b. Edit the PostgreSQL client authentication configuration
       file. The default allows local access (i.e. via Unix-domain
       sockets) for all users to all databases via peer authentication
       method (i.e. operating system user name matches the database
       user name), but it will be edited to add password authentication.

        sudoedit /var/lib/pgsql/data/pg_hba.conf
		
	   Add the following line _before_ the other "local" entries.  It
	   allows local access (i.e. via Unix-domain sockets) to all
	   databases for the user "thales" if they can be authenticated
	   using the md5 method (i.e. can present a md5 digest of the
	   correct password).
	   
	        local  all   thales  md5

    c. Start PostgreSQL.

        sudo service postgresql start

       If it is already running, restart it (so that it loads the
	   client authentication configuration file.)

        sudo service postgresql restart

Please continue with the [Development installation] or
[Production installation] instructions.

### Development installation

These steps continue on from the [Common to both development and production installations].

These steps assume the Web application is run using the WEBrick HTTP
server, which comes as standard with Ruby 1.9.3.

1. Create PostgreSQL user.

        $ sudo -u postgres psql
        postgres=# CREATE USER thales WITH CREATEDB PASSWORD 'p@ssw0rd';
        postgres=# \du
        postgres=# \q

	   Note: The CREATEDB role allows the user to drop any database
	   (not just the ones it owns). This can be a security risk, so
	   please consider if it is suitable for your setup before using
	   it.  The CREATEDB role is needed if you want to run the RSpec
	   tests and the db:create Rake task.
		
2. Edit configuration

    Edit _config/database.yml_ to set the username and password to the
	new PostgreSQL username and password.
	
	    vi config/database.yml

    Do this for the development and test environments.
	
	    development:
          ...
		  username: thales
		  password: p@ssw0rd
		  ...
	    test:
          ...
		  username: thales
		  password: p@ssw0rd
		  ...
		
3. Create, define and populate the development database.

        rake db:create
        rake db:migrate
        rake db:seed

4. Run the RSpec tests.

        rake spec
	
5. Start the development Rails server (see [Starting the Rails server]).

The application can be accessed by visiting <http://localhost:3000/>
(replacing "localhost" with the correct hostname, if necessary.)  The
initial account has the user name of "root" and no password.

The OAI-PMH feed will be available at <http://localhost:3000/oai>
(replacing "localhost" with the correct hostname.)


### Production installation

These steps continue on from the [Common to both development and production installations].

These steps assume the Web application is run using the
[Unicorn](http://unicorn.bogomips.org) HTTP server; that HTTP server
is started using the [Bluepill](https://github.com/arya/bluepill)
process monitor; and [nginx](http://nginx.org) is used to provide
TLS/SSL security.

1. Create PostgreSQL user and the production database.

        $ sudo -u postgres psql
        postgres=# CREATE USER thales WITH PASSWORD 'p@ssw0rd';
        postgres=# \du
        postgres=# CREATE DATABASE thales OWNER thales;
        postgres=# \l
        postgres=# \q

	
2. Edit configuration

    Edit _config/database.yml_ to set the username and password to the
    new PostgreSQL username and password.
	
	    vi config/database.yml

    Do this for the production environment.
	
	    production:
          ...
		  username: thales
		  password: p@ssw0rd
		  ...
  
3. Define and populate the database.

        RAILS_ENV=production rake db:migrate
        RAILS_ENV=production rake db:seed

4. Precompile the assets.

        RAILS_ENV=production rake assets:precompile

5. Install Bluepill.
   **This step needs work work.**

    a. Install Bluepill.
   
        rvmsudo gem install bluepill

    b. Configure logging according to the
    [Bluepill installation instructions](https://github.com/arya/bluepill#readme).

    c. Create direcoty for Bluepill's pid and sock files.
   
        sudo mkdir /var/run/bluepill
		
6. Install the init.d startup script.
   **This step needs more work.**

    a. Install the Bluepill configuration file.
   
        sudo cp script/thales.pill /etc/bluepill/thales.pill
		
    b. Copy the init.d script to the /etc/init.d directory.
   
        sudo cp script/thales-bluepill.init /etc/init.d/thales.init

7. Install nginx.
   **This step needs more work.**
   
8. Start the server.

        sudo service thales start

#### TLS/SSL in the production deployments

Thales will enforce the use of HTTPS for logins and user settings
pages in the production environment
(i.e. `RAILS_ENV=production`). That is, requests over HTTP to those
pages are redirected to the equivalent HTTPS URL.

If you need to run in a production environment where HTTPS is not
available, run it with `DISABLE_HTTPS=1` in the environment to
disable this.

Operation
---------

### Managing the development Rails server

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


Installing software on Fedora
-----------------------------

This section describes how to install Ruby on
[Fedora](https://fedoraproject.org) 18. It uses:

- Fedora with a _minimal install_ software selection.
- [Ruby Version Manager (RVM)](https://rvm.io) for Ruby.
- PostgreSQL from the distribution.

Thales can be installed on other environments. It has been
successfully installed on Fedora 17 and CentOS 6.3.  The steps will be
slightly different when installing on other environments.

These instructions assume you are using a non-root account and sudo.

1. Install packages needed by RVM

        sudo yum install  postgresql-server \
          git \
          tar bzip2 make gcc gcc-c++ \
          zlib-devel openssl-devel \
          readline-devel libyaml-devel libffi-devel libxml2-devel libxslt-devel postgresql-devel

    The first line for the distribution's installation of
    PostgreSQL. The second line is for Git, used to obtain the
    application. The third line is required for RVM. The fourth line
    is required for Bundler (and must be installed before RVM compiles
    Ruby). The fifth line is required for other gems that the
    application needs.

2. Install [Ruby Version Manager](https://rvm.io/) and Ruby 1.9.3:

        curl -L https://get.rvm.io | bash -s -- --version 1.9.3
        . ~/.rvm/scripts/rvm

    Thales has been tested with Ruby 1.9.3-p374.
	
3. Initialize PostgreSQL:

        sudo postgresql-setup initdb

4. Configure firewalls

    Choose which TCP/IP port for the Web application and configure the
	firewall to allow access to that port.  For development and
	testing the default is port 3000. For production, you probably
	want to use port 80 or 443.

    Fedora 18 uses [FirewallD] (instead of _iptables_ of previous
    releases).

        sudo firewall-cmd --get-active-zones
        sudo firewall-cmd --list-all --zone=public
		
        sudo firewall-cmd --add-port=3000/tcp     # Note: not permanent
		
        sudo firewall-cmd --permanent --zone=public --add-port=3000/tcp
		
        sudo firewall-cmd --add-service=http     # Note: not permanent

[Firewalld]: https://fedoraproject.org/wiki/FirewallD

Trouble shooting
----------------

**ERROR: Gem bundler is not installed, run 'gem install bundler' first**

The _zlib-devel_ and/or _openssl-devel_ packages were not installed
when Ruby was compiled, so _bundler_ was not installed. Install
these packages and reinstall Ruby.

        sudo yum install zlib-devel openssl-devel
        rvm list
        rvm uninstall ruby-1.9.3-p362 # using value obtained from list
        rvm install ruby-1.9.3-p362

**Data directory is not empty!**

PostgreSQL has already been initialized. You do not need to run
`sudo postgresql-setup initdb` again.

**PG::Error: ERROR:  permission denied to create database**

The PostgreSQL user does not have permission to create or drop
databases. This error is usually encountered when trying to run Rake
targets such as: db:create, db:drop, db:setup, db:reset or spec.

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
