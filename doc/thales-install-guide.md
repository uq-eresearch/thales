Thales Installation Guide
=========================

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

This guide describes how to install Thales: either for development or
production. It also provides example instructions on setting up the
software Thales depends upon.

It is intended for people who install the application.

### Related documents

The [Thales User Guide](thales-user-guide.md) describes how to use it
to create and modify metadata records.

The [Thales Admin Guide](thales-admin-guide.md) describes how to setup
and manage Thales.

The [Thales Development Guide](thales-devel-guide.md) describes the
import/export file format.


Requirements
------------

Thales is a Ruby on Rails Web application. It can run on any platform
that support Ruby on Rails.  By default, it is configured to use
PostgreSQL.

Mandatory:

- Git
- [PostgreSQL](http://www.postgresql.org/) (or another Ruby on Rails
  supported database)
- Ruby 1.9.3 (Note: dependent Gems do not yet work with Ruby 2.0.)
- [Bundler](http://gembundler.com) (or manage the gems manually)

Bundler will be used to install the required gems, such as: _Ruby on
Rails_ (3.2.11), _nokogiri_, _pg_ and _ruby-oai_.

Optional:

- [Ruby Version Manager (RVM)](https://rvm.io)

See [Example platform setup] for instructions on using some Linux
distributions as the platform.

Installation
------------


### Common to both development and production installations

1. Obtain a copy of the application:

        git clone https://github.com/uq-eresearch/thales.git

    Note: if deploying a production installation, consider carefully
    where the application will be installed, because the reverse proxy
    will need to access some of the files, but it is usually running
    as a differnt user to the owner of the files. For a production
    deployment consider installing it under somewhere like `/opt`
    where the permissions can allow all users read access.
	
2. Change into the project directory:

        cd thales

3. (Optional) If using RVM, create a project .rvmrc file:

        rvm --rvmrc --create ruby-1.9.3@thales

4. Install gems:

        bundle install

    This will install Ruby on Rails, as well as the other required
	gems. If this is for a production-only installation, unnecessary
	gems can be excluded by using `bundle install
	--without="development test"`.
	
5. Configure the connection between the application and PostgreSQL

    There are different ways of doing this. These instructions will
    assume PostgreSQL is running on the same machine as the Web
    application and _password authentication_ is used.  Another common
    method is to use _trust authentication_, where the database
    username is the same as the operating system login username. See the
    [PostgreSQL documentation on client authentication](http://www.postgresql.org/docs/9.2/interactive/client-authentication.html)
    for more details.
	
   
    a. Choose a database user name. These instructions uses "thales" as
       the database user name, but any database user name can be used.
	   
 	   If the database user name is the same as the login user name
	   nothing more needs to be done, since by default PostgreSQL is
	   setup to accept Unix socket connections from local users.
	   
	   If the database user name is different from the login user name,
	   continue with the next step.

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

6. Start or restart PostgreSQL.

     If PostgreSQL is already running, restart it (so that it loads the
	 client authentication configuration file.)

        sudo service postgresql start

Please continue with the [Development installation] or
[Production installation] instructions.

### Development installation

These steps continue on from the [Common to both development and production installations].

1. Create PostgreSQL user with the CREATEDB role.

        $ sudo -u postgres psql
        postgres=# CREATE USER thales WITH CREATEDB PASSWORD 'p@ssw0rd';
        postgres=# \du
        postgres=# \q

       If using PostgreSQL _trust authentication_, the password can be omitted.

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

    The tests should run without producing any failures.

5. If using the Unicorn Web server for development testing, create the
   directory to hold the PID file (that was specified in the Unicorn
   config file) and make sure it is writable by the Unicorn process
   worker (see config/unicorn.rb). This is important because Unicorn
   will fail if the directory not exist.

        mkdir -p tmp/pids
		
    If using the WEBrick Web server, this is not necssary because it will
    automatically create the temporary directories it needs.

6. Start the development Rails server (see [Starting the Rails server]).

The application can be accessed by visiting <http://localhost:3000/>
(replacing "localhost" with the correct hostname, if necessary.)  The
initial account has the user name of "root" and no password.

The OAI-PMH feed will be available at <http://localhost:3000/oai>
(replacing "localhost" with the correct hostname.)


### Production installation

These steps continue on from the
[Common to both development and production installations].

These steps assume the production Web application is run using the
[Unicorn](http://unicorn.bogomips.org) HTTP server and
[nginx](http://nginx.org) is used to provide TLS/SSL security.

#### Common

1. Create PostgreSQL user and the production database.

        $ sudo -u postgres psql
        postgres=# CREATE USER thales WITH PASSWORD 'rte0vurt3spes6ryqu5mo9hy9pybi2ra';
        postgres=# \du
        postgres=# CREATE DATABASE thales OWNER thales;
        postgres=# \l
        postgres=# \q

	If using PostgreSQL _trust authentication_, the password can be omitted.
   
    Note: unlike in development, this database user does not have the
    CREATEDB role to improve security.
	
2. Edit configuration

    Edit _config/database.yml_ to set the username and password to the
    new PostgreSQL username and password.
	
	    vi config/database.yml

    Do this for the production environment.
	
	    production:
          ...
		  username: thales
		  password: rte0vurt3spes6ryqu5mo9hy9pybi2ra
		  ...
  
3. Define and populate the database.

        RAILS_ENV=production rake db:migrate
        RAILS_ENV=production rake db:seed

4. Precompile the assets.

        RAILS_ENV=production rake assets:precompile

5. Create a wrapper script so that Unicorn can be run in the correct
   RVM gemset. The second argument is the name of the gemset.

        rvm wrapper `rvm current` thales unicorn

    This will create a wrapper script called `~/.rvm/bin/thales_unicorn`.

6. Edit the Unicorn configuration file. Set the following:

    - THALES_PROJ_DIR to where the sources have been installed;
	- _pid_ to the location of the PID file (e.g. /var/run/thales/unicorn.pid);
	- _user_ to the user that owns the worker processes.

            vi config/unicorn.rb

     Take note of the location of the PID file and user defined in
     this configuration file for the next step.
	 
7. Create the directory to hold the PID file and make sure it is
   writable by the Unicorn process worker (both are specified in the
   Unicorn config file). This is important because Unicorn will fail
   if the directory does not exist.

        mkdir -p tmp/pids
	
Continue with either the [Basic startup] or
[Startup using Bluepill process monitor] steps.

#### Basic startup

This option uses a basic init.d script to start and stop the Unicorn
HTTP server.

1. Configure the application to automatically start when the OS starts.

    a. Copy the init.d script (basic) to the /etc/init.d directory.
   
        sudo cp script/thales-basic.init /etc/init.d/thales

    b. Edit it to set:
	
       - PROJ_DIR to the directory where Thales has been installed;
	   - UNICORN to the wrapper script created in step 5; and
	   - PID_FILE to the path to the PID file in _config/unicorn.rb_
	  
            sudoedit /etc/init.d/thales
		
    c. Register it.
   
        sudo chkconfig thales on

2. Start the application.
   
        sudo service thales start

    The application will be running on port 30123 (unless you change
    it in the init.d script).
	
    Attempting to access http://localhost:30123 from the host (since
	the firewall should be blocking external access to this port)
	should return a HTTP redirection to the (currently non-existent)
	HTTPS secured login page.

    Other available commands are:

        sudo service thales status
        sudo service thales restart
        sudo service thales stop
	
	
Continue with the [Reverse proxy server setup] steps.
   
#### Startup using Bluepill process monitor

This option uses the [Bluepill](https://github.com/arya/bluepill)
process monitor to manage the Unicorn HTTP server.

1. Install Bluepill.

    a. Install the Bluepill gem.
   
        gem install bluepill

    b. Configure logging according to the
    [Bluepill installation instructions](https://github.com/arya/bluepill#readme).

2. Create a wrapper script so that Bluepill can be run in the correct
   RVM gemset. The second argument is the name of the gemset.

        rvm wrapper `rvm current` thales bluepill

    This will create a wrapper script called `~/.rvm/bin/thales_bluepill`.

3. Configure Bluepill by editing the Thales Bluepill config file. Edit
   it to set:

    - USER to the user name to run the Unicorn processes as.
    - RAILS_ROOT to the directory where Thales is installed
    - UNICORN to the location of the Unicorn wrapper script.

            vi config/bluepill.pill
		
	
4. Configure the application to automatically start when the OS starts.

    a. Copy the init.d script (Bluepill) to the /etc/init.d directory.
   
        sudo cp script/thales-bluepill.init /etc/init.d/thales

    b. Edit it to set:
	
       - BLUEPILL_BIN to the wrapper script for Bluepill created above.
	   - BLUEPILL_CONFIG to the location of the above Bluepill config file.

            sudoedit /etc/init.d/thales
		
    c. Register it.
   
        sudo chkconfig thales on

5. Start the application.

        sudo service thales start

    The application will be running on port 30123 (unless it was changed
    in the _init.d_ script).
	
    Attempting to access http://localhost:30123 from the host (since
	the firewall should be blocking external access to this port)
	should return a HTTP redirection to the (currently non-existent)
	HTTPS secured login page.

    Other available commands are:

        sudo service thales status
        sudo service thales restart
        sudo service thales stop

Continue with the [Reverse proxy server setup] steps.

##### Reverse proxy server setup

This section continues from either [Basic startup] or
[Startup using Bluepill process monitor].

A reverse proxy server will be used to efficiently serve static
content and the content from the Unicorn HTTP server. It will also be
used to provide TLS/SSL security.


1. Install [nginx](http://nginx.org).

    In these steps, we will download and compile nginx, instead
    of using the distribution's release.
   
    a. Download the sources from <http://nginx.org>

		pushd ~
		curl -O http://nginx.org/download/nginx-1.2.7.tar.gz

    b. Unpack the sources.
   
        tar xfz nginx-1.2.7.tar.gz
		cd nginx-1.2.7
	
    c. Ensure dependencies are installed.
	
       Either:

       i. If the distribution uses yum (e.g. Fedora and RHEL):
	   
        sudo yum install gcc pcre pcre-devel zlib zlib-devel openssl openssl-devel
		
	   ii. If the  distribution uses apt-get (e.g. Ubuntu):
        
		sudo apt-get install build-essential libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev

    d. Compile and install. There are many options, but the essential
       one is the SSL module.

        ./configure --help
        ./configure --with-http_ssl_module
        make
        sudo make install

2. Create a user account to run _nginx_.
	
	    sudo useradd --shell /sbin/nologin --home-dir /usr/local/nginx -c "Nginx server" nginx

    The warning about the home directory already existing can be ignored.
   
3. Change file and directory permissions to allow the nginx user
   to read the precompiled asset files. How this is done will depend
   on where the application was installed. For example, if they were
   installed in the user's home directory:

        namei -l /home/thales/thales/public/assets
        chmod o+rx /home/thales

4. Configure _nginx_ to proxy requests to the Unicorn HTTP server
   running on port 30123, and to serve both HTTP and HTTPS requests.

    a. Obtain a TLS/SSL certificate for the site.
	
	   For testing, you could use a self-signed test certificate. See
	   [Creating a self-signed test certificate] for one way of creating
	   a test certificate.
	
    b. Install the certificate and its (unencrypted) private key.

        pushd ~/pki-credentials-for-my-domain
	    sudo cp tls.crt /usr/local/nginx/conf/tls.crt
		sudo cp tls.key /usr/local/nginx/conf/tls.key
		sudo chmod 444 /usr/local/nginx/conf/tls.crt
        sudo chmod 400 /usr/local/nginx/conf/tls.key # keep private key secure!
		popd
		
    c. Configure nginx. You can use the supplied example configuration
	   file as a starting point, but remember to optimize it for your
	   setup.
	
	    popd  # to return to thales source directory
	    sudo cp config/nginx.conf /usr/local/nginx/conf/nginx.conf

    d. Start nginx
	
        sudo /usr/local/nginx/sbin/nginx
	
	e. Test the server by visiting <http://localhost> and <https://localhost>.

       Please see the
       [Thales Administration guide](thales-admin-guide.md) for
       information on how to login and set it up for use.
		
      Note: a common problem is the HTML page appears, but without the
	  CSS styling. This is usually a permissions problem: the _nginx_
	  user does not have permissions to read the static asset
	  files. Usually one of the parent directories does not have read
	  and execute permissions for other users.
	
	f. If necessary, modify the configuration and retest.
	
         sudoedit /usr/local/nginx/conf/nginx.conf
         sudo /usr/local/nginx/sbin/nginx -t
         sudo /usr/local/nginx/sbin/nginx -s reload

    g. When finished, manually stop the nginx server.
     
         sudo /usr/local/nginx/sbin/nginx -s quit

4. Setup _nginx_ to start automatically when the OS starts.

#### TLS/SSL in the production deployments

Thales will enforce the use of HTTPS for logins and user settings
pages in the production environment
(i.e. `RAILS_ENV=production`). That is, requests over HTTP to those
pages are redirected to the equivalent HTTPS URL.

If you need to run in a production environment where HTTPS is not
available, run it with `DISABLE_HTTPS=1` in the environment to
disable this.

Operating the development server
--------------------------------

### Managing the Rails server

These instructions describe how to use WEBrick or Unicorn 
as the development HTTP server.

WEBrick comes with Ruby 1.9.3 and is the standard Rails development
server. It is not recommended for production use.

[Unicorn] is a fast HTTP server and its gem is included in the project.
It can be used in production and in development.

[Unicorn]: http://unicorn.bogomips.org

#### Starting the Rails server

##### WEBrick

The WEBrick HTTP server can be manually started in development mode using:

    rails server -d

Or use the helper script:

    script/server.sh start

##### Unicorn

The Unicorn HTTP server can be manually started in development mode using:

    unicorn -D -c config/unicorn.rb --port 3000

Note: if the port number is not specified, the default is 8080.

#### Stopping the Rails server

##### WEBrick

The WEBrick HTTP server can be manually stopped using:

    kill -s SIGINT processID

Where the _processID_ can be found in the file `tmp/pid/server.pid`.

Or use the helper script:

    script/server.sh stop

##### Unicorn

The Unicorn HTTP server can be manually stopped using:

    kill -s SIGQUIT processID

Where the _processID_ can be found by running `ps -ef | grep "unicorn master"`.

#### Other functions of the helper script

Run the helper script with `-h` (or `--help`) for more options.

    script/server.sh --help

To run the server with TLS/SSL, the server certificate needs to be
copied to _config/pki/server.crt_ and the unencrypted private key
copied to _config/pki/server.key_.


Example platform setup
----------------------

This section describes how to setup the required software on Linux.

These steps might be different for different Linux distributions and
different configurations. These steps have been tested with a minimal
install of:

- [Fedora](https://fedoraproject.org) 18
- [CentOS](https://www.centos.org) 6.3
- [Scientific Linux](https://www.scientificlinux.org) 6.3
- [Ubuntu](http://www.ubuntu.com) 12.10

These steps have chosen to use:

- Single-user installation of [Ruby Version Manager (RVM)](https://rvm.io)
  for Ruby
- PostgreSQL from the distribution.

These instructions use a non-root account with sudo access. By
default, the configuration files and scripts assume the user name is
"thales", but any username can be used.

1. Install packages needed by RVM

    Either:
   
    a. If the distribution uses yum (e.g. Fedora and RHEL):
	
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

    b. If the distribution uses apt-get (e.g. Ubuntu):
	
	     sudo apt-get install \
           build-essential openssl libreadline6 libreadline6-dev curl git-core \
		   zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev \
		   autoconf libc6-dev libgdbm-dev ncurses-dev automake \
		   libtool bison subversion pkg-config libffi-dev \
           libpg-dev

2. Install [Ruby Version Manager](https://rvm.io/) and Ruby.

        curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
        . ~/.rvm/scripts/rvm

    Thales has been tested with Ruby 1.9.3-p374.
	
	As of 14 March 2013, it does not work with Ruby 2.0, because one
	of the Gems it uses (ruby-oai 0.0.9) does not work with Ruby
	2.0.0.
	
3. Initialize PostgreSQL.

    a. For PostgreSQL 9.x:
	
        sudo postgresql-setup initdb

    b. For PostgreSQL 8.x:
	
        sudo service postgresql initdb
   
4. Setup PostgreSQL to start automatically when the OS starts.

        sudo chkconfig postgresql on

5. Configure firewalls

    Choose which TCP/IP port for the Web application and configure the
	firewall to allow access to that port.  For development and
	testing the default is port 3000. For production, you will
	want to use port 80 or 443.

    a. FirewallD
	
    For systems running [FirewallD] (e.g. Fedora 18).

    Show the active zones and current settings for the public zone:
	
        sudo firewall-cmd --get-active-zones
        sudo firewall-cmd --list-all --zone=public
		
    For development, allow use of port 3000:
	
        sudo firewall-cmd --add-port=3000/tcp     # Note: not permanent
        sudo firewall-cmd --permanent --zone=public --add-port=3000/tcp
	
	For production, allow use of the standard ports of 80 and 443:
	
        sudo firewall-cmd --add-service=http     # Note: not permanent
        sudo firewall-cmd --permanent --zone=public --add-service=http
        sudo firewall-cmd --add-service=https     # Note: not permanent
        sudo firewall-cmd --permanent --zone=public --add-service=https

    b. iptables
	
    For systems running _iptables_.
	
	Edit the iptables configuration file:
	
	    sudoedit /etc/sysconfig/iptables
		
	Add the following lines:
	
        -A INPUT -m state --state NEW -m tcp -p tcp --dport 3000 -j ACCEPT
        -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
        -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
		
	Restart _iptables_ so the new settings are used:
	
	    sudo service iptables restart
	
[Firewalld]: https://fedoraproject.org/wiki/FirewallD

Creating a self-signed test certificate
---------------------------------------

These commands can be used to create a self-signed certificate for
testing purposes:

    openssl req -newkey rsa:2048 -nodes -keyout tls.key -out tls.csr
    # Above command will prompt for extra information	
	openssl x509 -req -in tls.csr -signkey tls.key -days 90 -out tls.crt
    rm tls.csr
	chmod 444 tls.crt
	chmod 400 tls.key
			
Trouble shooting
----------------

**ERROR: Gem bundler is not installed, run 'gem install bundler' first**

Attempting to run 'gem install bundler' (as suggested by the error
message) will usually fail with another error that says "Loading
command: install (LoadError) cannot load such file -- zlib".

The _zlib-devel_ and/or _openssl-devel_ packages were not installed
when Ruby was compiled, so _bundler_ was not installed. Install
these packages and reinstall Ruby.

        sudo yum install zlib-devel openssl-devel
        rvm list
        rvm uninstall ruby-1.9.3-p362 # using value obtained from 'rvm list'
        rvm install ruby

**Data directory is not empty!**

PostgreSQL has already been initialized. You do not need to run
`sudo postgresql-setup initdb` again.

**PG::Error: ERROR:  permission denied to create database**

The PostgreSQL user does not have permission to create or drop
databases. This error is usually encountered when trying to run Rake
targets (e.g.: db:create, db:drop, db:setup, db:reset or spec) and the
PostgreSQL user does not have the CREATEDB role.

**Nginx is constantly in the starting state**

If running `sudo service thales status` shows that Unicorn is always
"starting", check that the Unicorn PID file directory exists.

If it cannot create the PID file, Unicorn will not start.

**502 Bad Gateway**

The Unicorn HTTP server is not running or nginx has not been correctly
configured.

**403 Forbidden**

When accessing a static file, this could be caused by the reverse
proxy or HTTP server not having sufficient permissions to read the
file. Normally, the worker process is running as a different user
(e.g. nginx) from the owner of the files (e.g. thales).

Check the permissions on the file - and all ancestor directories -
allow the server's user to access it. Typically, the home directory
for a user is only readable by that user.

**HTML page shows, but without any CSS styling**

The precompiled assets are not being served. See **403 Forbidden** above.

Further information
-------------------

For further information on Thales, see the
[Thales project on GitHub](http://github.com/uq-eresearch/thales).
