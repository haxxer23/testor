#!/bin/bash

KVER=`uname -a`
# Variable to know if Homebrew should be installed
MSFPASS=`openssl rand -hex 16`
#Variable with time of launch used for log names
NOW=$(date +"-%b-%d-%y-%H%M%S")
IGCC=1
INSTALL=1
RVM=1

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}
########################################

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}
########################################

function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}
########################################

function check_root
{
    if [ "$(id -u)" != "0" ]; then
        print_error "This step must be ran as root"
        exit 1
    fi
}
########################################

function check_postgresql
{
  if [ -d /usr/local/share/postgresql ]; then
    print_error "A previous version of PostgreSQL was found on the system."
    print_error "remove the prevous version and files and run script again."
    exit 1
  fi
}
########################################

function check_macports
{
    if [ -f /opt/local/bin/port ]; then
        print_error "MacPorts was detected on the system. This script uses Hombrew"
        print_error "and it is incompatible with MacPorts."
        exit 1
    fi
}
########################################

function install_armitage_osx
{
    if [ -e /usr/bin/curl ]; then
        print_status "Downloading latest version of Armitage"
        echo "---- Downloading the latest version of Armitage ---" >> $LOGFILE 2>&1
        curl -# -o /tmp/armitage.tgz http://www.fastandeasyhacking.com/download/armitage-latest.tgz && print_good "Finished"
        if [ $? -eq 1 ] ; then
            echo "---- Failed to download the latest version of armitage ----" >> $LOGFILE 2>&1
            print_error "Failed to download the latest version of Armitage make sure you"
            print_error "are connected to the internert and can reach http://www.fastandeasyhacking.com"
            return 1
        else
            print_status "Decompressing package to /usr/local/share/armitage"
            echo "---- Decompressing the latest version of Armitage ----" >> $LOGFILE 2>&1
            tar -xvzf /tmp/armitage.tgz -C /usr/local/share >> $LOGFILE 2>&1
        if [ $? -eq 1 ] ; then
            print_error "Was unable to decompress the latest version of Armitage"
            echo "---- Decompression of Armitage failed ----" >> $LOGFILE 2>&1
            return 1
        fi
    fi

    # Check if links exists and if they do not create them
    if [ ! -e /usr/local/bin/armitage ]; then
        print_status "Creating link for Armitage in /usr/local/bin/armitage"
        echo "---- Creating launch script for Armitage and linking it ----" >> $LOGFILE 2>&1
        sh -c "echo java -jar /usr/local/share/armitage/armitage.jar \$\* > /usr/local/share/armitage/armitage"
        if [ $? -eq 1 ] ; then
            print_error "Failed to create Armitage launch script"
            return 1
        fi
        ln -s /usr/local/share/armitage/armitage /usr/local/bin/armitage
        if [ $? -eq 1 ] ; then
            print_error "Failed to link Armitage launch script"
            return 1
        fi
    else
    print_good "Armitage is already linked to /usr/local/bin/armitage"
    sh -c "echo java -jar /usr/local/share/armitage/armitage.jar \$\* > /usr/local/share/armitage/armitage"
    fi
        if [ ! -e /usr/local/bin/teamserver ]; then
            print_status "Creating link for Teamserver in /usr/local/bin/teamserver"
            ln -s /usr/local/share/armitage/teamserver /usr/local/bin/teamserver
            perl -pi -e 's/armitage.jar/\/usr\/local\/share\/armitage\/armitage.jar/g' /usr/local/share/armitage/teamserver
        else
            print_good "Teamserver is already linked to /usr/local/bin/teamserver"
            perl -pi -e 's/armitage.jar/\/usr\/local\/share\/armitage\/armitage.jar/g' /usr/local/share/armitage/teamserver
        fi
        print_good "Finished"
    fi
}
########################################

function check_for_brew_osx
{
    print_status "Verifying that Homebrew is installed:"
    if [ -e /usr/local/bin/brew ]; then
        print_good "Homebrew is installed on the system, updating formulas."
        /usr/local/bin/brew update >> $LOGFILE 2>&1
        print_good "Finished updating formulas"
        brew tap homebrew/versions >> $LOGFILE 2>&1
        print_status "Verifying that the proper paths are set"

        if [ -d ~/.bash_profile ]; then
            if [ "$(grep ":/usr/local/sbin" ~/.bash_profile -q)" ]; then
                print_good "Paths are properly set"
            else
                print_status "Setting the path for homebrew"
                echo PATH=/usr/local/bin:/usr/local/sbin:$PATH >> ~/.bash_profile
                source  ~/.bash_profile
            fi
        else
            echo PATH=/usr/local/bin:/usr/local/sbin:$PATH >> ~/.bash_profile
            source  ~/.bash_profile
        fi
    else

        print_status "Installing Homebrew"
         /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        if [ "$(grep ":/usr/local/sbin" ~/.bash_profile -q)" ]; then
            print_good "Paths are properly set"
        else
            print_status "Setting the path for homebrew"
            echo PATH=/usr/local/bin:/usr/local/sbin:$PATH >> ~/.bash_profile
            source  ~/.bash_profile
        fi
    fi
}
########################################

function check_dependencies_osx
{
    # Get a list of all the packages installed on the system
    PKGS=`pkgutil --pkgs`
    print_status "Verifying that Development Tools and Java are installed:"
    if [[ $PKGS =~ 'com.apple.pkg.JavaForMacOSX' || $PKGS =~ com.oracle.jdk* ]] ; then
        print_good "Java is installed."
    else
        print_error "Java is not installed on this system."
        print_error "Run the command java in Terminal and install Java"
        exit 1
    fi

    if [[ $PKGS =~ com.apple.pkg.XcodeMAS ]] ; then
        print_good "Xcode is installed."
    else
        print_error "Xcode is not installed on this system. Install from the Apple AppStore."
        exit 1
    fi

    if [[ $PKGS =~ com.apple.pkg.DeveloperToolsCLI || $PKGS =~ com.apple.pkg.CLTools_Executables ]] ; then
        print_good "Command Line Development Tools is intalled."
    else
        print_error "Command Line Development Tools is not installed on this system."
        exit 1
    fi
}
########################################

function install_ruby_osx
{
    print_status "Checking if Ruby 1.9.3 is installed, if not installing it."
    if [ -d /usr/local/Cellar/ruby193 ] && [ -L /usr/local/bin/ruby ] || [ -a ~/.rvm/rubies/*1.9.3* ]; then
        print_good "Correct version of Ruby is installed."
    else
        print_status "Installing Ruby 1.9.3"
        brew tap homebrew/versions >> $LOGFILE 2>&1
        brew install homebrew/versions/ruby193 >> $LOGFILE 2>&1
        echo PATH=/usr/local/opt/ruby193/bin:$PATH >> ~/.bash_profile
        source  ~/.bash_profile
    fi
    print_status "Installing the bundler and SQLite3 Gems"
    gem install bundler sqlite3 >> $LOGFILE 2>&1
}
########################################

function install_nmap_osx
{
    print_status "Checking if Nmap is installed, using Homebrew to install it if not."
    if [ -d /usr/local/Cellar/nmap ] && [ -L /usr/local/bin/nmap ]; then
        print_good "Nmap is installed."
    else
        print_status "Installing Nmap"
        brew install nmap >> $LOGFILE 2>&1
    fi
}
########################################

function install_postgresql_osx
{
    print_status "Checking if PostgreSQL is installed, using Homebrew to install it if not."
    echo "#### POSTGRESQL INSTALLATION ####" >> $LOGFILE 2>&1
    if [ -d /usr/local/Cellar/postgresql ] && [ -L /usr/local/bin/postgres ]; then
        print_good "PostgreSQL is installed."
    else
        print_status "Installing PostgreSQL"
        echo "---- Installing PostgreSQL ----" >> $LOGFILE 2>&1
        brew install postgresql --without-osso-uuid >> $LOGFILE 2>&1
        if [ $? -eq 0 ]; then
            echo "---- Installation of PostgreSQL successful----" >> $LOGFILE 2>&1
            print_good "Installation of PostgreSQL was successful"
            echo "---- Initiating the PostgreSQL Database ----" >> $LOGFILE 2>&1
            print_status "Initiating postgres"
            initdb /usr/local/var/postgres >> $LOGFILE 2>&1
            if [ $? -eq 0 ]; then
                print_good "Database initiation was successful"
                echo "---- Initiation of PostgreSQL successful----" >> $LOGFILE 2>&1
            fi

            # Getting the Postgres version so as to configure startup of the databse
            PSQLVER=`psql --version | cut -d " " -f3`
            echo "---- Postgres Version $PSQLVER ----" >> $LOGFILE 2>&1
            print_status "Configuring the database engine to start at logon"
            echo "---- Starting PostgreSQL Server ----" >> $LOGFILE 2>&1
            pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start >> $LOGFILE 2>&1
            mkdir -p ~/Library/LaunchAgents
            ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
            # Give enough time for the database to start for the first time
            sleep 5
            #launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
            print_status "Creating the MSF Database user msf with the password provided"
            echo "---- Postgres Version $PSQLVER ----" >> $LOGFILE 2>&1
            echo "---- Creating Metasploit DB user ----" >> $LOGFILE 2>&1
            psql postgres -c "create role msf login password '$MSFPASS'" >> $LOGFILE 2>&1
            if [ $? -eq 0 ]; then
                print_good "Metasploit Role named msf has been created."
                echo "---- Creation of Metasploit user was successful ----" >> $LOGFILE 2>&1
            else
                print_error "Failed to create the msf role"
                echo "---- Creation of Metasploit user failed ----" >> $LOGFILE 2>&1
            fi
            print_status "Creating msf database and setting the owner to msf user"
            echo "---- Creating Metasploit Database and assigning the role ----" >> $LOGFILE 2>&1
             createdb -O msf msf -h localhost >> $LOGFILE 2>&1
            if [ $? -eq 0 ]; then
                print_good "Metasploit Databse named msf has been created."
                echo "---- Database creation was successful ----" >> $LOGFILE 2>&1
            else
                print_error "Failed to create the msf database."
                echo "---- Database creation failed ----" >> $LOGFILE 2>&1
            fi
        fi
    fi
}
########################################

function install_msf_osx
{
    print_status "Installing Metasploit Framework from the GitHub Repository"
    if [[ ! -d /usr/local/share/metasploit-framework ]]; then
        print_status "Cloning latest version of Metasploit Framework"
        git clone https://github.com/rapid7/metasploit-framework.git /usr/local/share/metasploit-framework >> $LOGFILE 2>&1
        print_status "Linking Metasploit commands."
        cd /usr/local/share/metasploit-framework
        for MSF in $(ls msf*); do
            print_status "linking $MSF command"
        ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF
        done
        print_status "Creating Database configuration YAML file."
        echo 'production:
 adapter: postgresql
 database: msf
 username: msf
 password: $MSFPASS
 host: 127.0.0.1
 port: 5432
 pool: 75
 timeout: 5' > /usr/local/share/metasploit-framework/config/database.yml
        print_status "setting environment variable in system profile. Password will be requiered"
        sudo sh -c "echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml >> /etc/profile"
        echo "export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml" >> ~/.bash_profile
        source /etc/profile
        source ~/.bash_profile
        cd /usr/local/share/metasploit-framework
        if [[ $RVM -eq 0 ]]; then
            print_status "Installing required ruby gems by Framework using bundler on RVM Ruby"
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do bundle config build.nokogiri --use-system-libraries >> $LOGFILE 2>&1
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do bundle install >> $LOGFILE 2>&1
        else
            print_status "Installing required ruby gems by Framework using bundler on System Ruby"
            bundle config build.nokogiri --use-system-libraries >> $LOGFILE 2>&1
            bundle install  >> $LOGFILE 2>&1
        fi
        print_status "Starting Metasploit so as to populate the database."
        if [[ $RVM -eq 0 ]]; then
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do ruby /usr/local/share/metasploit-framework/msfconsole -q -x "exit" >> $LOGFILE 2>&1
        else
            /usr/local/share/metasploit-framework/msfconsole -q -x "exit" >> $LOGFILE 2>&1
            print_status "Finished Metasploit installation"
        fi
    else
        print_status "Metasploit already present."
    fi
}
########################################

function install_plugins_osx
{
    print_status "Installing additional Metasploit plugins"
    print_status "Installing Pentest plugin"
    curl -L -# -o /usr/local/share/metasploit-framework/plugins/pentest.rb https://raw.github.com/darkoperator/Metasploit-Plugins/master/pentest.rb
    if [ $? -eq 0 ]; then
        print_good "The pentest plugin has been installed."
    else
        print_error "Failed to install the pentest plugin."
    fi
    print_status "Installing DNSRecon Import plugin"
    curl -L -# -o /usr/local/share/metasploit-framework/plugins/dnsr_import.rb https://raw.github.com/darkoperator/dnsrecon/master/msf_plugin/dnsr_import.rb
    if [ $? -eq 0 ]; then
        print_good "The dnsr_import plugin has been installed."
    else
        print_error "Failed to install the dnsr_import plugin."
    fi
}
#######################################

function install_deps_deb
{
    print_status "Installing dependencies for Metasploit Framework"
    sudo apt-get -y update  >> $LOGFILE 2>&1
    sudo apt-get -y install build-essential libreadline-dev  libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev subversion git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev ruby sqlite3 ruby-dev libgdbm-dev libncurses5-dev libtool bison libffi-dev>> $LOGFILE 2>&1
    if [ $? -eq 1 ] ; then
        echo "---- Failed to download and install dependencies ----" >> $LOGFILE 2>&1
        print_error "Failed to download and install the dependencies for running Metasploit Framework"
        print_error "Make sure you have the proper permissions and able to download and install packages"
        print_error "for the distribution you are using."
        exit 1
    fi
    print_status "Finished installing the dependencies."
    print_status "Installing base Ruby Gems"
    sudo gem install wirble sqlite3 bundler >> $LOGFILE 2>&1
    if [ $? -eq 1 ] ; then
        echo "---- Failed to download and install base Ruby Gems ----" >> $LOGFILE 2>&1
        print_error "Failed to download and install Ruby Gems for running Metasploit Framework"
        exit 1
    fi
    print_status "Finished installing the base gems."
}
#######################################

function install_nmap_linux
{
    if [[ ! -e /usr/local/bin/nmap ]]; then
        print_status "Downloading and Compiling the latest version of Nmap"
        print_status "Downloading from SVN the latest version of Nmap"
        cd /usr/src
        echo "---- Downloading the latest version of NMap via SVN ----" >> $LOGFILE 2>&1
        sudo svn co https://svn.nmap.org/nmap >> $LOGFILE 2>&1
    if [ $? -eq 1 ] ; then
        print_error "Failed to download the latest version of Nmap"
        return 1
    fi
    cd nmap
    print_status "Configuring Nmap"
    echo "---- Configuring Nmap settings ----" >> $LOGFILE 2>&1
    sudo ./configure >> $LOGFILE 2>&1
    print_status "Compiling the latest version of Nmap"
    echo "---- Compiling NMap from source ----" >> $LOGFILE 2>&1
    sudo make >> $LOGFILE 2>&1
    if [ $? -eq 1 ] ; then
        print_error "Failed to compile Nmap"
        return 1
    fi
    print_status "Installing the latest version of Nmap"
    echo "---- Installing Nmap ----" >> $LOGFILE 2>&1
    sudo make install >> $LOGFILE 2>&1
    if [ $? -eq 1 ] ; then
        print_error "Failed to install Nmap"
        return 1
    fi
        sudo make clean  >> $LOGFILE 2>&1
    else
        print_status "Nmap is already installed on the system"
    fi
}
#######################################

function configure_psql_deb
{
    print_status "Creating the MSF Database user msf with the password provided"
    if [ "$(id -u)" != "0" ]; then
        MSFEXIST="$(sudo su - postgres -c "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='msf'\"")"
    else
        MSFEXIST="$(su - postgres -c "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='msf'\"")"
    fi
    if [[ ! $MSFEXIST -eq 1 ]]; then
        if [ "$(id -u)" != "0" ]; then
            sudo -u postgres psql postgres -c "create role msf login password '$MSFPASS'"  >> $LOGFILE 2>&1
        else
            su - postgres -c "psql postgres -c \"create role msf login password '$MSFPASS'\""  >> $LOGFILE 2>&1
        fi

        if [ $? -eq 0 ]; then
            print_good "Metasploit Role named msf has been created."
        else
        print_error "Failed to create the msf role"
        fi
    else
        print_status "The msf role already exists."
    fi

    if [ "$(id -u)" != "0" ]; then
        DBEXIST="$(sudo su postgres -c "psql postgres -l | grep msf")"
    else
        DBEXIST="$(su - postgres -c "psql postgres -l | grep msf")"
    fi

    if [[ ! $DBEXIST ]]; then
        print_status "Creating msf database and setting the owner to msf user"
        if [ "$(id -u)" != "0" ]; then
            sudo -u postgres psql postgres -c "CREATE DATABASE msf OWNER msf;" >> $LOGFILE 2>&1
        else
            su - postgres -c "psql postgres -c \"CREATE DATABASE msf OWNER msf;\"" >> $LOGFILE 2>&1
        fi

        if [ $? -eq 0 ]; then
            print_good "Metasploit database named msf has been created."
        else
            print_error "Failed to create the msf database."
        fi
    else
        print_status "The msf database already exists."
    fi
}
#######################################

function install_msf_linux
{
    print_status "Installing Metasploit Framework from the GitHub Repository"

    if [[ ! -d /usr/local/share/metasploit-framework ]]; then
        print_status "Cloning latest version of Metasploit Framework"
        if [ "$(id -u)" != "0" ]; then
            sudo git clone https://github.com/rapid7/metasploit-framework.git /usr/local/share/metasploit-framework >> $LOGFILE 2>&1
            sudo chown -R `whoami` /usr/local/share/metasploit-framework >> $LOGFILE 2>&1
        else
            git clone https://github.com/rapid7/metasploit-framework.git /usr/local/share/metasploit-framework >> $LOGFILE 2>&1
        fi

        print_status "Linking metasploit commands."
        cd /usr/local/share/metasploit-framework
        for MSF in $(ls msf*); do
            print_status "linking $MSF command"
            if [ "$(id -u)" != "0" ]; then
                sudo ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF
            else
                ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF
            fi
        done
        print_status "Creating Database configuration YAML file."
        if [ "$(id -u)" != "0" ]; then
            sudo sh -c "echo 'production:
  adapter: postgresql
  database: msf
  username: msf
  password: $MSFPASS
  host: 127.0.0.1
  port: 5432
  pool: 75
  timeout: 5' > /usr/local/share/metasploit-framework/config/database.yml"
        else
            sh -c "echo 'production:
  adapter: postgresql
  database: msf
  username: msf
  password: $MSFPASS
  host: 127.0.0.1
  port: 5432
  pool: 75
  timeout: 5' > /usr/local/share/metasploit-framework/config/database.yml"
        fi
        print_status "setting environment variable in system profile. Password will be requiered"
        sudo sh -c "echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml >> /etc/environment"
        echo "export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/config/database.yml" >> ~/.bashrc
        PS1='$ '
        source ~/.bashrc

        cd /usr/local/share/metasploit-framework
        if [[ $RVM -eq 0 ]]; then
            print_status "Installing required ruby gems by Framework using bundler on RVM Ruby"
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do bundle config build.nokogiri --use-system-libraries >> $LOGFILE 2>&1
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do bundle install  >> $LOGFILE 2>&1
        else
            print_status "Installing required ruby gems by Framework using bundler on System Ruby"
            sudo bundle config build.nokogiri --use-system-libraries >> $LOGFILE 2>&1
            sudo bundle install  >> $LOGFILE 2>&1
        fi
        print_status "Starting Metasploit so as to populate the database."
        if [[ $RVM -eq 0 ]]; then
            ~/.rvm/bin/rvm ruby-1.9.3-p550 do ruby /usr/local/share/metasploit-framework/msfconsole -q -x "exit" >> $LOGFILE 2>&1
        else
            /usr/local/share/metasploit-framework/msfconsole -q -x "exit" >> $LOGFILE 2>&1
            print_status "Finished Metasploit installation"
        fi
    else
        print_status "Metasploit already present."
    fi
}
#######################################

function install_plugins_linux
{
    print_status "Installing additional Metasploit plugins"
    print_status "Installing pentest plugin"
    sudo curl -L -# -o /usr/local/share/metasploit-framework/plugins/pentest.rb https://raw.github.com/darkoperator/Metasploit-Plugins/master/pentest.rb
    if [ $? -eq 0 ]; then
        print_good "The pentest plugin has been installed."
    else
        print_error "Failed to install the pentest plugin."
    fi
    print_status "Installing DNSRecon Import plugin"
    sudo curl -L -# -o /usr/local/share/metasploit-framework/plugins/dnsr_import.rb https://raw.github.com/darkoperator/dnsrecon/master/msf_plugin/dnsr_import.rb
    if [ $? -eq 0 ]; then
        print_good "The dnsr_import plugin has been installed."
    else
        print_error "Failed to install the dnsr_import plugin."
    fi
}
#######################################

function install_armitage_linux
{
    if [ -e /usr/bin/curl ]; then
        print_status "Downloading latest version of Armitage"
        curl -# -o /tmp/armitage.tgz http://www.fastandeasyhacking.com/download/armitage-latest.tgz && print_good "Finished"
        if [ $? -eq 1 ] ; then
            print_error "Failed to download the latest version of Armitage make sure you"
            print_error "are connected to the internet and can reach http://www.fastandeasyhacking.com"
        else
            print_status "Decompressing package to /usr/local/share/armitage"
            sudo tar -xvzf /tmp/armitage.tgz -C /usr/local/share >> $LOGFILE 2>&1
        fi

        # Check if links exists and if they do not create them
        if [ ! -e /usr/local/bin/armitage ]; then
            print_status "Creating link for Armitage in /usr/local/bin/armitage"
            sudo sh -c "echo java -jar /usr/local/share/armitage/armitage.jar \$\* > /usr/local/share/armitage/armitage"
            sudo ln -s /usr/local/share/armitage/armitage /usr/local/bin/armitage
        else
            print_good "Armitage is already linked to /usr/local/bin/armitage"
            sudo sh -c "echo java -jar /usr/local/share/armitage/armitage.jar \$\* > /usr/local/share/armitage/armitage"
        fi

        if [ ! -e /usr/local/bin/teamserver ]; then
            print_status "Creating link for Teamserver in /usr/local/bin/teamserver"
            sudo ln -s /usr/local/share/armitage/teamserver /usr/local/bin/teamserver
            sudo perl -pi -e 's/armitage.jar/\/usr\/local\/share\/armitage\/armitage.jar/g' /usr/local/share/armitage/teamserver
        else
            print_good "Teamserver is already linked to /usr/local/bin/teamserver"
            sudo perl -pi -e 's/armitage.jar/\/usr\/local\/share\/armitage\/armitage.jar/g' /usr/local/share/armitage/teamserver
        fi
        print_good "Finished"
    fi
}
#######################################

function usage ()
{
    echo "Script for Installing Metasploit Framework"
    echo "By Carlos_Perez[at]darkoperator.com"
    echo "Ver 0.1.7"
    echo ""
    echo "-i                :Install Metasploit Framework."
    echo "-p <password>     :password for Metasploit databse msf user. If not provided a random one is generated for you."
    echo "-r                :Installs Ruby using Ruby Version Manager."
    echo "-h                :This help message"
}

function install_ruby_rvm
{

    if [[ ! -e ~/.rvm/scripts/rvm ]]; then
        print_status "Installing RVM"

        bash < <(curl -sSL https://get.rvm.io) >> $LOGFILE 2>&1
        PS1='$ '
        if [[ $OSTYPE =~ darwin ]]; then
            source ~/.bash_profile
        else
            source ~/.bashrc
        fi

        if [[ $OSTYPE =~ darwin ]]; then
            print_status "Installing Ruby"
            ~/.rvm/bin/rvm install ruby-1.9.3-p550 --with-gcc=clang --autolibs=4 --verify-downloads 1 >> $LOGFILE 2>&1
        else
            ~/.rvm/bin/rvm install ruby-1.9.3-p550 --autolibs=4 --verify-downloads 1 >> $LOGFILE 2>&1
        fi

        if [[ $? -eq 0 ]]; then
            print_good "Installation of Ruby 1.9.3 was successful"

            ~/.rvm/bin/rvm use 1.9.3 --default >> $LOGFILE 2>&1
            print_status "Installing base gems"
            ~/.rvm/bin/rvm 1.9.3 do gem install sqlite3 bundler >> $LOGFILE 2>&1
            if [[ $? -eq 0 ]]; then
                print_good "Base gems in the RVM Ruby have been installed."
            else
                print_error "Base Gems for the RVM Ruby have failed!"
                exit 1
            fi
        else
            print_error "Was not able to install Ruby 1.9.3!"
            exit 1
        fi
    else
        print_status "RVM is already installed"
        if [[ "$( ls -1 ~/.rvm/rubies/)" =~ ruby-1.9.3-p... ]]; then
            print_status "Ruby for Metasploit is already installed"
        else
            PS1='$ '
            if [[ $OSTYPE =~ darwin ]]; then
                source ~/.bash_profile
            else
                source ~/.bashrc
            fi

            print_status "Installing Ruby 1.9.3 "
            ~/.rvm/bin/rvm install ruby-1.9.3-p550  --autolibs=4 --verify-downloads 1  >> $LOGFILE 2>&1
            if [[ $? -eq 0 ]]; then
                print_good "Installation of Ruby 1.9.3 was successful"

                ~/.rvm/bin/rvm use ruby-1.9.3-p550 --default >> $LOGFILE 2>&1
                print_status "Installing base gems"
                ~/.rvm/bin/rvm ruby-1.9.3-p550 do gem install sqlite3 bundler >> $LOGFILE 2>&1
                if [[ $? -eq 0 ]]; then
                    print_good "Base gems in the RVM Ruby have been installed."
                else
                    print_error "Base Gems for the RVM Ruby have failed!"
                    exit 1
                fi
            else
                print_error "Was not able to install Ruby 1.9.3!"
                exit 1
            fi
        fi
    fi
}
#### MAIN ###
[[ ! $1 ]] && { usage; exit 0; }
#Variable with log file location for trobleshooting
LOGFILE="/tmp/msfinstall$NOW.log"
while getopts "irp:h" options; do
    case $options in
        p ) MSFPASS=$OPTARG;;
        i ) INSTALL=0;;
        h ) usage;;
        r ) RVM=0;;
        \? ) usage
        exit 1;;
        * ) usage
        exit 1;;

    esac
done

if [ $INSTALL -eq 0 ]; then
    print_status "Log file with command output and errors $LOGFILE"
    if [[ "$KVER" =~ Darwin ]]; then
        check_macports
        check_postgresql
        check_dependencies_osx
        check_for_brew_osx
        install_ruby_osx
        if [[ $RVM -eq 0 ]]; then
            install_ruby_rvm
        fi
        install_nmap_osx
        install_postgresql_osx
        install_msf_osx
        install_armitage_osx
        install_plugins_osx

        print_status "#################################################################"
        print_status "### YOU NEED TO RELOAD YOUR PROFILE BEFORE USE OF METASPLOIT!   ###"
        print_status "### RUN source ~/.bash_profile                                  ###"
        if [[ $RVM -eq 0 ]]; then
            print_status "###                                                             ###"
            print_status "### INSTALLATION WAS USING RVM, SET 1.9.3 AS DEFAULT            ###"
            print_status "### RUN rvm use ruby-1.9.3-p550 --default                       ###"
            print_status "###                                                             ###"
        fi
        print_status "###################################################################"

    elif [[ "$KVER" =~ buntu ]] || [ -f /etc/dpkg/origins/ubuntu ]; then
        install_deps_deb

        if [[ $RVM -eq 0 ]]; then
            install_ruby_rvm
        fi

        install_nmap_linux
        configure_psql_deb
        install_msf_linux
        install_plugins_linux
        install_armitage_linux
        print_status "##################################################################"
        print_status "### YOU NEED TO RELOAD YOUR PROFILE BEFORE USE OF METASPLOIT!  ###"
        print_status "### RUN source ~/.bashrc                                       ###"
        if [[ $RVM -eq 0 ]]; then
            print_status "###                                                            ###"
            print_status "### INSTALLATION WAS USING RVM SET 1.9.3 AS DEFAULT            ###"
            print_status "### RUN rvm use ruby-1.9.3-p550 --default                      ###"
        fi
        print_status "### When launching teamserver and armitage with sudo use the   ###"
        print_status "### use the -E option to make sure the MSF Database variable   ###"
        print_status "### is properly set.                                           ###"
        print_status "###                                                            ###"
        print_status "##################################################################"

    elif [[ "$KVER" =~ Debian ]] || [ -f /etc/debian_version ]; then
        if [[ "$(cat /etc/debian_version )" =~ 7.*  ]]; then
            if [[ $( cat /etc/apt/sources.list | grep -E '^deb cdrom' ) ]]; then
                print_error "Source in /etc/apt/sources.list is set to CD or DVD"
                print_error "Comment out the line and only use network sources."
                exit 1
            fi
            install_deps_deb

            if [[ $RVM -eq 0 ]]; then
                install_ruby_rvm
            fi

            install_nmap_linux
            configure_psql_deb
            install_msf_linux
            install_plugins_linux
            install_armitage_linux
            print_status "##################################################################"
            print_status "### YOU NEED TO RELOAD YOUR PROFILE BEFORE USE OF METASPLOIT!  ###"
            print_status "### RUN source ~/.bashrc                                       ###"
            if [[ $RVM -eq 0 ]]; then
                print_status "###                                                            ###"
                print_status "### INSTALLATION WAS USING RVM SET 1.9.3-metasploit AS DEFAULT ###"
                print_status "### RUN rvm use ruby-1.9.3-p550 default                        ###"
            fi
            print_status "### When launching teamserver and armitage with sudo use the   ###"
            print_status "### use the -E option to make sure the MSF Database variable   ###"
            print_status "### is properly set.                                           ###"
            print_status "###                                                            ###"
            print_status "##################################################################"
        else
            print_error "This version of Debian is not supported. Only Debian 7.0 is supported"
        fi
    else
        print_error "The script does not support this platform at this moment."
        exit 1
    fi
fi
