#!/bin/bash
##############################################################################
#    Open LiteSpeed is an open source HTTP server.                           #
#    Copyright (C) 2013 - 2016 LiteSpeed Technologies, Inc.                  #
#                                                                            #
#    This program is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by    #
#    the Free Software Foundation, either version 3 of the License, or       #
#    (at your option) any later version.                                     #
#                                                                            #
#    This program is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            #
#    GNU General Public License for more details.                            #
#                                                                            #
#    You should have received a copy of the GNU General Public License       #
#    along with this program. If not, see http://www.gnu.org/licenses/.      #
##############################################################################

###    Author: dxu@litespeedtech.com (David Shue)

OSVER=UNKNOWN
OSTYPE=`uname -m`
SERVER_ROOT=/usr/local/lsws
ISCENTOS=

#Current status
OLSINSTALLED=
MYSQLINSTALLED=

#Generate webAdmin and mysql root password randomly
RAND1=$RANDOM
RAND2=$RANDOM
RAND3=$RANDOM
RAND4=$RANDOM
DATE=`date`
ADMINPASSWORD=`echo "$RAND1$DATE" |  md5sum | base64 | head -c 8`
ROOTPASSWORD=`echo "$RAND2$DATE" |  md5sum | base64 | head -c 8`
DATABASENAME=olsdbname
USERNAME=olsdbuser
USERPASSWORD=`echo "$RAND3$DATE" |  md5sum | base64 | head -c 8`
WORDPRESSPATH=$SERVER_ROOT

WPPORT=80

INSTALLWORDPRESS=0
INSTALLWORDPRESSPLUS=0

WPLANGUAGE=en
WPPASSWORD=`echo "$RAND3$DATE" |  md5sum | base64 | head -c 8`
WPUSER=wpuser
WPTITLE=MySite

SITEDOMAIN=*
EMAIL=

#All lsphp versions, keep using two digits to identify a version!!!
#otherwise, need to update the uninstall function which will check the version
LSPHPVERLIST=(54 55 56 70)

#default version
LSPHPVER=56

ALLERRORS=0
TEMPPASSWORD=
PASSWORDPROVIDE=

echoY()
{
    FLAG=$1
    shift
    echo -e "\033[38;5;148m$FLAG\033[39m$@"
}

echoG()
{
    FLAG=$1
    shift
    echo -e "\033[38;5;71m$FLAG\033[39m$@"
}

echoR()
{
    FLAG=$1
    shift
    echo -e "\033[38;5;203m$FLAG\033[39m$@"
}

function check_root
{
    local INST_USER=`id -u`
    if [ $INST_USER != 0 ] ; then
        echoR "Sorry, only the root user can install."
        echo 
        exit 1
    fi
}

function check_wget
{
    which wget  > /dev/null 2>&1
    if [ $? != 0 ] ; then
        if [ "x$ISCENTOS" = "x1" ] ; then
            yum -y install wget
        else
            apt-get -y install wget
        fi
    
        which wget  > /dev/null 2>&1
        if [ $? != 0 ] ; then
            echoR "An error occured during wget installation."
            ALLERRORS=1
        fi
    fi
}

function display_license
{
    echoY '**********************************************************************************************'
    echoY '*                    Open LiteSpeed One click installation, Version 1.4                      *'
    echoY '*                    Copyright (C) 2016 LiteSpeed Technologies, Inc.                         *'
    echoY '**********************************************************************************************'
}

function check_os
{
    OSVER=
    ISCENTOS=0
    
    if [ -f /etc/redhat-release ] ; then
        cat /etc/redhat-release | grep " 5." > /dev/null
        if [ $? = 0 ] ; then
            OSVER=CENTOS5
            ISCENTOS=1
        else
            cat /etc/redhat-release | grep " 6." > /dev/null
            if [ $? = 0 ] ; then
                OSVER=CENTOS6
                ISCENTOS=1
            else
                cat /etc/redhat-release | grep " 7." > /dev/null
                if [ $? = 0 ] ; then
                    OSVER=CENTOS7
                    ISCENTOS=1
                fi
            fi
        fi
    elif [ -f /etc/lsb-release ] ; then
        cat /etc/lsb-release | grep "DISTRIB_RELEASE=12." > /dev/null
        if [ $? = 0 ] ; then
            OSVER=UBUNTU12
        else
            cat /etc/lsb-release | grep "DISTRIB_RELEASE=14." > /dev/null
            if [ $? = 0 ] ; then
                OSVER=UBUNTU14
            else
                cat /etc/lsb-release | grep "DISTRIB_RELEASE=16." > /dev/null
                if [ $? = 0 ] ; then
                    OSVER=UBUNTU16
                fi
            fi
        fi    
    elif [ -f /etc/debian_version ] ; then
        cat /etc/debian_version | grep "^7." > /dev/null
        if [ $? = 0 ] ; then
            OSVER=DEBIAN7
        else
            cat /etc/debian_version | grep "^8." > /dev/null
            if [ $? = 0 ] ; then
                OSVER=DEBIAN8
            else
                cat /etc/debian_version | grep "^9." > /dev/null
                if [ $? = 0 ] ; then
                    OSVER=DEBIAN9
                fi
            fi
        fi
    fi

    if [ "x$OSVER" = "x" ] ; then
        echoR "Sorry, currently one click installation only supports Centos(5-7), Debian(7-9) and Ubuntu(12,14,16)."
        echoR "You can download the source code and build from it."
        echoR "The url of the source code is https://github.com/litespeedtech/openlitespeed/releases."
        echo 
        exit 1
    else
        echoG "Current platform is  "  $OSVER.
        export OSVER=$OSVER
        export ISCENTOS=$ISCENTOS
    fi
}


function update_centos_hashlib
{
    if [ "x$ISCENTOS" = "x1" ] ; then
        yum -y install python-hashlib
    fi
}

function install_ols_centos
{
    local VERSION=
    local ND=
    if [ "x$OSVER" = "xCENTOS5" ] ; then
        VERSION=5
    elif [ "x$OSVER" = "xCENTOS6" ] ; then
        VERSION=6
    else #if [ "x$OSVER" = "xCENTOS7" ] ; then
        VERSION=7
    fi

    if [ "x$LSPHPVER" = "x70" ] ; then
        ND=nd
        if [ "x$OSVER" = "xCENTOS5" ] ; then
            rpm -ivh http://repo.mysql.com/mysql-community-release-el5.rpm
        fi
    fi
    
    rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el$VERSION.noarch.rpm
    yum -y install openlitespeed
    yum -y install lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring lsphp$LSPHPVER-mysql$ND lsphp$LSPHPVER-xml lsphp$LSPHPVER-mcrypt lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap
    if [ $? != 0 ] ; then
        echoR "An error occured during openlitespeed installation."
        ALLERRORS=1
    else
        ln -sf $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp $SERVER_ROOT/fcgi-bin/lsphp5
    fi
}

function uninstall_ols_centos
{
    yum -y remove openlitespeed
    
    if [ "x$LSPHPVER" = "x56" ] ; then
        yum list installed | grep lsphp | grep process >  /dev/null 2>&1
        if [ $? = 0 ] ; then
            local LSPHPSTR=`yum list installed | grep lsphp | grep process`
            LSPHPVER=`echo $LSPHPSTR | awk '{print substr($0,6,2)}'`
            echoY "Current install lsphp version is $LSPHPVER"
        else
            echoR "Uninstallation can not get the version infomation of the current installed lsphp."
            echoR "Can not uninstall lsphp correctly."
            LSPHPVER=
        fi

    fi

    local ND=nd
    if [ "x$LSPHPVER" = "x70" ] ; then
        ND=nd
    fi
    
    if [ "x$LSPHPVER" != "x" ] ; then
        yum -y remove lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring lsphp$LSPHPVER-mysql$ND lsphp$LSPHPVER-xml lsphp$LSPHPVER-mcrypt lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap
        if [ $? != 0 ] ; then
            echoR "An error occured while uninstalling openlitespeed."
            ALLERRORS=1
        fi
    fi
    
    rm -rf $SERVER_ROOT/
}

function install_ols_debian
{
    local NAME=
    if [ "x$OSVER" = "xDEBIAN7" ] ; then
        NAME=wheezy
    elif [ "x$OSVER" = "xDEBIAN8" ] ; then
        NAME=jessie
    elif [ "x$OSVER" = "xDEBIAN9" ] ; then
        NAME=stretch
        
    elif [ "x$OSVER" = "xUBUNTU12" ] ; then
        NAME=precise
    elif [ "x$OSVER" = "xUBUNTU14" ] ; then
        NAME=trusty
    elif [ "x$OSVER" = "xUBUNTU16" ] ; then
        NAME=xenial
    fi

    echo "deb http://rpms.litespeedtech.com/debian/ $NAME main"  > /etc/apt/sources.list.d/lst_debian_repo.list
    wget -O /etc/apt/trusted.gpg.d/lst_debian_repo.gpg http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg
    apt-get -y update
    apt-get -y install openlitespeed
    apt-get -y install lsphp$LSPHPVER lsphp$LSPHPVER-mysql lsphp$LSPHPVER-imap  

    if [ "x$LSPHPVER" != "x70" ] ; then
        apt-get -y install lsphp$LSPHPVER-gd lsphp$LSPHPVER-mcrypt 
    else
       apt-get -y install lsphp$LSPHPVER-common
    fi
    
    if [ $? != 0 ] ; then
        echoR "An error occured during openlitespeed installation."
        ALLERRORS=1
    else
        ln -sf $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp $SERVER_ROOT/fcgi-bin/lsphp5
    fi
}


function uninstall_ols_debian
{
    apt-get -y --purge remove openlitespeed
    
    if [ "x$LSPHPVER" = "x56" ] ; then
        dpkg -l | grep lsphp | grep mysql >  /dev/null 2>&1
        if [ $? = 0 ] ; then
            local LSPHPSTR=`dpkg -l | grep lsphp | grep mysql`
            LSPHPVER=`echo $LSPHPSTR | awk '{print substr($2,6,2)}'`
            echoY "Current install lsphp version is $LSPHPVER"
        else
            echoR "Uninstallation can not get the version infomation of the current installed lsphp."
            echoR "Can not uninstall lsphp correctly."
            LSPHPVER=
        fi
    fi

    if [ "x$LSPHPVER" != "x" ] ; then
        apt-get -y --purge remove lsphp$LSPHPVER lsphp$LSPHPVER-mysql lsphp$LSPHPVER-imap
        
        if [ "x$LSPHPVER" != "x70" ] ; then
            apt-get -y --purge remove lsphp$LSPHPVER-gd lsphp$LSPHPVER-mcrypt
        else
            apt-get -y --purge remove lsphp$LSPHPVER-common
        fi
        
        if [ $? != 0 ] ; then
            echoR "An error occured while uninstalling openlitespeed."
            ALLERRORS=1
        fi
    fi

    rm -rf $SERVER_ROOT/
}

function install_wordpress
{
    if [ ! -e "$WORDPRESSPATH" ] ; then 
        mkdir -p "$WORDPRESSPATH"
    fi

    cd "$WORDPRESSPATH"
    wget --no-check-certificate http://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz  >  /dev/null 2>&1
    rm latest.tar.gz
    
    wget -q -r -nH --cut-dirs=2 --no-parent https://plugins.svn.wordpress.org/litespeed-cache/trunk/ --reject html -P $WORDPRESSPATH/wordpress/wp-content/plugins/litespeed-cache/
    chown -R --reference=autoupdate  $WORDPRESSPATH/wordpress
    
    cd -
}



function setup_wordpress
{
    if [ -e "$WORDPRESSPATH/wordpress/wp-config-sample.php" ] ; then
        sed -e "s/database_name_here/$DATABASENAME/" -e "s/username_here/$USERNAME/" -e "s/password_here/$USERPASSWORD/" "$WORDPRESSPATH/wordpress/wp-config-sample.php" > "$WORDPRESSPATH/wordpress/wp-config.php"
        if [ -e "$WORDPRESSPATH/wordpress/wp-config.php" ] ; then
            chown  -R --reference="$WORDPRESSPATH/wordpress/wp-config-sample.php"   "$WORDPRESSPATH/wordpress/wp-config.php"
            echoG "Finished setting up WordPress."
        else
            echoR "WordPress setup failed. You may not have enough privileges to access $WORDPRESSPATH/wordpress/wp-config.php."
            ALLERRORS=1
        fi
    else
        echoR "WordPress setup failed. File $WORDPRESSPATH/wordpress/wp-config-sample.php does not exist."
        ALLERRORS=1
    fi
}


function test_mysql_password
{
    CURROOTPASSWORD=$ROOTPASSWORD
    TESTPASSWORDERROR=0
    
    #test it is the current password
    mysqladmin -uroot -p$CURROOTPASSWORD password $CURROOTPASSWORD
    if [ $? != 0 ] ; then
        printf '\033[31mPlease input the current root password:\033[0m'
        read answer
        mysqladmin -uroot -p$answer password $answer
        if [ $? = 0 ] ; then
            CURROOTPASSWORD=$answer
        else
            echoR "root password is incorrect. 2 attempts remaining."
            printf '\033[31mPlease input the current root password:\033[0m'
            read answer
            mysqladmin -u root -p$answer password $answer
            if [ $? = 0 ] ; then
                CURROOTPASSWORD=$answer
            else
                echoR "root password is incorrect. 1 attempt remaining."
                printf '\033[31mPlease input the current root password:\033[0m'
                read answer
                mysqladmin -u root -p$answer password $answer
                if [ $? = 0 ] ; then
                    CURROOTPASSWORD=$answer
                else
                    echoR "root password is incorrect. 0 attempts remaining."
                    echo
                    TESTPASSWORDERROR=1
                fi
            fi
        fi
    fi

    export CURROOTPASSWORD=$CURROOTPASSWORD
    export TESTPASSWORDERROR=$TESTPASSWORDERROR
}

function install_mysql
{
    if [ "x$ISCENTOS" = "x1" ] ; then
        yum -y install mysql-server
        if [ $? != 0 ] ; then
            echoR "An error occured during installation of Mysql-server. Please fix this error and try again."
            echoR "You may want to manually run the command 'yum -y install mysql-server' to check. Aborting installation!"
            exit 1
        fi
        service mysqld start
    else
        apt-get -y -f --force-yes install mysql-server
        if [ $? != 0 ] ; then
            echoR "An error occured during installation of Mysql-server. Please fix this error and try again."
            echoR "You may want to manually run the command 'apt-get -y -f --force-yes install mysql-server' to check. Aborting installation!"
            exit 1
        fi
        #mysqld start
        service mysql start
    fi
    
    if [ $? != 0 ] ; then
        echoR "An error occured during starting service of Mysql-server. "
        echoR "Please fix this error and try again. Aborting installation!"
        exit 1
    fi
    
    #mysql_secure_installation
    #mysql_install_db
    mysqladmin -u root password $ROOTPASSWORD
    if [ $? = 0 ] ; then
        echoG "Mysql root password set to $ROOTPASSWORD"
    else
        #test it is the current password
        mysqladmin -uroot -p$ROOTPASSWORD password $ROOTPASSWORD
        if [ $? = 0 ] ; then
            echoG "Mysql root password is $ROOTPASSWORD"
        else
            echoR "Failed to set Mysql root password to $ROOTPASSWORD, it may already have a root password."
            printf '\033[31mInstallation must know the password for the next step settings.\033[0m'
            test_mysql_password
            
            if [ "x$TESTPASSWORDERROR" = "x1" ] ; then
                echoY "If you forget your password you may stop the mysqld service and run the following command to reset it,"
                echoY "mysqld_safe --skip-grant-tables &"
                echoY "mysql --user=root mysql"
                echoY "update user set Password=PASSWORD('new-password') where user='root'; flush privileges; exit; "
                echoR "Aborting installation."
                echo
                exit 1
            fi
        
            if [ "x$CURROOTPASSWORD" != "x$ROOTPASSWORD" ] ; then
                echoY "Current mysql root password is $CURROOTPASSWORD, it will be changed to $ROOTPASSWORD."
                printf '\033[31mDo you still want to change it?[y/N]\033[0m '
                read answer
                echo

                if [ "x$answer" != "xY" ] && [ "x$answer" != "xy" ] ; then
                    echoG "OK, mysql root password not changed." 
                    ROOTPASSWORD=$CURROOTPASSWORD
                else
                    mysqladmin -u root -p$CURROOTPASSWORD password $ROOTPASSWORD
                    if [ $? = 0 ] ; then
                        echoG "OK, mysql root password changed to $ROOTPASSWORD."
                    else
                        echoR "Failed to change mysql root password, it is still $CURROOTPASSWORD."
                        ROOTPASSWORD=$CURROOTPASSWORD
                    fi
                fi
            fi
        fi
    fi
}

function setup_mysql
{
    local ERROR=

    #delete user if exists because I need to set the password
    mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';" 
    
    echo `mysql -uroot -p$ROOTPASSWORD -e "SELECT user FROM mysql.user"` | grep "$USERNAME" > /dev/null
    if [ $? = 0 ] ; then
        echoG "user $USERNAME exists in mysql.user"
    else
        mysql -uroot -p$ROOTPASSWORD  -e "CREATE USER $USERNAME@localhost IDENTIFIED BY '$USERPASSWORD';"
        if [ $? = 0 ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO '$USERNAME'@localhost IDENTIFIED BY '$USERPASSWORD';"
        else
            echoR "Failed to create mysql user $USERNAME. This user may already exist or a problem occured."
            echoR "Please check this and update the wp-config.php file."
            ERROR="Create user error"
        fi
    fi
    
    mysql -uroot -p$ROOTPASSWORD  -e "CREATE DATABASE IF NOT EXISTS $DATABASENAME;"
    if [ $? = 0 ] ; then
        mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON $DATABASENAME.* TO '$USERNAME'@localhost IDENTIFIED BY '$USERPASSWORD';"
    else
        echoR "Failed to create database $DATABASENAME. It may already exist or a problem occured."
        echoR "Please check this and update the wp-config.php file."
        if [ "x$ERROR" = "x" ] ; then
            ERROR="Create database error"
        else
            ERROR="$ERROR and create database error"
        fi  
    fi
    mysql -uroot -p$ROOTPASSWORD  -e "flush privileges;"
   
    if [ "x$ERROR" = "x" ] ; then
        echoG "Finished mysql setup without error."
    else
        echoR "Finished mysql setup - some error occured."
    fi
}

function resetmysqlroot
{
    MYSQLNAME=mysql
    if [ "x$ISCENTOS" = "x1" ] ; then
        MYSQLNAME=mysqld
    fi
    
    service $MYSQLNAME stop
    
    DEFAULTPASSWD=$1
    
    echo "update user set Password=PASSWORD('$DEFAULTPASSWD') where user='root'; flush privileges; exit; " > /tmp/resetmysqlroot.sql
    mysqld_safe --skip-grant-tables &
    #mysql --user=root mysql < /tmp/resetmysqlroot.sql
    mysql --user=root mysql -e "update user set Password=PASSWORD('$DEFAULTPASSWD') where user='root'; flush privileges; exit; "
    sleep 1            
    service $MYSQLNAME restart
}

function purgedatabase
{
    if [ "x$MYSQLINSTALLED" != "x1" ] ; then
        echoY "Mysql-server not installed."
    else
        local ERROR=0
        test_mysql_password

        if [ "x$TESTPASSWORDERROR" = "x1" ] ; then
            echoR "Failed to purge database."
            echo
            ERROR=1
            ALLERRORS=1
            #ROOTPASSWORD=123456
            #resetmysqlroot $ROOTPASSWORD
        else
            ROOTPASSWORD=$CURROOTPASSWORD
        fi
        

        if [ "x$ERROR" = "x0" ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';"  
            mysql -uroot -p$ROOTPASSWORD  -e "DROP DATABASE IF EXISTS $DATABASENAME;"
            echoY "Database purged."
        fi
    fi
}

function uninstall_result
{
    if [ "x$ALLERRORS" = "x0" ] ; then
        echoG "Uninstallation finished."
    else
        echoY "Uninstallation finished - some errors occured. Please check these as you may need to manually fix them."
    fi  
    echo
}


function install_ols
{
    if [ "x$ISCENTOS" = "x1" ] ; then
        echo "Install on Centos"
        install_ols_centos
    else
        echo "Install on Debian/Ubuntu"
        install_ols_debian
    fi
}

function config_server
{
    if [ -e "$SERVER_ROOT/conf/httpd_config.conf" ] ; then
        cat $SERVER_ROOT/conf/httpd_config.conf | grep "virtualhost wordpress" > /dev/null
        if [ $? != 0 ] ; then
            sed -i -e "s/adminEmails/adminEmails $EMAIL\n#adminEmails/" "$SERVER_ROOT/conf/httpd_config.conf"
            VHOSTCONF=$SERVER_ROOT/conf/vhosts/wordpress/vhconf.conf

            cat >> $SERVER_ROOT/conf/httpd_config.conf <<END 

virtualhost wordpress {
vhRoot                  $WORDPRESSPATH/wordpress/
configFile              $VHOSTCONF
allowSymbolLink         1
enableScript            1
restrained              0
setUIDMode              2
}

listener wordpress {
address                 *:$WPPORT
secure                  0
map                     wordpress $SITEDOMAIN
}


module cache {
param <<<PARAMFLAG

enableCache         1
qsCache             1
reqCookieCache      1
respCookieCache     1
ignoreReqCacheCtrl  1
ignoreRespCacheCtrl 0
expireInSeconds     2000
maxStaleAge         1000
enablePrivateCache  1
privateExpireInSeconds 1000                      
checkPrivateCache   1
checkPublicCache    1
maxCacheObjSize     100000000

PARAMFLAG
}

END
    
            mkdir -p $SERVER_ROOT/conf/vhosts/wordpress/
            cat > $VHOSTCONF <<END 
docRoot                   \$VH_ROOT/
index  {
  useServer               0
  indexFiles              index.php
}

context / {
  type                    NULL
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php
 
  rewrite  {
    enable                1
    inherit               1
    rules                 <<<END_rules
    rewriteFile           $WORDPRESSPATH/wordpress/.htaccess

END_rules

  }
}

END
            chown -R lsadm:lsadm $WORDPRESSPATH/conf/
        fi
        
        #setup password
        ENCRYPT_PASS=`"$SERVER_ROOT/admin/fcgi-bin/admin_php" -q "$SERVER_ROOT/admin/misc/htpasswd.php" $ADMINPASSWORD`
        if [ $? = 0 ] ; then
            echo "admin:$ENCRYPT_PASS" > "$SERVER_ROOT/admin/conf/htpasswd"
            if [ $? = 0 ] ; then
                echoY "Finished setting OpenLiteSpeed webAdmin password to $ADMINPASSWORD."
                echoY "Finished updating server configuration."
                
                #write the password file for record and remove the previous file.
                echo "WebAdmin password is [$ADMINPASSWORD]." > $SERVER_ROOT/password
            else
                echoY "OpenLiteSpeed webAdmin password not changed."
            fi
        fi
    else
        echoR "$SERVER_ROOT/conf/httpd_config.conf is missing, it seems that something went wrong during openlitespeed installation."
        ALLERRORS=1
    fi
}


function getCurStatus
{
    if [ -e $SERVER_ROOT/bin/openlitespeed ] ; then
        OLSINSTALLED=1
    else
        OLSINSTALLED=0
    fi
 
    which mysqladmin  > /dev/null 2>&1
    if [ $? = 0 ] ; then
        MYSQLINSTALLED=1
    else
        MYSQLINSTALLED=0
    fi
    
}

function changeOlsPassword
{
    LSWS_HOME=$SERVER_ROOT
    ENCRYPT_PASS=`"$LSWS_HOME/admin/fcgi-bin/admin_php" -q "$LSWS_HOME/admin/misc/htpasswd.php" $ADMINPASSWORD`
    echo "$ADMIN_USER:$ENCRYPT_PASS" > "$LSWS_HOME/admin/conf/htpasswd"
    echoY "Finished setting OpenLiteSpeed webAdmin password to $ADMINPASSWORD."
}


function uninstall
{
    if [ "x$OLSINSTALLED" = "x1" ] ; then
        echoY "Uninstalling ..."
        $SERVER_ROOT/bin/lswsctrl stop
        if [ "x$ISCENTOS" = "x1" ] ; then
            echo "Uninstall on Centos"
            uninstall_ols_centos
        else
            echo "Uninstall on Debian/Ubuntu"
            uninstall_ols_debian
        fi
        echoG Uninstalled.
    else
        echoY "OpenLiteSpeed not installed."
    fi
}

function readPassword
{
    if [ "x$1" != "x" ] ; then 
        TEMPPASSWORD=$1
    else
        passwd=
        echoY "Please input password for $2(press enter to get a random one):"
        read passwd
        if [ "x$passwd" = "x" ] ; then
            local RAND=$RANDOM
            local DATE0=`date`
            TEMPPASSWORD=`echo "$RAND0$DATE0" |  md5sum | base64 | head -c 8`
        else
            TEMPPASSWORD=$passwd
        fi
    fi
}


function check_password_follow
{
    #test if first letter is - or not.
    local PARAMCHAR=`echo $1 | awk '{print substr($0,1,1)}'`
    if [ "x$PARAMCHAR" = "x-" ] ; then 
        PASSWORDPROVIDE=
    else
        PASSWORDPROVIDE=$1
    fi
}



function usage
{
    echoY "Usage:                             " "$0 [options] [options] ..."
    echoY "Options:                           "
    echoG " --adminpassword(-a) [PASSWORD]    " "To set the webAdmin password for openlitespeed instead of using a random one."
    echoG "                                   " "If you omit [PASSWORD], ols1clk will prompt you to provide this password during installation."
    echoG " --email(-e) EMAIL                 " "To set the email of the administrator."
    echoG " --lsphp VERSION                   " "To set the version of lsphp, such as 56, now we support '${LSPHPVERLIST[@]}'."
    echoG " --wordpress(-w)                   " "Set to install and setup wordpress, ....FIXME......"
    echoG " --wordpressplus SITEDOMAIN        " "Set to install and setup wordpress, .........FIXME............."
    echoG " --wordpresspath WORDPRESSPATH     " "To specify a location for new wordpress install ot use an existing wordpress installation."
    echoG " --dbrootpassword(-r) [PASSWORD]   " "To set the mysql server root password instead of using a random one."
    echoG "                                   " "If you omit [PASSWORD], ols1clk will prompt you to provide this password during installation."
    echoG " --dbname DATABASENAME             " "To set the database name to be used by wordpress."
    echoG " --dbuser DBUSERNAME               " "To set the username of wordpress in mysql."
    echoG " --dbpassword [PASSWORD]           " "To set the password of the table used by wordpress in mysql instead of using a random one."
    echoG "                                   " "If you omit [PASSWORD], ols1clk will prompt you to provide this password during installation."
    echoG " --listenport WORDPRESSPORT        " "To set the listener port, default is 80."
    
    echoG " --wpuser WORDPRESSUSER            " "To set the wordpress user for admin login to wordpress dashboard"
    echoG " --wppassword [PASSWORD]           " "To set the wordpress user for admin login to wordpress dashboard"
    echoG " --wplang WORDPRESSLANGUAGE        " "To set the wordpress language"
    echoG " --sitetitle WORDPRESSSITETITLE    " "To set the wordpress site title"
    
    echoG " --uninstall                       " "To uninstall OpenLiteSpeed and remove installation directory."
    echoG " --purgeall                        " "To uninstall OpenLiteSpeed, remove installation directory, and purge all data in mysql."
    echoG " --version(-v)                     " "To display version information."
    echoG " --help(-h)                        " "To display usage."
    echo
}

#####################################################################################
####   Main function here
#####################################################################################
display_license
check_root
check_os
getCurStatus
#test if have $SERVER_ROOT , and backup it

while [ "$1" != "" ]; do
    case $1 in
        -a | --adminpassword )      check_password_follow $2
                                    if [ "x$PASSWORDPROVIDE" != "x" ] ; then
                                        shift
                                    fi
                                    ADMINPASSWORD=$PASSWORDPROVIDE
                                    ;;

        -e | --email )              shift
                                    EMAIL=$1
                                    ;;
                                    
             --lsphp )              shift
                                    #echo lsphpversion: $1
                                    cnt=${#LSPHPVERLIST[@]}
                                    for (( i = 0 ; i < cnt ; i++ ))
                                    do
                                        if [ "x$1" = "x${LSPHPVERLIST[$i]}" ] ; then
                                            LSPHPVER=$1
                                        fi
                                    done
                                    ;;                                    
                                    
        -w | --wordpress )          INSTALLWORDPRESS=1
                                    ;;
                                    
             --wordpressplus )      shift
                                    SITEDOMAIN=$1
                                    INSTALLWORDPRESS=1
                                    INSTALLWORDPRESSPLUS=1
                                    ;;
                                    
             --wordpresspath )      shift
                                    WORDPRESSPATH=$1
                                    INSTALLWORDPRESS=1
                                    ;;
                                    
        -r | --dbrootpassword )     check_password_follow $2
                                    if [ "x$PASSWORDPROVIDE" != "x" ] ; then
                                        shift
                                    fi
                                    ROOTPASSWORD=$PASSWORDPROVIDE
                                    ;;

             --dbname )             shift
                                    DATABASENAME=$1
                                    ;;
             --dbuser )             shift
                                    USERNAME=$1
                                    ;;
             --dbpassword )         check_password_follow $2
                                    if [ "x$PASSWORDPROVIDE" != "x" ] ; then
                                        shift
                                    fi
                                    USERPASSWORD=$PASSWORDPROVIDE
                                    ;;
                                    
             --listenport )         shift
                                    WPPORT=$1
                                    ;;
                         

             --wpuser )             shift
                                    WPUSER=$1
                                    ;;
             --wppassword )         check_password_follow $2
                                    if [ "x$PASSWORDPROVIDE" != "x" ] ; then
                                        shift
                                    fi
                                    WPPASSWORD=$PASSWORDPROVIDE
                                    ;;
                                    
             --wplang )             shift
                                    WPLANGUAGE=$1
                                    ;;
                                    
             --sitetitle )          shift
                                    WPTITLE=$1
                                    ;;
                                    
        -v | --version )            exit 0
                                    ;;                                    
                                    
        -h | --help )               usage
                                    exit 0
                                    ;;
            --uninstall )           uninstall
                                    uninstall_result
                                    exit 0
                                    ;;
            --purgeall )            uninstall
                                    purgedatabase
                                    uninstall_result
                                    exit 0
                                    ;;
        * )                         usage
                                    exit 0
                                    ;;
    esac
    shift
done



if [ "x$OSVER" = "xCENTOS5" ] ; then
   if [ "x$LSPHPVER" = "x70" ] ; then
       echoY "We do not support lsphp7 on Centos 5, will use lsphp56."
       LSPHPVER=56
   fi
fi

if [ "x$EMAIL" = "x" ] ; then
    if [ "x$SITEDOMAIN" = "x*" ] ; then
        EMAIL=root@localhost
    else
        EMAIL=root@$SITEDOMAIN
    fi
fi

readPassword "$ADMINPASSWORD" "webAdmin password"
ADMINPASSWORD=$TEMPPASSWORD
readPassword "$ROOTPASSWORD" "mysql root password"
ROOTPASSWORD=$TEMPPASSWORD
readPassword "$USERPASSWORD" "mysql user password"
USERPASSWORD=$TEMPPASSWORD
if [ "x$INSTALLWORDPRESSPLUS" = "x1" ] ; then
    readPassword "$WPPASSWORD" "Wordpress admin password"
    WPPASSWORD=$TEMPPASSWORD
fi

echo
echoR "Starting to install openlitespeed to $SERVER_ROOT/ with below parameters,"
echoY "WebAdmin password:        " "$ADMINPASSWORD"
echoY "WebAdmin email:           " "$EMAIL"
echoY "Mysql root Password:      " "$ROOTPASSWORD"
echoY "Database name:            " "$DATABASENAME"
echoY "Database username:        " "$USERNAME"
echoY "Database password:        " "$USERPASSWORD"
echoY "lsphp version:            " "$LSPHPVER"


WORDPRESSINSTALLED=
if [ "x$INSTALLWORDPRESS" = "x1" ] ; then
    echoY "Install wordpress:        " Yes
    echoY "WordPress listenport:     " "$WPPORT"
    echoY "Web site domain:          " "$SITEDOMAIN"
    
    if [ "x$INSTALLWORDPRESSPLUS" = "x1" ] ; then
        echoY "Wordpress plus:           " Yes
        echoY "Wordpress language:       " "$WPLANGUAGE"
        echoY "Wordpress site title:     " "$WPTITLE"
        echoY "Wordpress username:       " "$WPUSER"
        echoY "Wordpress password:       " "$WPPASSWORD"
    else
        echoY "Wordpress plus:           " No
    fi
    
    
    if [ -e "$WORDPRESSPATH/wordpress/wp-config.php" ] ; then
        echoY "WordPress location:       " "$WORDPRESSPATH.(Exsiting)"
        WORDPRESSINSTALLED=1
    else
        echoY "WordPress location:       " "$WORDPRESSPATH.(New install)"
        WORDPRESSINSTALLED=0
    fi


else
    echoY "Install WordPress:        " "No"
fi

echo
printf '\033[31mIs the settings correct? Type n to quit, otherwise will continue.[Y/n]\033[0m '
read answer
echo

if [ "x$answer" = "xN" ] || [ "x$answer" = "xn" ] ; then
    echoG "Aborting installation!" 
    exit 0
fi
echo 


####begin here#####
update_centos_hashlib
check_wget

if [ "x$OLSINSTALLED" = "x1" ] ; then
    echoY "OpenLiteSpeed is already installed, will attempt to update it."
fi
install_ols


if [ "x$INSTALLWORDPRESS" = "x1" ] ; then
    if [ "x$MYSQLINSTALLED" != "x1" ] ; then
        install_mysql
    else
        test_mysql_password
    fi    

    if [ "x$WORDPRESSINSTALLED" != "x1" ] ; then
        install_wordpress
        setup_wordpress
    
        if [ "x$TESTPASSWORDERROR" = "x1" ] ; then
            echoY "Mysql setup byppassed due to not know the root password."
        else
            ROOTPASSWORD=$CURROOTPASSWORD
            setup_mysql
        fi
    fi
    
    config_server
    
    if [ "x$WPPORT" = "x80" ] ; then
        echoY "Trying to stop some web servers that may be using port 80."
        killall -9 apache2  >  /dev/null 2>&1
        killall -9 httpd    >  /dev/null 2>&1
    fi
fi

$SERVER_ROOT/bin/lswsctrl stop
$SERVER_ROOT/bin/lswsctrl start
echo "mysql root password is [$ROOTPASSWORD]." >> $SERVER_ROOT/password

if [ "x$INSTALLWORDPRESSPLUS" = "x1" ] ; then
    if [ "x$WPPORT" != "x80" ] ; then
        INSTALLURL=http://$SITEDOMAIN:$WPPORT/wp-admin/install.php
    else
        INSTALLURL=http://$SITEDOMAIN/wp-admin/install.php
    fi

    wget $INSTALLURL>  /dev/null 2>&1
    sleep 5
    
    #echo "wget --post-data 'language=$WPLANGUAGE' --referer=$INSTALLURL $INSTALLURL?step=1"
    wget --no-check-certificate --post-data "language=$WPLANGUAGE" --referer=$INSTALLURL $INSTALLURL?step=1>  /dev/null 2>&1
    sleep 1
    
    #echo "wget --post-data 'weblog_title=$WPTITLE&user_name=$WPUSER&admin_password=$WPPASSWORD&pass1-text=$WPPASSWORD&admin_password2=$WPPASSWORD&pw_weak=on&admin_email=$EMAIL&Submit=Install+WordPress&language=$WPLANGUAGE' --referer=$INSTALLURL?step=1 $INSTALLURL?step=2 "
    wget --no-check-certificate --post-data "weblog_title=$WPTITLE&user_name=$WPUSER&admin_password=$WPPASSWORD&pass1-text=$WPPASSWORD&admin_password2=$WPPASSWORD&pw_weak=on&admin_email=$EMAIL&Submit=Install+WordPress&language=$WPLANGUAGE" --referer=$INSTALLURL?step=1 $INSTALLURL?step=2  >  /dev/null 2>&1

    echo "wordpress administrator username is [$WPUSER], password is [$WPPASSWORD]." >> $SERVER_ROOT/password
fi


echoY "Please be aware that your password was written to file '$SERVER_ROOT/password'." 

if [ "x$ALLERRORS" = "x0" ] ; then
    echoG "Congratulations! Installation finished."
    if [ "x$INSTALLWORDPRESS" = "x1" ] ; then
        echoG "Please access http://localhost:$WPPORT/ to finish setting up your WordPress site."
        echoG "And also you may want to activate Litespeed Cache plugin to get better performance."
    fi
else
    echoY "Installation finished. It seems some errors occured, please check this as you may need to manually fix them."
    if [ "x$INSTALLWORDPRESS" = "x1" ] ; then
        echoG "Please access http://localhost:$WPPORT/ to finish setting up your WordPress site."
        echoG "And also you may want to activate Litespeed Cache plugin to get better performance."
    fi
fi  
echo
echoG "If you run into any problems, they can sometimes be fixed by purgeall and reinstalling."
echoG 'Thanks for using "OpenLiteSpeed One click installation".'
echoG "Enjoy!"
echo
echo
