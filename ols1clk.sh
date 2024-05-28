#!/bin/bash
##############################################################################
#    Open LiteSpeed is an open source HTTP server.                           #
#    Copyright (C) 2013 - 2024 LiteSpeed Technologies, Inc.                  #
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

###    Author: LiteSpeed


TEMPRANDSTR=
OSNAMEVER=UNKNOWN
OSNAME=
OSVER=
OSTYPE=$(uname -m)
MARIADBCPUARCH=
SERVER_ROOT=/usr/local/lsws
WEBCF="$SERVER_ROOT/conf/httpd_config.conf"
EXAMPLE_VHOSTCONF="$SERVER_ROOT/conf/vhosts/Example/vhconf.conf"
RULE_FILE='modsec_includes.conf'
OWASP_DIR="${SERVER_ROOT}/conf/owasp"
CRS_DIR='owasp-modsecurity-crs'
OLSINSTALLED=
MYSQLINSTALLED=
TESTGETERROR=no
DATABASENAME=olsdbname
USERNAME=olsdbuser
DBPREFIX=wp_
VERBOSE=0
PURE_DB=0
PURE_MYSQL=0
PURE_PERCONA=0
WITH_MYSQL=0
WITH_PERCONA=0
PROXY=0
PROXY_TYPE=''
PROXY_SERVER='http://127.0.0.1:8080'
WORDPRESSPATH=$SERVER_ROOT/wordpress
PWD_FILE=$SERVER_ROOT/password
WPPORT=80
SSLWPPORT=443
WORDPRESSINSTALLED=
INSTALLWORDPRESS=0
INSTALLWORDPRESSPLUS=0
FORCEYES=0
WPLANGUAGE=en_US
WPUSER=wpuser
WPTITLE=MySite
SITEDOMAIN=*
EMAIL=
ADMINUSER='admin'
ADMINPORT='7080'
ADMINPASSWORD=
ROOTPASSWORD=
USERPASSWORD=
WPPASSWORD=
LSPHPVERLIST=(71 72 73 74 80 81 82 83)
MARIADBVERLIST=(10.2 10.3 10.4 10.5 10.6 10.7 10.8 10.9 10.10 10.11 11.0 11.1 11.2 11.3)
OLD_SYS_MARIADBVERLIST=(10.2 10.3 10.4 10.5)
LSPHPVER=82
MARIADBVER=10.11
MYSQLVER=8.0
PERCONAVER=80
WEBADMIN_LSPHPVER=74
OWASP_V='4.2.0'
SET_OWASP=
ALLERRORS=0
TEMPPASSWORD=
ACTION=INSTALL
FOLLOWPARAM=
CONFFILE=myssl.conf
CSR=example.csr
KEY=example.key
CERT=example.crt
EPACE='        '
FPACE='    '
APT='apt-get -qq'
YUM='yum -q'
MYGITHUBURL=https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh

function echoY
{
    FLAG=$1
    shift
    echo -e "\033[38;5;148m$FLAG\033[39m$@"
}

function echoG
{
    FLAG=$1
    shift
    echo -e "\033[38;5;71m$FLAG\033[39m$@"
}

function echoB
{
    FLAG=$1
    shift
    echo -e "\033[38;1;34m$FLAG\033[39m$@"
}

function echoR
{
    FLAG=$1
    shift
    echo -e "\033[38;5;203m$FLAG\033[39m$@"
}

function echoW
{
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

function echoNW
{
    FLAG=${1}
    shift
    echo -e "\033[1m${FLAG}\033[0m${@}"
}

function echoCYAN
{
    FLAG=$1
    shift
    echo -e "\033[1;36m$FLAG\033[0m$@"
}

function silent
{
    if [ "${VERBOSE}" = '1' ] ; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

function change_owner
{
    chown -R ${USER}:${GROUP} ${1}
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

function update_system(){
    echoG 'System update'
    if [ "$OSNAME" = "centos" ] ; then
        silent ${YUM} update -y >/dev/null 2>&1
    else
        disable_needrestart
        silent ${APT} update && ${APT} upgrade -y >/dev/null 2>&1
    fi
}

function check_wget
{
    which wget  >/dev/null 2>&1
    if [ $? != 0 ] ; then
        if [ "$OSNAME" = "centos" ] ; then
            silent ${YUM} -y install wget
        else
            ${APT} -y install wget
        fi

        which wget  >/dev/null 2>&1
        if [ $? != 0 ] ; then
            echoR "An error occured during wget installation."
            ALLERRORS=1
        fi
    fi
}

function check_curl
{
    which curl  >/dev/null 2>&1
    if [ $? != 0 ] ; then
        if [ "$OSNAME" = "centos" ] ; then
            silent ${YUM} -y install curl
        else
            ${APT} -y install curl
        fi

        which curl  >/dev/null 2>&1
        if [ $? != 0 ] ; then
            echoR "An error occured during curl installation."
            ALLERRORS=1
        fi
    fi
}

function update_email
{
    if [ "$EMAIL" = '' ] ; then
        if [ "$SITEDOMAIN" = "*" ] ; then
            EMAIL=root@localhost
        else
            EMAIL=root@$SITEDOMAIN
        fi
    fi
}

function restart_lsws
{
    systemctl stop lsws >/dev/null 2>&1
    systemctl start lsws
}

function usage
{
    echo -e "\033[1mOPTIONS\033[0m"
    echoW " --adminuser [USERNAME]"           "${EPACE}    To set the WebAdmin username for OpenLiteSpeed instead of admin."
    echoNW "  -A,    --adminpassword [PASSWORD]" "${EPACE}To set the WebAdmin password for OpenLiteSpeed instead of using a random one."
    echoW " --adminport [PORTNUMBER]"           "${EPACE}    To set the WebAdmin console port number instead of 7080."
    echoNW "  -E,    --email [EMAIL]          " "${EPACE} To set the administrator email."
    echoW " --lsphp [VERSION]                 " "To set the LSPHP version, such as 82. We currently support versions '${LSPHPVERLIST[@]}'."
    echoW " --mariadbver [VERSION]            " "To set MariaDB version, such as 10.6. We currently support versions '${MARIADBVERLIST[@]}'."
    echoNW "  -W,    --wordpress              " "${EPACE} To install WordPress. You will still need to complete the WordPress setup by browser"
    echoW " --wordpressplus [SITEDOMAIN]      " "To install, setup, and configure WordPress, also LSCache will be enabled"
    echoW " --wordpresspath [WP_PATH]         " "To specify a location for the new WordPress installation or an existing WordPress."
    echoNW "  -R,    --dbrootpassword [PASSWORD]  " "     To set the database root password instead of using a random one."
    echoW " --dbname [DATABASENAME]           " "To set the database name to be used by WordPress."
    echoW " --dbuser [DBUSERNAME]             " "To set the WordPress username in the database."
    echoW " --dbpassword [PASSWORD]           " "To set the WordPress table password in MySQL instead of using a random one."
    echoW " --prefix [PREFIXNAME]             " "To set the WordPress table prefix."
    echoW " --listenport [PORT]               " "To set the HTTP server listener port, default is 80."
    echoW " --ssllistenport [PORT]            " "To set the HTTPS server listener port, default is 443."
    echoW " --wpuser [WORDPRESSUSER]          " "To set the WordPress admin user for WordPress dashboard login. Default value is wpuser."
    echoW " --wppassword [PASSWORD]           " "To set the WordPress admin user password for WordPress dashboard login."
    echoW " --wplang [WP_LANGUAGE]            " "To set the WordPress language. Default value is \"en_US\" for English."
    echoW " --sitetitle [WP_TITLE]            " "To set the WordPress site title. Default value is mySite."
    echoW " --pure-mariadb                    " "To install OpenLiteSpeed and MariaDB"
    echoW " --pure-mysql                      " "To install OpenLiteSpeed and MySQL"
    echoW " --pure-percona                    " "To install OpenLiteSpeed and Percona"
    echoW " --with-mysql                      " "To install OpenLiteSpeed/App with MySQL"
    echoW " --with-percona                    " "To install OpenLiteSpeed/App with Percona"
    echoW " --owasp-enable                    " "To enable mod_security with OWASP rules. If OLS is installed, then enable the owasp directly"
    echoW " --owasp-disable                   " "To disable mod_security with OWASP rules."
    echoW " --proxy-r                         " "To set a proxy with rewrite type."
    echoW " --proxy-c                         " "To set a proxy with config type."
    echoNW "  -U,    --uninstall              " "${EPACE} To uninstall OpenLiteSpeed and remove installation directory."
    echoNW "  -P,    --purgeall               " "${EPACE} To uninstall OpenLiteSpeed, remove installation directory, and purge all data in MySQL."
    echoNW "  -Q,    --quiet                  " "${EPACE} To use quiet mode, won't prompt to input anything."
    echoNW "  -V,    --version                " "${EPACE} To display the script version information."
    echoNW "  -v,    --verbose                " "${EPACE} To display more messages during the installation."
    echoW " --update                          " "To update ols1clk from github."
    echoNW "  -H,    --help                   " "${EPACE} To display help messages."
    echo 
    echo -e "\033[1mEXAMPLES\033[0m"
    echoW "./ols1clk.sh                       " "To install OpenLiteSpeed with a random WebAdmin password."
    echoW "./ols1clk.sh --lsphp 83            " "To install OpenLiteSpeed with lsphp83."
    echoW "./ols1clk.sh -A 123456 -e a@cc.com " "To install OpenLiteSpeed with WebAdmin password  \"123456\" and email a@cc.com."
    echoW "./ols1clk.sh -R 123456 -W          " "To install OpenLiteSpeed with WordPress and MySQL root password \"123456\"."
    echoW "./ols1clk.sh --wordpressplus a.com " "To install OpenLiteSpeed with a fully configured WordPress installation at \"a.com\"."
    echo
    exit 0
}

function display_license
{
    echoY '**********************************************************************************************'
    echoY '*                    Open LiteSpeed One click installation, Version 3.1                      *'
    echoY '*                    Copyright (C) 2016 - 2024 LiteSpeed Technologies, Inc.                  *'
    echoY '**********************************************************************************************'
}

function check_os
{
    if [ -f /etc/centos-release ] ; then
        OSNAME=centos
        USER='nobody'
        GROUP='nobody'
        case $(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1) in 
        7)
            OSNAMEVER=CENTOS7
            OSVER=7
            ;;
        8)
            OSNAMEVER=CENTOS8
            OSVER=8
            ;;
        9)
            OSNAMEVER=CENTOS9
            OSVER=9
            ;;            
        esac
    elif [ -f /etc/redhat-release ] ; then
        OSNAME=centos
        USER='nobody'
        GROUP='nobody'
        case $(cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f1) in 
        7)
            OSNAMEVER=CENTOS7
            OSVER=7
            ;;
        8)
            OSNAMEVER=CENTOS8
            OSVER=8
            ;;
        9)
            OSNAMEVER=CENTOS9
            OSVER=9
            ;;            
        esac             
    elif [ -f /etc/lsb-release ] ; then
        OSNAME=ubuntu
        USER='nobody'
        GROUP='nogroup'
        case $(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d = -f 2) in
        bionic)
            OSNAMEVER=UBUNTU18
            OSVER=bionic
            MARIADBCPUARCH="arch=amd64"
            ;;
        focal)            
            OSNAMEVER=UBUNTU20
            OSVER=focal
            MARIADBCPUARCH="arch=amd64"
            ;;
        jammy)            
            OSNAMEVER=UBUNTU22
            OSVER=jammy
            MARIADBCPUARCH="arch=amd64"
            ;;          
        noble)            
            OSNAMEVER=UBUNTU24
            OSVER=noble
            MARIADBCPUARCH="arch=amd64"
            ;;                
        esac
    elif [ -f /etc/debian_version ] ; then
        OSNAME=debian
        USER='nobody'
        GROUP='nogroup'        
        case $(cat /etc/os-release | grep VERSION_CODENAME | cut -d = -f 2) in
        stretch) 
            OSNAMEVER=DEBIAN9
            OSVER=stretch
            MARIADBCPUARCH="arch=amd64,i386"
            ;;
        buster)
            OSNAMEVER=DEBIAN10
            OSVER=buster
            MARIADBCPUARCH="arch=amd64,i386"
            ;;
        bullseye)
            OSNAMEVER=DEBIAN11
            OSVER=bullseye
            MARIADBCPUARCH="arch=amd64,i386"
            ;;
        bookworm)
            OSNAMEVER=DEBIAN12
            OSVER=bookworm
            MARIADBCPUARCH="arch=amd64,i386"
            ;;            
        esac    
    fi

    if [ "$OSNAMEVER" = '' ] ; then
        echoR "Sorry, currently one click installation only supports Centos(7-9), Debian(10-12) and Ubuntu(18,20,22,24)."
        echoR "You can download the source code and build from it."
        echoR "The url of the source code is https://github.com/litespeedtech/openlitespeed/releases."
        exit 1
    else
        if [ "$OSNAME" = "centos" ] ; then
            echoG "Current platform is "  "$OSNAME $OSVER."
        else
            export DEBIAN_FRONTEND=noninteractive
            echoG "Current platform is "  "$OSNAMEVER $OSNAME $OSVER."
        fi
    fi
}

function fst_match_line
{
    FIRST_LINE_NUM=$(grep -n -m 1 "${1}" ${2} | awk -F ':' '{print $1}')
}
function fst_match_after
{
    FIRST_NUM_AFTER=$(tail -n +${1} ${2} | grep -n -m 1 ${3} | awk -F ':' '{print $1}')
}
function lst_match_line
{
    fst_match_after ${1} ${2} ${3}
    LAST_LINE_NUM=$((${FIRST_LINE_NUM}+${FIRST_NUM_AFTER}-1))
}

function update_centos_hashlib
{
    if [ "$OSNAME" = 'centos' ] ; then
        silent ${YUM} -y install python-hashlib
    fi
}

function install_ols_centos
{
    local action=install
    if [ "$1" = "Update" ] ; then
        action=update
    elif [ "$1" = "Reinstall" ] ; then
        action=reinstall
    fi

    local JSON=
    if [ "x$LSPHPVER" = "x70" ] || [ "x$LSPHPVER" = "x71" ] || [ "x$LSPHPVER" = "x72" ] || [ "x$LSPHPVER" = "x73" ] || [ "x$LSPHPVER" = "x74" ]; then
        JSON=lsphp$LSPHPVER-json
    fi

    if [ "${OSNAMEVER}" = 'CENTOS9' ]; then
        echoB "${FPACE} - add remi repo"
        silent ${YUM} -y $action https://rpms.remirepo.net/enterprise/remi-release-${OSVER}.rpm
    else
        echoB "${FPACE} - add epel repo"
        silent ${YUM} -y $action epel-release
    fi
    echoB "${FPACE} - add litespeedtech repo"
    sudo wget -q -O - https://repo.litespeed.sh | sudo bash >/dev/null 2>&1

    echoB "${FPACE} - $1 OpenLiteSpeed"
    silent ${YUM} -y $action openlitespeed
    if [ ! -e $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp ] ; then
        action=install
    fi
    echoB "${FPACE} - $1 lsphp$LSPHPVER"
    if [ "$action" = "reinstall" ] ; then
        silent ${YUM} -y remove lsphp$LSPHPVER-mysqlnd
    fi
    silent ${YUM} -y install lsphp$LSPHPVER-mysqlnd
    if [[ "$LSPHPVER" == 8* ]]; then 
        silent ${YUM} -y $action lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring \
        lsphp$LSPHPVER-xml lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap
    else
        silent ${YUM} -y $action lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring \
        lsphp$LSPHPVER-xml lsphp$LSPHPVER-mcrypt lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap $JSON
    fi
    if [ $? != 0 ] ; then
        echoR "An error occured during OpenLiteSpeed installation."
        ALLERRORS=1
    else
        echoB "${FPACE} - Setup lsphp symlink"
        ln -sf $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp $SERVER_ROOT/fcgi-bin/lsphpnew
        sed -i -e "s/fcgi-bin\/lsphp/fcgi-bin\/lsphpnew/g" "${WEBCF}"
        sed -i -e "s/lsphp${WEBADMIN_LSPHPVER}\/bin\/lsphp/lsphp$LSPHPVER\/bin\/lsphp/g" "${WEBCF}"
        if [ ! -f /usr/bin/php ]; then
            ln -s ${SERVER_ROOT}/lsphp${LSPHPVER}/bin/php /usr/bin/php
        fi          
    fi
    if [ ${INSTALLWORDPRESS} = 1 ]; then
        silent ${YUM} -y $action lsphp$LSPHPVER-imagick lsphp$LSPHPVER-opcache lsphp$LSPHPVER-redis lsphp$LSPHPVER-memcached lsphp$LSPHPVER-intl
    fi    
}

function uninstall_ols_centos
{
    echoB "${FPACE} - Remove OpenLiteSpeed"
    silent ${YUM} -y remove openlitespeed
    if [ $? != 0 ] ; then
        echoR "An error occured while uninstalling OpenLiteSpeed."
        ALLERRORS=1
    fi
    rm -rf $SERVER_ROOT/
}

function uninstall_php_centos
{
    ls "${SERVER_ROOT}" | grep lsphp >/dev/null
    if [ $? = 0 ] ; then
        local LSPHPSTR="$(ls ${SERVER_ROOT} | grep -i lsphp | tr '\n' ' ')"
        for LSPHPVER in ${LSPHPSTR}; do 
            echoB "${FPACE} - Detect LSPHP version $LSPHPVER"
            if [ "$LSPHPVER" = "lsphp80" ]; then
                silent ${YUM} -y remove lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring \
                lsphp$LSPHPVER-mysqlnd lsphp$LSPHPVER-xml  lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap lsphp*
            else
                silent ${YUM} -y remove lsphp$LSPHPVER lsphp$LSPHPVER-common lsphp$LSPHPVER-gd lsphp$LSPHPVER-process lsphp$LSPHPVER-mbstring \
                lsphp$LSPHPVER-mysqlnd lsphp$LSPHPVER-xml lsphp$LSPHPVER-mcrypt lsphp$LSPHPVER-pdo lsphp$LSPHPVER-imap $JSON lsphp*
            fi                
            if [ $? != 0 ] ; then
                echoR "An error occured while uninstalling lsphp$LSPHPVER"
                ALLERRORS=1
            fi
        done 
    else
        echoB "${FPACE} - Uinstall LSPHP"
        ${YUM} -y remove lsphp*
        echoR "Uninstallation cannot get the currently installed LSPHP version."
        echoY "May not uninstall LSPHP correctly."
        LSPHPVER=
    fi
}

function install_ols_debian
{
    local action=
    local INSTALL_STATUS=0
    if [ "$1" = "Update" ] ; then
        action="--only-upgrade"
    elif [ "$1" = "Reinstall" ] ; then
        action="--reinstall"
    fi
    echoB "${FPACE} - add litespeedtech repo"
    sudo wget -q -O - https://repo.litespeed.sh | sudo bash >/dev/null 2>&1
    echoB "${FPACE} - update list"
    ${APT} -y update
    echoB "${FPACE} - $1 OpenLiteSpeed"
    silent ${APT} -y install $action openlitespeed

    if [ ${?} != 0 ] ; then
        echoR "An error occured during OpenLiteSpeed installation."
        ALLERRORS=1
        INSTALL_STATUS=1
    fi
    if [ ! -e $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp ] ; then
        action=
    fi
    echoB "${FPACE} - $1 lsphp$LSPHPVER"
    silent ${APT} -y install $action lsphp$LSPHPVER lsphp$LSPHPVER-mysql lsphp$LSPHPVER-imap lsphp$LSPHPVER-curl

    if [ "$LSPHPVER" = "56" ]; then
        silent ${APT} -y install $action lsphp$LSPHPVER-gd lsphp$LSPHPVER-mcrypt
    elif [[ "$LSPHPVER" == 8* ]]; then
        silent ${APT} -y install $action lsphp$LSPHPVER-common
    else
        silent ${APT} -y install $action lsphp$LSPHPVER-common lsphp$LSPHPVER-json
    fi

    if [ $? != 0 ] ; then
        echoR "An error occured during lsphp$LSPHPVER installation."
        ALLERRORS=1
    fi
    
    if [ -e $SERVER_ROOT/bin/openlitespeed ]; then 
        echoB "${FPACE} - Setup lsphp symlink"
        ln -sf $SERVER_ROOT/lsphp$LSPHPVER/bin/lsphp $SERVER_ROOT/fcgi-bin/lsphpnew
        sed -i -e "s/fcgi-bin\/lsphp/fcgi-bin\/lsphpnew/g" "${WEBCF}"    
        sed -i -e "s/lsphp${WEBADMIN_LSPHPVER}\/bin\/lsphp/lsphp$LSPHPVER\/bin\/lsphp/g" "${WEBCF}"
        if [ ! -f /usr/bin/php ]; then
            ln -s ${SERVER_ROOT}/lsphp${LSPHPVER}/bin/php /usr/bin/php
        fi        
    fi
    if [ ${INSTALLWORDPRESS} = 1 ]; then
        silent ${APT} -y install $action lsphp$LSPHPVER-imagick lsphp$LSPHPVER-opcache lsphp$LSPHPVER-redis lsphp$LSPHPVER-memcached lsphp$LSPHPVER-intl
    fi    
}


function uninstall_ols_debian
{
    echoB "${FPACE} - Uninstall OpenLiteSpeed"
    silent ${APT} -y purge openlitespeed
    silent ${APT} -y remove openlitespeed
    ${APT} clean
    #rm -rf $SERVER_ROOT/
}

function uninstall_php_debian
{
    echoB "${FPACE} - Uninstall LSPHP"
    silent ${APT} -y --purge remove lsphp*
    if [ -e /usr/bin/php ] && [ -L /usr/bin/php ]; then 
        rm -f /usr/bin/php
    fi
}

function action_uninstall
{
    if [ "$ACTION" = "UNINSTALL" ] ; then
        uninstall_warn
        uninstall
        uninstall_result
        exit 0
    fi    
} 

function action_purgeall
{    
    if [ "$ACTION" = "PURGEALL" ] ; then
        uninstall_warn
        if [ "$ROOTPASSWORD" = '' ] ; then
            passwd=
            echoY "Please input the MySQL root password: "
            read passwd
            ROOTPASSWORD=$passwd
        fi
        uninstall
        purgedatabase
        uninstall_result
        exit 0
    fi
}

function config_php
{
    echoB "${FPACE} - Config php.ini"
    if [ -f /etc/redhat-release ] ; then
        PHPINICONF="${SERVER_ROOT}/lsphp${LSPHPVER}/etc/php.ini"
    else
        PHPMVER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d".")
        PHPINICONF="${SERVER_ROOT}/lsphp${LSPHPVER}/etc/php/${PHPMVER}/litespeed/php.ini"
    fi
    if [ -e "${PHPINICONF}" ]; then 
        sed -i 's|memory_limit = 128M|memory_limit = 256M|g' ${PHPINICONF}
        sed -i 's|max_execution_time = 30|max_execution_time = 120|g' ${PHPINICONF}
        sed -i 's|max_input_time = 60|max_input_time = 240|g' ${PHPINICONF}
        sed -i 's|post_max_size = 8M|post_max_size = 256M|g' ${PHPINICONF}
        sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 256M|g' ${PHPINICONF}
    else
        echoY "${PHPINICONF} does not exsit, skip!"
    fi    
}

function disable_needrestart
{
    if [ -d /etc/needrestart/conf.d ]; then
        echoG 'List Restart services only'
        cat >> /etc/needrestart/conf.d/disable.conf <<END
# Restart services (l)ist only, (i)nteractive or (a)utomatically. 
\$nrconf{restart} = 'l'; 
# Disable hints on pending kernel upgrades. 
\$nrconf{kernelhints} = 0;         
END
    fi
}

function download_wordpress
{
    echoG 'Start Download WordPress file'
    if [ ! -e "$WORDPRESSPATH" ] ; then
        local WPDIRNAME=$(dirname $WORDPRESSPATH)
        local WPBASENAME=$(basename $WORDPRESSPATH)
        mkdir -p "$WORDPRESSPATH"; 
        cd "$WORDPRESSPATH"
    else
        echoG "$WORDPRESSPATH exists, will use it."
    fi
    if [ "${WORDPRESSINSTALLED}" = '0' ];then 
        wp core download \
            --locale=$WPLANGUAGE \
            --path=$WORDPRESSPATH \
            --allow-root \
            --quiet
    fi        
    echoG 'End Download WordPress file'
}
function create_wordpress_cf
{
    echoG 'Start Create Wordpress config'
    cd "$WORDPRESSPATH"
    wp config create \
        --dbname=$DATABASENAME \
        --dbuser=$USERNAME \
        --dbpass=$USERPASSWORD \
        --dbprefix=$DBPREFIX \
        --locale=ro_RO \
        --allow-root \
        --quiet
    echoG 'Done Create Wordpress config'
}

function install_wordpress_core
{
    echoG 'Start Setting Core Wordpress'
    cd "$WORDPRESSPATH"
    wp core install \
        --url=$SITEDOMAIN \
        --title=$WPTITLE \
        --admin_user=$WPUSER \
        --admin_password=$WPPASSWORD \
        --admin_email=$EMAIL \
        --skip-email \
        --allow-root
    echoG 'Install wordpress Cache plugin'    
    wp plugin install litespeed-cache \
        --allow-root \
        --activate \
        --quiet
    echoG 'End Setting Core Wordpress'
}

function random_password
{
    if [ ! -z ${1} ]; then 
        TEMPPASSWORD="${1}"
    else    
        TEMPPASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo '')
    fi
}

function random_strong_password
{
    if [ ! -z ${1} ]; then 
        TEMPPASSWORD="${1}"
    else    
        TEMPPASSWORD=$(openssl rand -base64 32)
    fi
}

function main_gen_password
{
    random_password "${ADMINPASSWORD}"
    ADMINPASSWORD="${TEMPPASSWORD}"
    random_strong_password "${ROOTPASSWORD}"
    ROOTPASSWORD="${TEMPPASSWORD}"
    random_strong_password "${USERPASSWORD}"
    USERPASSWORD="${TEMPPASSWORD}"
    random_password "${WPPASSWORD}"
    WPPASSWORD="${TEMPPASSWORD}"
    read_password "$ADMINPASSWORD" "webAdmin password"
    ADMINPASSWORD=$TEMPPASSWORD
    
    if [ "$INSTALLWORDPRESS" = "1" ] ; then
        read_password "$ROOTPASSWORD" "MySQL root password"
        ROOTPASSWORD=$TEMPPASSWORD
        read_password "$USERPASSWORD" "MySQL user password"
        USERPASSWORD=$TEMPPASSWORD
    fi

    if [ "$INSTALLWORDPRESSPLUS" = "1" ] ; then
        read_password "$WPPASSWORD" "WordPress admin password"
        WPPASSWORD=$TEMPPASSWORD
    fi    
}

function main_ols_password
{
    echo "WebAdmin username is [admin], password is [$ADMINPASSWORD]." >> ${PWD_FILE}
    set_ols_password
}

function test_mysql_password
{
    CURROOTPASSWORD=$ROOTPASSWORD
    TESTPASSWORDERROR=0

    mysqladmin -uroot -p$CURROOTPASSWORD password $CURROOTPASSWORD
    if [ $? != 0 ] ; then
        #Sometimes, mysql will treat the password error and restart will fix it.
        service mysql restart
        if [ $? != 0 ] && [ "$OSNAME" = "centos" ] ; then
            service mysqld restart
        fi

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
                mysqladmin -uroot -p$answer password $answer
                if [ $? = 0 ] ; then
                    CURROOTPASSWORD=$answer
                else
                    echoR "root password is incorrect. 1 attempt remaining."
                    printf '\033[31mPlease input the current root password:\033[0m'
                    read answer
                    mysqladmin -uroot -p$answer password $answer
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
    fi

    export TESTPASSWORDERROR=$TESTPASSWORDERROR
    if [ "x$TESTPASSWORDERROR" = "x1" ] ; then
        export CURROOTPASSWORD=
    else
        export CURROOTPASSWORD=$CURROOTPASSWORD
    fi
}

function centos_install_mariadb
{
    echoB "${FPACE} - Add MariaDB repo"
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$MARIADBVER" >/dev/null 2>&1
#    local REPOFILE=/etc/yum.repos.d/MariaDB.repo
#    if [ ! -f $REPOFILE ] ; then
#        local CENTOSVER=
#        if [ "$OSTYPE" != "x86_64" ] ; then
#            CENTOSVER=centos$OSVER-x86
#        else
#            CENTOSVER=centos$OSVER-amd64
#        fi
#        if [ "$OSNAMEVER" = "CENTOS8" ] || [ "$OSNAMEVER" = "CENTOS9" ]; then
#            rpm --quiet --import https://downloads.mariadb.com/MariaDB/MariaDB-Server-GPG-KEY
#            cat >> $REPOFILE <<END
#[mariadb]
#name = MariaDB
#baseurl = https://downloads.mariadb.com/MariaDB/mariadb-$MARIADBVER/yum/rhel/\$releasever/\$basearch
#gpgkey = file:///etc/pki/rpm-gpg/MariaDB-Server-GPG-KEY
#gpgcheck=1
#enabled = 1
#module_hotfixes = 1
#END
#        else
#            cat >> $REPOFILE <<END
#[mariadb]
#name = MariaDB
#baseurl = http://yum.mariadb.org/$MARIADBVER/$CENTOSVER
#gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
#gpgcheck=1

#END
#        fi 
#    fi
    echoB "${FPACE} - Install MariaDB"
    if [ "$OSNAMEVER" = "CENTOS8" ] || [ "$OSNAMEVER" = "CENTOS9" ]; then
        silent ${YUM} install -y boost-program-options
        silent ${YUM} --disablerepo=AppStream install -y MariaDB-server MariaDB-client
    else
        silent ${YUM} -y install MariaDB-server MariaDB-client
    fi
    if [ $? != 0 ] ; then
        echoR "An error occured during installation of MariaDB. Please fix this error and try again."
        echoR "You may want to manually run the command '${YUM} -y install MariaDB-server MariaDB-client' to check. Aborting installation!"
        exit 1
    fi
    echoB "${FPACE} - Start MariaDB"
    if [ "$OSNAMEVER" = "CENTOS9" ] || [ "$OSNAMEVER" = "CENTOS8" ] || [ "$OSNAMEVER" = "CENTOS7" ] ; then
        silent systemctl enable mariadb
        silent systemctl start  mariadb
    else
        service mysql start
    fi    
}

function centos_install_mysql
{
    echoB "${FPACE} - Add MySQL repo"
    if [ "${OSVER}" = '9' ]; then 
        silent ${YUM} install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm    
    elif [ "${OSVER}" = '8' ]; then 
        silent ${YUM} install -y https://dev.mysql.com/get/mysql80-community-release-el8-4.noarch.rpm
    elif [ "${OSVER}" = '7' ]; then 
        silent ${YUM} install -y https://dev.mysql.com/get/mysql80-community-release-el7-6.noarch.rpm
    else
        echoR 'No repo found, exit!'; exit 1
    fi
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 >/dev/null 
    yum-config-manager --disable mysql57-community >/dev/null
    yum-config-manager --enable mysql80-community  >/dev/null
    if yum search 'mysql-community-server' | grep 'mysql-community-server\.' >/dev/null 2>&1; then 
        silent ${YUM} install -y mysql-community-server
    else
        silent ${YUM} install -y mysql-server
    fi
    service mysqld start 2>/dev/null
}

function centos_install_percona
{

    echoB "${FPACE} - Add Percona repo"
    silent ${YUM} install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    echoB "${FPACE} - Enable Percona repo"
    percona-release setup ps${PERCONAVER} -y >/dev/null 2>&1
    silent ${YUM} install -y percona-server-server
    service mysqld start 2>/dev/null
}    

function centos_install_unzip
{
    if [ ! -f /usr/bin/unzip ]; then
        echoB "${FPACE} - Install Unzip"
        yum update >/dev/null 2>&1
        yum install unzip -y >/dev/null 2>&1
    fi
}

function debian_install_mariadb
{
    echoB "${FPACE} - Install software properties"
    if [ "$OSNAMEVER" = "DEBIAN8" ]; then
        silent ${APT} -y -f install software-properties-common
    elif [ "$OSNAME" = "debian" ]; then
        silent ${APT} -y -f install software-properties-common gnupg
    elif [ "$OSNAME" = "ubuntu" ]; then
        silent ${APT} -y -f install software-properties-common
    fi
    #MARIADB_KEY='/usr/share/keyrings/mariadb.gpg'
    #wget -q -O- https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor > "${MARIADB_KEY}"
    #if [ ! -e "${MARIADB_KEY}" ]; then 
    #    echoR "${MARIADB_KEY} does not exist, please check the key, exit!"
    #    exit 1
    #fi
    echoB "${FPACE} - Add MariaDB repo"
	
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-$MARIADBVER" >/dev/null 2>&1

    #if [ -e /etc/apt/sources.list.d/mariadb.list ]; then  
    #    grep -Fq  "mirror.mariadb.org" /etc/apt/sources.list.d/mariadb.list >/dev/null 2>&1
    #    if [ $? != 0 ] ; then
    #        echo "deb [$MARIADBCPUARCH signed-by=${MARIADB_KEY}] http://mirror.mariadb.org/repo/$MARIADBVER/$OSNAME $OSVER main"  > /etc/apt/sources.list.d/mariadb.list
    #    fi
    #else 
    #    echo "deb [$MARIADBCPUARCH signed-by=${MARIADB_KEY}] http://mirror.mariadb.org/repo/$MARIADBVER/$OSNAME $OSVER main"  > /etc/apt/sources.list.d/mariadb.list
    #fi
    echoB "${FPACE} - Update packages"
    ${APT} update
    echoB "${FPACE} - Install MariaDB"
    silent ${APT} -y -f install mariadb-server
    if [ $? != 0 ] ; then
        echoR "An error occured during installation of MariaDB. Please fix this error and try again."
        echoR "You may want to manually run the command 'apt-get -y -f --allow-unauthenticated install mariadb-server' to check. Aborting installation!"
        exit 1
    fi
    echoB "${FPACE} - Start MariaDB"
    service mysql start
    if [ ${?} != 0 ]; then
        service mariadb start
    fi
}

function debian_install_mysql
{
    echoB "${FPACE} - Install software properties"
    local MYSQL_REPO='/etc/apt/sources.list.d/mysql.list'
    silent ${APT} -y -f install software-properties-common
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3A79BD29 >/dev/null 2>&1
    apt-key list 2>&1 | grep MySQL >/dev/null 
    if [ ${?} != 0 ]; then 
        echoY 'Key add failed from keyserver.ubuntu.com, try pgp.mit.edu!'
        apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29
        apt-key list 2>&1 | grep MySQL >/dev/null 
        if [ ${?} != 0 ]; then 
            echoR 'Key add failed from pgp.mit.edu, please check the key issue, exit!'
            exit 1
        fi
    fi
    echoB "${FPACE} - Add mysql ${MYSQLVER} repo"
    if [ -e "${MYSQL_REPO}" ]; then
        grep -Fq  "repo.mysql.com" "${MYSQL_REPO}" >/dev/null 2>&1
        if [ $? != 0 ] ; then
            echo "deb http://repo.mysql.com/apt/$OSNAME $OSVER mysql-${MYSQLVER}"  > "${MYSQL_REPO}"
        fi
    else 
        echo "deb http://repo.mysql.com/apt/$OSNAME $OSVER mysql-${MYSQLVER}"  > "${MYSQL_REPO}"  
    fi
    echoB "${FPACE} - Update packages"
    ${APT} update
    echoB "${FPACE} - Install Mysql"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password ${ROOTPASSWORD}"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password ${ROOTPASSWORD}"
    DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server > /dev/null 2>&1
    if [ $? != 0 ] ; then
        echoR "An error occured during installation of MYSQL. Please fix this error and try again."
        echoR "You may want to manually run the command 'apt-get -y -f --allow-unauthenticated install mysql-server' to check. Aborting installation!"
        exit 1
    fi
    echoB "${FPACE} - Start Mysql"
    service mysql start
}

function debian_install_percona
{
    echoB "${FPACE} - Install software properties"
    curl -sO https://repo.percona.com/apt/percona-release_latest.generic_all.deb
    silent ${APT} -y -f install gnupg2 lsb-release ./percona-release_latest.generic_all.deb

    echoB "${FPACE} - Update packages"
    ${APT} update
    echoB "${FPACE} - Install Percona"
    percona-release setup ps${PERCONAVER} > /dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install percona-server-server > /dev/null 2>&1
    if [ $? != 0 ] ; then
        echoR "An error occured during installation of Percona. Please fix this error and try again."
        echoR "You may want to manually run the command 'apt-get -y -f --allow-unauthenticated install percona-server' to check. Aborting installation!"
        exit 1
    fi
    echoB "${FPACE} - Start Percona"
    service mysql start
}    

function debian_install_unzip
{
    if [ ! -f /usr/bin/unzip ]; then
        echoB "${FPACE} - Install Unzip"
        apt update >/dev/null 2>&1
        apt-get install unzip -y >/dev/null 2>&1
    fi
}

function mk_owasp_dir
{
    echoB "${FPACE} - Create owasp dir"
    if [ -d ${OWASP_DIR} ] ; then
        rm -rf ${OWASP_DIR}
    fi
    mkdir -p ${OWASP_DIR}
    if [ ${?} -ne 0 ] ; then
        echo "Unable to create directory: ${OWASP_DIR}, exit!"
        exit 1
    fi
}

function enable_ols_modsec
{
    grep 'module mod_security {' ${WEBCF} >/dev/null 2>&1
    if [ ${?} -eq 0 ] ; then
        echoB "${FPACE} - Already configured for modsecurity."
    else
        echoB "${FPACE} - Enable modsecurity"
        sed -i "s=module cache=module mod_security {\nmodsecurity  on\
        \nmodsecurity_rules \`\nSecRuleEngine On\n\`\nmodsecurity_rules_file \
        ${OWASP_DIR}/${RULE_FILE}\n  ls_enabled              1\n}\
        \n\nmodule cache=" ${WEBCF}
    fi    
}

function disable_ols_modesec
{
    grep 'module mod_security {' ${WEBCF} >/dev/null 2>&1
    if [ ${?} -eq 0 ] ; then
        echo 'Disable modsecurity'
        fst_match_line 'module mod_security' ${WEBCF}
        lst_match_line ${FIRST_LINE_NUM} ${WEBCF} '}'
        sed -i "${FIRST_LINE_NUM},${LAST_LINE_NUM}d" ${WEBCF}
    else
        echo 'Already disabled for modsecurity'
    fi
    restart_lsws  
}

function backup_owasp
{
    if [ -d ${OWASP_DIR} ]; then
        echoY "Detect ${OWASP_DIR} folder exist, move to ${OWASP_DIR}.$(date +%F).bk"
        if [ -d ${OWASP_DIR}.$(date +%F).bk ]; then
            rm -rf ${OWASP_DIR}.$(date +%F).bk
        fi
        mv ${OWASP_DIR} ${OWASP_DIR}.$(date +%F).bk
    fi
}    

function install_owasp
{
    cd ${OWASP_DIR}
    echoB "${FPACE} - Download OWASP rules"
    wget -q https://github.com/coreruleset/coreruleset/archive/refs/tags/v${OWASP_V}.zip
    unzip -qq v${OWASP_V}.zip
    rm -f v${OWASP_V}.zip
    mv coreruleset-* ${CRS_DIR}
}

function centos_install_modsecurity
{
    ${YUM} -y install ols-modsecurity >/dev/null 2>&1
}

function debian_install_modsecurity
{
    ${APT} -y install ols-modsecurity >/dev/null 2>&1
}


function install_modsecurity
{
    if [ ! -f ${SERVER_ROOT}/modules/mod_security.so ]; then
        echoB "${FPACE} - Install Mod_security Package"
        if [ "$OSNAME" = "centos" ] ; then
            centos_install_modsecurity
        else
            debian_install_modsecurity
        fi
    fi
}

function configure_owasp
{
    echoB "${FPACE} - Config OWASP rules"
  
    cd ${OWASP_DIR}
    if [ -f ${CRS_DIR}/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example ]; then
        mv ${CRS_DIR}/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example ${CRS_DIR}/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
    fi
    if [ -f ${CRS_DIR}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example ]; then
        mv ${CRS_DIR}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example ${CRS_DIR}/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
    fi
    if [ -f "${RULE_FILE}" ]; then
        mv ${RULE_FILE} ${RULE_FILE}.bk
    fi
    echo 'include modsecurity.conf' >> ${RULE_FILE}
    if [ -f ${CRS_DIR}/crs-setup.conf.example ]; then
        mv ${CRS_DIR}/crs-setup.conf.example ${CRS_DIR}/crs-setup.conf
        echo "include ${CRS_DIR}/crs-setup.conf" >> ${RULE_FILE}
    fi    
    ALL_RULES="$(ls ${CRS_DIR}/rules/ | grep 'REQUEST-\|RESPONSE-')"
    echo "${ALL_RULES}"  | while read LINE; do echo "include ${CRS_DIR}/rules/${LINE}" >> ${RULE_FILE}; done
    echo 'SecRuleEngine On' > modsecurity.conf
    chown -R lsadm ${OWASP_DIR}
}

function centos_install_postfix
{
    if [ -z /usr/sbin/sendmail ]; then
        echoG 'Install Postfix'
        yum install postfix -y  > /dev/null 2>&1
    else
        echoG 'sendmail is already exist, skip!'
    fi    
}

function debian_install_postfix
{
    echoG 'Install Postfix'
    DEBIAN_FRONTEND='noninteractive' apt-get -y -o Dpkg::Options::='--force-confdef' \
    -o Dpkg::Options::='--force-confold' install postfix > /dev/null 2>&1
}

function install_postfix
{
    if [ "$OSNAME" = 'centos' ] ; then
        centos_install_postfix
    else
        debian_install_postfix
    fi
}

function install_mariadb
{
    echoG "Start Install MariaDB"
    if [ "$OSNAME" = 'centos' ] ; then
        centos_install_mariadb
    else
        debian_install_mariadb
    fi
    if [ $? != 0 ] ; then
        echoR "An error occured when starting the MariaDB service. "
        echoR "Please fix this error and try again. Aborting installation!"
        exit 1
    fi

    echoB "${FPACE} - Set MariaDB root"
    mysql -uroot -e "flush privileges;"
    mysqladmin -uroot password $ROOTPASSWORD
    if [ $? = 0 ] ; then
        CURROOTPASSWORD=$ROOTPASSWORD
    else
        #test it is the current password
        mysqladmin -uroot -p$ROOTPASSWORD password $ROOTPASSWORD
        if [ $? = 0 ] ; then
            #echoG "MySQL root password is $ROOTPASSWORD"
            CURROOTPASSWORD=$ROOTPASSWORD
        else
            echoR "Failed to set MySQL root password to $ROOTPASSWORD, it may already have a root password."
            printf '\033[31mInstallation must know the password for the next step.\033[0m'
            test_mysql_password

            if [ "$TESTPASSWORDERROR" = "1" ] ; then
                echoY "If you forget your password you may stop the mysqld service and run the following command to reset it,"
                echoY "mysqld_safe --skip-grant-tables &"
                echoY "mysql --user=root mysql"
                echoY "update user set Password=PASSWORD('new-password') where user='root'; flush privileges; exit; "
                echoR "Aborting installation."
                echo
                exit 1
            fi

            if [ "$CURROOTPASSWORD" != "$ROOTPASSWORD" ] ; then
                echoY "Current MySQL root password is $CURROOTPASSWORD, it will be changed to $ROOTPASSWORD."
                printf '\033[31mDo you still want to change it?[y/N]\033[0m '
                read answer
                echo

                if [ "$answer" != "Y" ] && [ "$answer" != "y" ] ; then
                    echoG "OK, MySQL root password not changed."
                    ROOTPASSWORD=$CURROOTPASSWORD
                else
                    mysqladmin -uroot -p$CURROOTPASSWORD password $ROOTPASSWORD
                    if [ $? = 0 ] ; then
                        echoG "OK, MySQL root password changed to $ROOTPASSWORD."
                    else
                        echoR "Failed to change MySQL root password, it is still $CURROOTPASSWORD."
                        ROOTPASSWORD=$CURROOTPASSWORD
                    fi
                fi
            fi
        fi
    fi
    save_db_root_pwd
    echoG "End Install MariaDB"
}

function install_mysql
{
    echoG "Start Install MySQL"
    if [ "$OSNAME" = 'centos' ] ; then
        centos_install_mysql
    else
        debian_install_mysql
    fi
    if [ $? != 0 ] ; then
        echoR "An error occured when starting the MySQL service. "
        echoR "Please fix this error and try again. Aborting installation!"
        exit 1
    fi

    echoB "${FPACE} - Set MySQL root"
    if [ "$OSNAME" = 'centos' ] ; then
        TMP_LOG_ROOT_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
        mysqladmin -uroot -p$TMP_LOG_ROOT_PASS password $ROOTPASSWORD 2>/dev/null
    fi        
    mysql -uroot -p${ROOTPASSWORD} -e 'status' >/dev/null 2>&1
    if [ $? = 0 ] ; then
        CURROOTPASSWORD=$ROOTPASSWORD
    else
        mysqladmin -uroot -p$ROOTPASSWORD password $ROOTPASSWORD 2>/dev/null
        if [ $? = 0 ] ; then
            CURROOTPASSWORD=$ROOTPASSWORD
        else
            echoR "Failed to set MySQL root password to $ROOTPASSWORD, it may already have a root password."
            printf '\033[31mInstallation must know the password for the next step.\033[0m'
            test_mysql_password

            if [ "$TESTPASSWORDERROR" = "1" ] ; then
                echoY "If you forget your password you may stop the mysqld service and run the following command to reset it,"
                echoY "mysqld_safe --skip-grant-tables &"
                echoY "mysql --user=root mysql"
                echoY "update user set Password=PASSWORD('new-password') where user='root'; flush privileges; exit; "
                echoR "Aborting installation."
                echo
                exit 1
            fi

            if [ "$CURROOTPASSWORD" != "$ROOTPASSWORD" ] ; then
                echoY "Current MySQL root password is $CURROOTPASSWORD, it will be changed to $ROOTPASSWORD."
                printf '\033[31mDo you still want to change it?[y/N]\033[0m '
                read answer
                echo

                if [ "$answer" != "Y" ] && [ "$answer" != "y" ] ; then
                    echoG "OK, MySQL root password not changed."
                    ROOTPASSWORD=$CURROOTPASSWORD
                else
                    mysqladmin -uroot -p$CURROOTPASSWORD password $ROOTPASSWORD
                    if [ $? = 0 ] ; then
                        echoG "OK, MySQL root password changed to $ROOTPASSWORD."
                    else
                        echoR "Failed to change MySQL root password, it is still $CURROOTPASSWORD."
                        ROOTPASSWORD=$CURROOTPASSWORD
                    fi
                fi
            fi
        fi
    fi
    save_db_root_pwd
    echoG "End Install MySQL"
}

function install_percona
{
    echoG "Start Install Percona"
    if [ "$OSNAME" = 'centos' ] ; then
        centos_install_percona
    else
        debian_install_percona
    fi
    if [ $? != 0 ] ; then
        echoR "An error occured when starting the Percona service. "
        echoR "Please fix this error and try again. Aborting installation!"
        exit 1
    fi
    echoB "${FPACE} - Set Percona root"
    if [ "$OSNAME" = 'centos' ] ; then
        TMP_LOG_ROOT_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
        mysqladmin -uroot -p$TMP_LOG_ROOT_PASS password $ROOTPASSWORD 2>/dev/null
    fi        
    mysql -uroot -p${ROOTPASSWORD} -e 'status' >/dev/null 2>&1
    if [ $? = 0 ] ; then
        CURROOTPASSWORD=$ROOTPASSWORD
    else
        mysqladmin -uroot -p$ROOTPASSWORD password $ROOTPASSWORD 2>/dev/null
        if [ $? = 0 ] ; then
            CURROOTPASSWORD=$ROOTPASSWORD
        else
            echoR "Failed to set MySQL root password to $ROOTPASSWORD, it may already have a root password."
            printf '\033[31mInstallation must know the password for the next step.\033[0m'
            test_mysql_password

            if [ "$TESTPASSWORDERROR" = "1" ] ; then
                echoY "If you forget your password you may stop the mysqld service and run the following command to reset it,"
                echoY "mysqld_safe --skip-grant-tables &"
                echoY "mysql --user=root mysql"
                echoY "update user set Password=PASSWORD('new-password') where user='root'; flush privileges; exit; "
                echoR "Aborting installation."
                echo
                exit 1
            fi

            if [ "$CURROOTPASSWORD" != "$ROOTPASSWORD" ] ; then
                echoY "Current Percona root password is $CURROOTPASSWORD, it will be changed to $ROOTPASSWORD."
                printf '\033[31mDo you still want to change it?[y/N]\033[0m '
                read answer
                echo

                if [ "$answer" != "Y" ] && [ "$answer" != "y" ] ; then
                    echoG "OK, Percona root password not changed."
                    ROOTPASSWORD=$CURROOTPASSWORD
                else
                    mysqladmin -uroot -p$CURROOTPASSWORD password $ROOTPASSWORD
                    if [ $? = 0 ] ; then
                        echoG "OK, Percona root password changed to $ROOTPASSWORD."
                    else
                        echoR "Failed to change Percona root password, it is still $CURROOTPASSWORD."
                        ROOTPASSWORD=$CURROOTPASSWORD
                    fi
                fi
            fi
        fi
    fi
    save_db_root_pwd
    echoG "End Install Percona"

}    

function setup_mariadb_user
{
    echoG "Start setup MariaDB"
    local ERROR=
    #delete user if exists
    mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';"

    echo `mysql -uroot -p$ROOTPASSWORD -e "SELECT user FROM mysql.user"` | grep "$USERNAME" >/dev/null
    if [ $? = 0 ] ; then
        echoG "user $USERNAME exists in mysql.user"
    else
        mysql -uroot -p$ROOTPASSWORD  -e "CREATE USER $USERNAME@localhost IDENTIFIED BY '$USERPASSWORD';"
        if [ $? = 0 ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO '$USERNAME'@localhost IDENTIFIED BY '$USERPASSWORD';"
        else
            echoR "Failed to create MySQL user $USERNAME. This user may already exist. If it does not, another problem occured."
            echoR "Please check this and update the wp-config.php file."
            ERROR="Create user error"
        fi
    fi

    mysql -uroot -p$ROOTPASSWORD  -e "CREATE DATABASE IF NOT EXISTS $DATABASENAME;"
    if [ $? = 0 ] ; then
        mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON $DATABASENAME.* TO '$USERNAME'@localhost IDENTIFIED BY '$USERPASSWORD';"
    else
        echoR "Failed to create database $DATABASENAME. It may already exist. If it does not, another problem occured."
        echoR "Please check this and update the wp-config.php file."
        if [ "x$ERROR" = "x" ] ; then
            ERROR="Create database error"
        else
            ERROR="$ERROR and create database error"
        fi
    fi
    mysql -uroot -p$ROOTPASSWORD  -e "flush privileges;"

    if [ "x$ERROR" = "x" ] ; then
        echoG "Finished MySQL setup without error."
    else
        echoR "Finished MySQL setup - some error(s) occured."
    fi
    save_db_user_pwd
    echoG "End setup mysql"
}

function setup_mysql_user
{
    echoG "Start setup MySQL"
    local ERROR=
    #delete user if exists
    mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';" 2>/dev/null

    echo `mysql -uroot -p$ROOTPASSWORD -e "SELECT user FROM mysql.user" 2>/dev/null` | grep "$USERNAME" >/dev/null
    if [ $? = 0 ] ; then
        echoG "user $USERNAME exists in mysql.user"
    else
        mysql -uroot -p$ROOTPASSWORD  -e "CREATE USER $USERNAME@localhost IDENTIFIED BY '$USERPASSWORD';" 2>/dev/null
        if [ $? = 0 ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO '$USERNAME'@localhost;" 2>/dev/null
        else
            echoR "Failed to create MySQL user $USERNAME. This user may already exist. If it does not, another problem occured."
            echoR "Please check this and update the wp-config.php file."
            ERROR="Create user error"
        fi
    fi

    mysql -uroot -p$ROOTPASSWORD  -e "CREATE DATABASE IF NOT EXISTS $DATABASENAME;" 2>/dev/null
    if [ $? = 0 ] ; then
        mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON $DATABASENAME.* TO '$USERNAME'@localhost;" 2>/dev/null
    else
        echoR "Failed to create database $DATABASENAME. It may already exist. If it does not, another problem occured."
        echoR "Please check this and update the wp-config.php file."
        if [ "x$ERROR" = "x" ] ; then
            ERROR="Create database error"
        else
            ERROR="$ERROR and create database error"
        fi
    fi
    mysql -uroot -p$ROOTPASSWORD  -e "flush privileges;" 2>/dev/null

    if [ "x$ERROR" = "x" ] ; then
        echoG "Finished MySQL setup without error."
    else
        echoR "Finished MySQL setup - some error(s) occured."
    fi
    save_db_user_pwd
    echoG "End setup mysql"
}

function setup_percona_user
{
    echoG "Start setup Percona"
    local ERROR=
    #delete user if exists
    mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';" 2>/dev/null

    echo `mysql -uroot -p$ROOTPASSWORD -e "SELECT user FROM mysql.user" 2>/dev/null` | grep "$USERNAME" >/dev/null
    if [ $? = 0 ] ; then
        echoG "user $USERNAME exists in mysql.user"
    else
        mysql -uroot -p$ROOTPASSWORD  -e "CREATE USER $USERNAME@localhost IDENTIFIED BY '$USERPASSWORD';" 2>/dev/null
        if [ $? = 0 ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON *.* TO '$USERNAME'@localhost;" 2>/dev/null
        else
            echoR "Failed to create MySQL user $USERNAME. This user may already exist. If it does not, another problem occured."
            echoR "Please check this and update the wp-config.php file."
            ERROR="Create user error"
        fi
    fi

    mysql -uroot -p$ROOTPASSWORD  -e "CREATE DATABASE IF NOT EXISTS $DATABASENAME;" 2>/dev/null
    if [ $? = 0 ] ; then
        mysql -uroot -p$ROOTPASSWORD  -e "GRANT ALL PRIVILEGES ON $DATABASENAME.* TO '$USERNAME'@localhost;" 2>/dev/null
    else
        echoR "Failed to create database $DATABASENAME. It may already exist. If it does not, another problem occured."
        echoR "Please check this and update the wp-config.php file."
        if [ "x$ERROR" = "x" ] ; then
            ERROR="Create database error"
        else
            ERROR="$ERROR and create database error"
        fi
    fi
    mysql -uroot -p$ROOTPASSWORD  -e "flush privileges;" 2>/dev/null

    if [ "x$ERROR" = "x" ] ; then
        echoG "Finished Percona setup without error."
    else
        echoR "Finished Percona setup - some error(s) occured."
    fi
    save_db_user_pwd
    echoG "End setup Percona"

}    

function resetmysqlroot
{
    if [ "x$OSNAMEVER" = "xCENTOS8" ]; then
        MYSQLNAME='mariadb'
    else
        MYSQLNAME=mysql
    fi
    service $MYSQLNAME stop
    if [ $? != 0 ] && [ "x$OSNAME" = "xcentos" ] ; then
        service $MYSQLNAME stop
    fi

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
    if [ "$MYSQLINSTALLED" != "1" ] ; then
        echoY "MySQL-server not installed."
    else
        local ERROR=0
        test_mysql_password

        if [ "$TESTPASSWORDERROR" = "1" ] ; then
            echoR "Failed to purge database."
            echo
            ERROR=1
            ALLERRORS=1
        else
            ROOTPASSWORD=$CURROOTPASSWORD
        fi

        if [ "$ERROR" = "0" ] ; then
            mysql -uroot -p$ROOTPASSWORD  -e "DELETE FROM mysql.user WHERE User = '$USERNAME@localhost';"
            mysql -uroot -p$ROOTPASSWORD  -e "DROP DATABASE IF EXISTS $DATABASENAME;"
            echoY "Database purged."
        fi
    fi
}

function save_db_root_pwd
{
    echo "mysql root password is [$ROOTPASSWORD]." >> ${PWD_FILE}
}

function save_db_user_pwd
{
    echo "mysql WordPress DataBase name is [$DATABASENAME], username is [$USERNAME], password is [$USERPASSWORD]." >> ${PWD_FILE}
}

function pure_mariadb
{
    if [ "$MYSQLINSTALLED" = "0" ] ; then
        install_mariadb
        ROOTPASSWORD=$CURROOTPASSWORD
    else
        echoG 'MariaDB already exist, skip!'
    fi
}

function pure_mysql
{
    if [ "$MYSQLINSTALLED" = "0" ] ; then
        install_mysql
        ROOTPASSWORD=$CURROOTPASSWORD
    else
        echoG 'MySQL already exist, skip!'
    fi
}

function pure_percona
{
    if [ "$MYSQLINSTALLED" = "0" ] ; then
        install_percona
        ROOTPASSWORD=$CURROOTPASSWORD
    else
        echoG 'PERCONA already exist, skip!'
    fi
}

function uninstall_result
{
    if [ "$ALLERRORS" != "0" ] ; then
        echoY "Some error(s) occured. Please check these as you may need to manually fix them."
    fi
    echoCYAN 'End OpenLiteSpeed one click Uninstallation << << << << << << <<'
}


function install_openlitespeed
{
    echoG "Start setup OpenLiteSpeed"
    local STATUS=Install
    if [ "$OLSINSTALLED" = "1" ] ; then
        OLS_VERSION=$(cat "$SERVER_ROOT"/VERSION)
        wget -qO "$SERVER_ROOT"/release.tmp  http://open.litespeedtech.com/packages/release?ver=$OLS_VERSION
        LATEST_VERSION=$(cat "$SERVER_ROOT"/release.tmp)
        rm "$SERVER_ROOT"/release.tmp
        if [ "$OLS_VERSION" = "$LATEST_VERSION" ] ; then
            STATUS=Reinstall
            echoY "OpenLiteSpeed is already installed with the latest version, will attempt to reinstall it."
        else
            STATUS=Update
            echoY "OpenLiteSpeed is already installed and newer version is available, will attempt to update it."
        fi
    fi

    if [ "$OSNAME" = "centos" ] ; then
        install_ols_centos $STATUS
    else
        install_ols_debian $STATUS
    fi
    silent killall -9 lsphp
    echoG "End setup OpenLiteSpeed"
}

function install_unzip
{
    if [ "$OSNAME" = "centos" ] ; then
        centos_install_unzip
    else
        debian_install_unzip
    fi
}

function gen_selfsigned_cert
{
    if [ -e $CONFFILE ] ; then
        source $CONFFILE 2>/dev/null
        if [ $? != 0 ]; then
            . $CONFFILE
        fi
    fi

    SSL_COUNTRY="${SSL_COUNTRY:-US}"
    SSL_STATE="${SSL_STATE:-New Jersey}"
    SSL_LOCALITY="${SSL_LOCALITY:-Virtual}"
    SSL_ORG="${SSL_ORG:-LiteSpeedCommunity}"
    SSL_ORGUNIT="${SSL_ORGUNIT:-Testing}"
    SSL_HOSTNAME="${SSL_HOSTNAME:-webadmin}"
    SSL_EMAIL="${SSL_EMAIL:-.}"
    COMMNAME=$(hostname)
    
    cat << EOF > $CSR
[req]
prompt=no
distinguished_name=openlitespeed
[openlitespeed]
commonName = ${COMMNAME}
countryName = ${SSL_COUNTRY}
localityName = ${SSL_LOCALITY}
organizationName = ${SSL_ORG}
organizationalUnitName = ${SSL_ORGUNIT}
stateOrProvinceName = ${SSL_STATE}
emailAddress = ${SSL_EMAIL}
name = openlitespeed
initials = CP
dnQualifier = openlitespeed
[server_exts]
extendedKeyUsage=1.3.6.1.5.5.7.3.1
EOF
    openssl req -x509 -config $CSR -extensions 'server_exts' -nodes -days 820 -newkey rsa:2048 -keyout ${KEY} -out ${CERT} >/dev/null 2>&1
    rm -f $CSR
    
    mv ${KEY}   $SERVER_ROOT/conf/$KEY
    mv ${CERT}  $SERVER_ROOT/conf/$CERT
    chmod 0600 $SERVER_ROOT/conf/$KEY
    chmod 0600 $SERVER_ROOT/conf/$CERT
}


function set_ols_password
{
    ENCRYPT_PASS=`"$SERVER_ROOT/admin/fcgi-bin/admin_php" -q "$SERVER_ROOT/admin/misc/htpasswd.php" $ADMINPASSWORD`
    if [ $? = 0 ] ; then
        echo "${ADMINUSER}:$ENCRYPT_PASS" > "$SERVER_ROOT/admin/conf/htpasswd"
        if [ $? = 0 ] ; then
            echoG "Set OpenLiteSpeed Web Admin access."
        else
            echoG "OpenLiteSpeed WebAdmin password not changed."
        fi
    fi
}

function config_server
{
    echoB "${FPACE} - Config OpenLiteSpeed"
    if [ "$INSTALLWORDPRESS" != "1" ]; then 
        if [ -e "${WEBCF}" ] ; then
            sed -i -e "s/adminEmails/adminEmails $EMAIL\n#adminEmails/" "${WEBCF}"
            sed -i -e "s/8088/$WPPORT/" "${WEBCF}"
            sed -i -e "s/ls_enabled/ls_enabled   1\n#/" "${WEBCF}"

            cat >> ${WEBCF} <<END

listener Defaultssl {
address                 *:$SSLWPPORT
secure                  1
map                     Example *
keyFile                 $SERVER_ROOT/conf/$KEY
certFile                $SERVER_ROOT/conf/$CERT
}

END
            chown -R lsadm:lsadm $SERVER_ROOT/conf/
        else
            echoR "${WEBCF} is missing. It appears that something went wrong during OpenLiteSpeed installation."
            ALLERRORS=1
        fi
        echo ols1clk > "$SERVER_ROOT/PLAT"
    fi
    if [ ${PROXY} = '1' ]; then
        cat >> ${WEBCF} <<END
extprocessor proxy-http {
  type                    proxy
  address                 ${PROXY_SERVER}
  maxConns                100
  initTimeout             60
  retryTimeout            0
  respBuffer              0
}
END
    fi
    sed -i s"|lsphp.*/bin/lsphp|lsphp${LSPHPVER}/bin/lsphp|g" ${WEBCF}

    if [ ${ADMINPORT} != 7080 ]; then
        config_admin_port
    fi
}

function config_vh_wp
{
    echoG 'Start setup virtual host config'
    if [ -e "${WEBCF}" ] ; then
        cat ${WEBCF} | grep "virtualhost wordpress" >/dev/null
        if [ $? != 0 ] ; then
            sed -i -e "s/adminEmails/adminEmails $EMAIL\n#adminEmails/" "${WEBCF}"
            sed -i -e "s/ls_enabled/ls_enabled   1\n#/" "${WEBCF}"

            VHOSTCONF=$SERVER_ROOT/conf/vhosts/wordpress/vhconf.conf
            echoB "${FPACE} - Check existing port"
            grep "address.*:${WPPORT}$\|${SSLWPPORT}$"  ${WEBCF} >/dev/null 2>&1
            if [ ${?} = 0 ]; then
                echoY "Detect port ${WPPORT} || ${SSLWPPORT}, will skip domain setup!"
            else   
                echoB "${FPACE} - Create wordpress listener"  
                cat >> ${WEBCF} <<END

listener wordpress {
address                 *:$WPPORT
secure                  0
map                     wordpress $SITEDOMAIN
}


listener wordpressssl {
address                 *:$SSLWPPORT
secure                  1
map                     wordpress $SITEDOMAIN
keyFile                 $SERVER_ROOT/conf/$KEY
certFile                $SERVER_ROOT/conf/$CERT
}

END
            fi
            echoB "${FPACE} - Insert wordpress virtual host"  
            cat >> ${WEBCF} <<END

virtualhost wordpress {
vhRoot                  $WORDPRESSPATH
configFile              $VHOSTCONF
allowSymbolLink         1
enableScript            1
restrained              0
setUIDMode              2
}
END
            echoB "${FPACE} - Create wordpress virtual host conf"
            mkdir -p $SERVER_ROOT/conf/vhosts/wordpress/
            cat > $VHOSTCONF <<END
docRoot                   \$VH_ROOT/
index  {
  useServer               0
  indexFiles              index.php
}

context / {
  location                \$VH_ROOT
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                1
    inherit               1
    rewriteFile           $WORDPRESSPATH/.htaccess
  }
}

rewrite  {
  enable                  1
  autoLoadHtaccess        1
}

END
            chown -R lsadm:lsadm $SERVER_ROOT/conf/
        else 
            echoY "${FPACE} - Detect wordpress exist, will skip virtual host conf setup!"
        fi
    else
        echoR "${WEBCF} is missing. It appears that something went wrong during OpenLiteSpeed installation."
        ALLERRORS=1
    fi
    echo ols1clk > "$SERVER_ROOT/PLAT"
    echoG 'End setup virtual host config'
}

function config_admin_port
{
    echoG 'Start updating web admin port number'
    if [ -e ${SERVER_ROOT}/admin/conf/admin_config.conf ]; then 
        sed -i "s/7080/${ADMINPORT}/g" ${SERVER_ROOT}/admin/conf/admin_config.conf
    else
        echoR "${SERVER_ROOT}/admin/conf/admin_config.conf is not found, skip!"
    fi        
}


function activate_cache
{
    cat >> $WORDPRESSPATH/activate_cache.php <<END
<?php
include '$WORDPRESSPATH/wp-load.php';
include_once '$WORDPRESSPATH/wp-admin/includes/plugin.php';
include_once '$WORDPRESSPATH/wp-admin/includes/file.php';
define('WP_ADMIN', true);
activate_plugin('litespeed-cache/litespeed-cache.php', '', false, false);

END
    $SERVER_ROOT/fcgi-bin/lsphpnew $WORDPRESSPATH/activate_cache.php
    rm $WORDPRESSPATH/activate_cache.php
}

function set_proxy_vh
{
    if [ ${PROXY} = '1' ]; then
        echoG 'Set proxy in Example virtual host config.'
        if [ ${PROXY_TYPE} = 'r' ]; then 
            proxy_vh_rewrite
        elif [ ${PROXY_TYPE} = 'c' ]; then 
            proxy_vh_context
        else
            echoY "PROXY_TYPE: ${PROXY_TYPE} is not found, will use rewrite type!"
            proxy_vh_rewrite
        fi    
    fi
}

function proxy_vh_rewrite
{
    sed -i 's/enable[[:blank:]]*0$/enable                  1/g' ${EXAMPLE_VHOSTCONF}
    sed -i '/^rewrite.*/a \ \ rules                   REWRITERULE ^(.*)$ HTTP://proxy-http/$1 [P,L,E=PROXY-HOST:WWW.EXAMPLE.COM]' ${EXAMPLE_VHOSTCONF}
}

function proxy_vh_context
{
    sed -i 's|context / {|context /static/ {|g' ${EXAMPLE_VHOSTCONF}
    cat >> ${EXAMPLE_VHOSTCONF} <<END
context / {
  type                    proxy
  handler                 proxy-http
  addDefaultCharset       off
}
END
}

function check_cur_status
{
    if [ -e $SERVER_ROOT/bin/openlitespeed ] ; then
        OLSINSTALLED=1
    else
        OLSINSTALLED=0
    fi

    which mysqladmin  >/dev/null 2>&1
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
    echoY "Finished setting OpenLiteSpeed WebAdmin password to $ADMINPASSWORD."
}


function uninstall
{
    if [ "$OLSINSTALLED" = "1" ] ; then
        echoB "${FPACE} - Stop OpenLiteSpeed"
        silent $SERVER_ROOT/bin/lswsctrl stop
        echoB "${FPACE} - Stop LSPHP"
        silent killall -9 lsphp
        if [ "$OSNAME" = "centos" ] ; then
            uninstall_php_centos
            uninstall_ols_centos
        else
            uninstall_php_debian
            uninstall_ols_debian 
        fi
        echoG Uninstalled.
    else
        echoY "OpenLiteSpeed not installed."
    fi
}

function read_password
{
    if [ "$1" != "" ] ; then
        TEMPPASSWORD=$1
    else
        passwd=
        echoY "Please input password for $2(press enter to get a random one):"
        read passwd
        if [ "$passwd" = "" ] ; then
            TEMPPASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo '')
        else
            TEMPPASSWORD=$passwd
        fi
    fi
}


function check_dbversion_param
{
    if [ "$OSNAMEVER" = "DEBIAN8" ] || [ "$OSNAMEVER" = "UBUNTU14" ] || [ "$OSNAMEVER" = "UBUNTU16" ]; then
        if [ "$MARIADBVER" != '10.2' -o "$MARIADBVER" != '10.3' -o "$MARIADBVER" != '10.4' -o "$MARIADBVER" != '10.5'] ; then 
            echoY "We do not support "$MARIADBVER" on $OSNAMEVER, 10.5 will be used instead."
            MARIADBVER=10.5
        fi                 
    fi
}


function check_value_follow
{
    FOLLOWPARAM=$1
    local PARAM=$1
    local KEYWORD=$2

    if [ "$1" = "-n" ] || [ "$1" = "-e" ] || [ "$1" = "-E" ] ; then
        FOLLOWPARAM=
    else
        local PARAMCHAR=$(echo $1 | awk '{print substr($0,1,1)}')
        if [ "$PARAMCHAR" = "-" ] ; then
            FOLLOWPARAM=
        fi
    fi

    if [ -z "$FOLLOWPARAM" ] ; then
        if [ ! -z "$KEYWORD" ] ; then
            echoR "Error: '$PARAM' is not a valid '$KEYWORD', please check and try again."
            usage
        fi
    fi
}


function fixLangTypo
{
    WP_LOCALE="af ak sq am ar hy rup_MK as az az_TR ba eu bel bn_BD bs_BA bg_BG my_MM ca bal zh_CN \
      zh_HK zh_TW co hr cs_CZ da_DK dv nl_NL nl_BE en_US en_AU 	en_CA en_GB eo et fo fi fr_BE fr_FR \
      fy fuc gl_ES ka_GE de_DE de_CH el gn gu_IN haw_US haz he_IL hi_IN hu_HU is_IS ido id_ID ga it_IT \
      ja jv_ID kn kk km kin ky_KY ko_KR ckb lo lv li lin lt_LT lb_LU mk_MK mg_MG ms_MY ml_IN mr xmf mn \
      me_ME ne_NP nb_NO nn_NO ory os ps fa_IR fa_AF pl_PL pt_BR pt_PT pa_IN rhg ro_RO ru_RU ru_UA rue \
      sah sa_IN srd gd sr_RS sd_PK si_LK sk_SK sl_SI so_SO azb es_AR es_CL es_CO es_MX es_PE es_PR es_ES \
      es_VE su_ID sw sv_SE gsw tl tg tzm ta_IN ta_LK tt_RU te th bo tir tr_TR tuk ug_CN uk ur uz_UZ vi \
      wa cy yor"
    LANGSTR=$(echo "$WPLANGUAGE" | awk '{print tolower($0)}')
    if [ "$LANGSTR" = "zh_cn" ] || [ "$LANGSTR" = "zh-cn" ] || [ "$LANGSTR" = "cn" ] ; then
        WPLANGUAGE=zh_CN
    fi

    if [ "$LANGSTR" = "zh_tw" ] || [ "$LANGSTR" = "zh-tw" ] || [ "$LANGSTR" = "tw" ] ; then
        WPLANGUAGE=zh_TW
    fi
    echo ${WP_LOCALE} | grep -w "${WPLANGUAGE}" -q
    if [ ${?} != 0 ]; then 
        echoR "${WPLANGUAGE} language not found." 
        echo "Please check $WP_LOCALE"
        exit 1
    fi
}

function updatemyself
{
    local CURMD=$(md5sum "$0" | cut -d' ' -f1)
    local SERVERMD=$(md5sum  <(wget $MYGITHUBURL -O- 2>/dev/null)  | cut -d' ' -f1)
    if [ "$CURMD" = "$SERVERMD" ] ; then
        echoG "You already have the latest version installed."
    else
        wget -O "$0" $MYGITHUBURL
        CURMD=$(md5sum "$0" | cut -d' ' -f1)
        if [ "$CURMD" = "$SERVERMD" ] ; then
            echoG "Updated."
        else
            echoG "Tried to update but seems to be failed."
        fi
    fi
    exit 0
}

function uninstall_warn
{
    if [ "$FORCEYES" != "1" ] ; then
        echo
        printf "\033[31mAre you sure you want to uninstall? Type 'Y' to continue, otherwise will quit.[y/N]\033[0m "
        read answer
        echo

        if [ "$answer" != "Y" ] && [ "$answer" != "y" ] ; then
            echoG "Uninstallation aborted!"
            exit 0
        fi
        echo 
    fi
    echoCYAN 'Start OpenLiteSpeed one click Uninstallation >> >> >> >> >> >> >>'
}

function befor_install_display
{
    echo
    echoCYAN "Starting to install OpenLiteSpeed to $SERVER_ROOT/ with the parameters below,"
    echoY "WebAdmin Console URL:     " "https://$(curl -s http://checkip.amazonaws.com || printf "0.0.0.0"):$ADMINPORT"
    echoY "WebAdmin username:        " "$ADMINUSER"
    echoY "WebAdmin password:        " "$ADMINPASSWORD"
    echoY "WebAdmin email:           " "$EMAIL"
    echoY "LSPHP version:            " "$LSPHPVER"
    if [ ${WITH_MYSQL} = 0 ] && [ "${PURE_MYSQL}" = 0 ] && [ "${WITH_PERCONA}" = 0 ] && [ "${PURE_PERCONA}" = 0 ] && [ "${PURE_DB}" = 0 ]; then 
        if [ ${INSTALLWORDPRESS} = 1 ]; then
            echoY "MariaDB version:          " "$MARIADBVER"
        fi
    elif [ "${PURE_DB}" = 1 ]; then
        echoY "MariaDB version:          " "$MARIADBVER"
        echoY "MariaDB root Password:    " "$ROOTPASSWORD"    
    elif [ "${PURE_MYSQL}" = 1 ]; then 
        echoY "MySQL version:            " "$MYSQLVER"
        echoY "MySQL root Password:      " "$ROOTPASSWORD"
    elif [ "${PURE_PERCONA}" = 1 ]; then 
        echoY "PERCONA version:          " "$PERCONAVER"
        echoY "PERCONA root Password:    " "$ROOTPASSWORD"        
    elif [ "${WITH_PERCONA}" = 1 ]; then 
        echoY "PERCONA version:          " "$PERCONAVER"     
    elif [ "${WITH_MYSQL}" = 1 ]; then   
        echoY "MySQL version:            " "$MYSQLVER"
    fi

    if [ "$INSTALLWORDPRESS" = "1" ] ; then
        echoY "Install WordPress:        " Yes
        echoY "WordPress HTTP port:      " "$WPPORT"
        echoY "WordPress HTTPS port:     " "$SSLWPPORT"
        echoY "WordPress language:       " "$WPLANGUAGE"        
        echoY "Web site domain:          " "$SITEDOMAIN"
        echoY "MySQL root Password:      " "$ROOTPASSWORD"
        echoY "Database name:            " "$DATABASENAME"
        echoY "Database username:        " "$USERNAME"
        echoY "Database password:        " "$USERPASSWORD"

        if [ "$INSTALLWORDPRESSPLUS" = "1" ] ; then
            echoY "WordPress plus:           " Yes
            echoY "WordPress site title:     " "$WPTITLE"
            echoY "WordPress username:       " "$WPUSER"
            echoY "WordPress password:       " "$WPPASSWORD"
        else
            echoY "WordPress plus:           " No
        fi


        if [ -e "$WORDPRESSPATH/wp-config.php" ] ; then
            echoY "WordPress location:       " "$WORDPRESSPATH (Exsiting)"
            WORDPRESSINSTALLED=1
        else
            echoY "WordPress location:       " "$WORDPRESSPATH (New install)"
            WORDPRESSINSTALLED=0
        fi
    else
        echoY "Server HTTP port:         " "$WPPORT"
        echoY "Server HTTPS port:        " "$SSLWPPORT"
    fi
    echoNW "Your password will be written to file:  ${PWD_FILE}"
    echo 
    if [ "$FORCEYES" != "1" ] ; then
        printf 'Are these settings correct? Type n to quit, otherwise will continue. [Y/n]  '
        read answer
        if [ "$answer" = "N" ] || [ "$answer" = "n" ] ; then
            echoG "Aborting installation!"
            exit 0
        fi
    fi  
    echo
    echoCYAN 'Start OpenLiteSpeed one click installation >> >> >> >> >> >> >>'
}

function main_owasp
{
    if [ "${SET_OWASP}" = 'ON' ]; then
        echoG "Start Enable OWASP"
        backup_owasp
        mk_owasp_dir
        install_unzip
        install_owasp
        install_modsecurity
        configure_owasp
        enable_ols_modsec
        restart_lsws
        echoG "End Enable OWASP"
    fi
}

function install_wp_cli
{
    if [ -e /usr/local/bin/wp ] || [ -e /usr/bin/wp ]; then 
        echoG 'WP CLI already exist'
    else    
        echoG "Install wp_cli"
        curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        echo $PATH | grep '/usr/local/bin' >/dev/null 2>&1
        if [ ${?} = 0 ]; then
            mv wp-cli.phar /usr/local/bin/wp
        else
            mv wp-cli.phar /usr/bin/wp
        fi    
    fi
    if [ ! -e /usr/bin/php ] && [ ! -L /usr/bin/php ]; then
        ln -s ${SERVER_ROOT}/lsphp${LSPHPVER}/bin/php /usr/bin/php
    elif [ ! -e /usr/bin/php ]; then 
        rm -f /usr/bin/php
        ln -s ${SERVER_ROOT}/lsphp${LSPHPVER}/bin/php /usr/bin/php    
    else 
        echoG '/usr/bin/php symlink exist, skip symlink.'    
    fi
}

function main_pure_db
{
    if [ "${PURE_DB}" = '1' ]; then 
        echoG 'Install MariaDB only'
        pure_mariadb
    elif [ "${PURE_MYSQL}" = '1' ]; then 
        echoG 'Install MySQL only'
        pure_mysql
    elif [ "${PURE_PERCONA}" = '1' ]; then
        echoG 'Install Percona only'
        pure_percona
    fi    
}

function main_install_wordpress
{
    if [ "${PURE_DB}" = '1' ] || [ "${PURE_MYSQL}" = '1' ] || [ "${PURE_PERCONA}" = '1' ]; then 
        echoG 'Skip WordPress setup.'
    else
        if [ "$WORDPRESSINSTALLED" = '1' ] ; then
            echoY 'Skip WordPress installation!'
        else
            if [ "$INSTALLWORDPRESS" = "1" ] ; then
                install_wp_cli
                config_vh_wp
                check_port_usage
                if [ "$MYSQLINSTALLED" != "1" ] ; then
                    if [ "${WITH_MYSQL}" = '1' ]; then 
                        install_mysql
                    elif [ "${WITH_PERCONA}" = '1' ]; then 
                        install_percona                      
                    else
                        install_mariadb
                    fi
                else
                    test_mysql_password
                fi
                if [ "$TESTPASSWORDERROR" = "1" ] ; then
                    echoY "MySQL setup bypassed, can not get root password."
                else
                    ROOTPASSWORD=$CURROOTPASSWORD
                    if [ "${WITH_MYSQL}" = '1' ]; then
                        setup_mysql_user
                    elif [ "${WITH_PERCONA}" = '1' ]; then
                        setup_percona_user                        
                    else 
                        setup_mariadb_user
                    fi    
                fi
                download_wordpress
                create_wordpress_cf
                if [ "$INSTALLWORDPRESSPLUS" = "1" ] ; then            
                    install_wordpress_core
                    echo "WordPress administrator username is [$WPUSER], password is [$WPPASSWORD]." >> ${PWD_FILE} 
                fi
                change_owner ${WORDPRESSPATH}
                install_postfix
            fi
        fi 
    fi    
}

function check_port_usage
{
    if [ "$WPPORT" = "80" ] || [ "$SSLWPPORT" = "443" ]; then
        echoG "Avoid port 80/443 conflict."
        killall -9 apache  >/dev/null 2>&1
        killall -9 apache2  >/dev/null 2>&1
        killall -9 httpd    >/dev/null 2>&1
        killall -9 nginx    >/dev/null 2>&1
    fi
}

function after_install_display
{
    chmod 600 "${PWD_FILE}"
    if [ "$ALLERRORS" = "0" ] ; then
        echoG "Congratulations! Installation finished."
    else
        echoY "Installation finished. Some errors seem to have occured, please check this as you may need to manually fix them."
    fi
    if [ "$INSTALLWORDPRESSPLUS" = "0" ] && [ "$INSTALLWORDPRESS" = "1" ] && [ "${PURE_DB}" = '0' ] && [ "${PURE_MYSQL}" = '0' ]; then
        echo "Please access http://server_IP:$WPPORT/ to finish setting up your WordPress site."
        echo "Also, you may want to activate the LiteSpeed Cache plugin to get better performance."
    fi
    if [ "${PROXY_TYPE}" = 'r' ]; then
        echo "Please substitute the Default proxy address [${PROXY_SERVER}] and domain [WWW.EXAMPLE.COM] with your own value. More,"
        echoB "https://docs.openlitespeed.org/docs/advanced/proxy"
    elif [ "${PROXY_TYPE}" = 'c' ]; then
        echo "Please substitute the Default proxy address [${PROXY_SERVER}] with your own value."
        echo "More, https://docs.openlitespeed.org/docs/advanced/proxy"
    fi
    echoCYAN 'End OpenLiteSpeed one click installation << << << << << << <<'
    echo
}

function test_page
{
    local URL=$1
    local KEYWORD=$2
    local PAGENAME=$3
    curl -skL  $URL | grep -i "$KEYWORD" >/dev/null 2>&1
    if [ $? != 0 ] ; then
        echoR "Error: $PAGENAME failed."
        TESTGETERROR=yes
    else
        echoG "OK: $PAGENAME passed."
    fi
}

function test_ols_admin
{
    test_page https://localhost:${ADMINPORT}/ "LiteSpeed WebAdmin" "test webAdmin page"
}

function test_ols
{
    if [ ${PROXY} = 0 ]; then
        test_page http://localhost:$WPPORT/  Congratulation "test Example HTTP vhost page"
        test_page https://localhost:$SSLWPPORT/  Congratulation "test Example HTTPS vhost page"
    else
        echoG 'Proxy is on, skip the test!'
    fi    
}

function test_wordpress
{
    if [ ${PROXY} = 0 ]; then
        test_page http://localhost:8088/  Congratulation "test Example vhost page"
    else
        echoG 'Proxy is on, skip the test!'
    fi      
    test_page http://localhost:$WPPORT/ "WordPress" "test wordpress HTTP first page"
    test_page https://localhost:$SSLWPPORT/ "WordPress" "test wordpress HTTPS first page"
}

function test_wordpress_plus
{
    if [ ${PROXY} = 0 ]; then
        test_page http://localhost:8088/  Congratulation "test Example vhost page"
    else
        echoG 'Proxy is on, skip the test!'
    fi        
    test_page "http://$SITEDOMAIN:$WPPORT/ --resolve $SITEDOMAIN:$WPPORT:127.0.0.1" WordPress "test wordpress HTTP first page"
    test_page "https://$SITEDOMAIN:$SSLWPPORT/ --resolve $SITEDOMAIN:$SSLWPPORT:127.0.0.1" WordPress "test wordpress HTTPS first page"
}


function main_ols_test
{
    echoCYAN "Start auto testing >> >> >> >>"
    test_ols_admin
    if [ "${PURE_DB}" = '1' ] || [ "${PURE_MYSQL}" = '1' ]; then 
        test_ols
    elif [ "$INSTALLWORDPRESS" = "1" ] ; then
        if [ "$INSTALLWORDPRESSPLUS" = "1" ] ; then
            test_wordpress_plus
        else
            test_wordpress
        fi
    else
        test_ols
    fi

    if [ "${TESTGETERROR}" = "yes" ] ; then
        echoG "Errors were encountered during testing. In many cases these errors can be solved manually by referring to installation logs."
        echoG "Service loading issues can sometimes be resolved by performing a restart of the web server."
        echoG "Reinstalling the web server can also help if neither of the above approaches resolve the issue."
    fi

    echoCYAN "End auto testing << << << <<"
    echoG 'Thanks for using OpenLiteSpeed One click installation!'
    echo
}

function main_init_check
{
    check_root
    check_os
    check_cur_status
    check_dbversion_param
}

function main_init_package
{
    update_centos_hashlib
    update_system
    check_wget
    check_curl
}

function main
{
    display_license
    main_init_check
    action_uninstall
    action_purgeall
    update_email
    main_gen_password
    befor_install_display
    main_init_package
    install_openlitespeed
    main_ols_password
    gen_selfsigned_cert
    main_pure_db
    main_install_wordpress
    config_server
    config_php
    main_owasp
    set_proxy_vh
    restart_lsws
    after_install_display
    main_ols_test
}

while [ ! -z "${1}" ] ; do
    case "${1}" in
        --adminuser )  
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                ADMINUSER=$FOLLOWPARAM
                ;;
        -[aA] | --adminpassword )  
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                ADMINPASSWORD=$FOLLOWPARAM
                ;;
        --adminport )  
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                ADMINPORT=$FOLLOWPARAM
                ;;                
        -[eE] | --email )          
                check_value_follow "$2" "email address"
                shift
                EMAIL=$FOLLOWPARAM
                ;;
        --lsphp )           
                check_value_follow "$2" "LSPHP version"
                shift
                cnt=${#LSPHPVERLIST[@]}
                for (( i = 0 ; i < cnt ; i++ )); do
                    if [ "$1" = "${LSPHPVERLIST[$i]}" ] ; then LSPHPVER=$1; fi
                done
                ;;
        --mariadbver )      
                check_value_follow "$2" "MariaDB version"
                shift
                cnt=${#MARIADBVERLIST[@]}
                for (( i = 0 ; i < cnt ; i++ )); do 
                    if [ "$1" = "${MARIADBVERLIST[$i]}" ] ; then MARIADBVER=$1; fi 
                done                    
                ;;
        --pure-mariadb )
                PURE_DB=1
                ;;    
        --pure-mysql )
                PURE_MYSQL=1
                ;;
        --pure-percona )
                PURE_PERCONA=1
                ;;                
        --with-mysql )
                WITH_MYSQL=1
                ;;
        --with-percona )
                WITH_PERCONA=1
                ;;                                        
        -[wW] | --wordpress )      
                INSTALLWORDPRESS=1
                ;;
        --wordpressplus )  
                check_value_follow "$2" "domain"
                shift
                SITEDOMAIN=$FOLLOWPARAM
                INSTALLWORDPRESS=1
                INSTALLWORDPRESSPLUS=1
                ;;
        --wordpresspath )  
                check_value_follow "$2" "WordPress path"
                shift
                WORDPRESSPATH=$FOLLOWPARAM
                INSTALLWORDPRESS=1
                ;;
        -[rR] | --dbrootpassword ) 
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                ROOTPASSWORD=$FOLLOWPARAM
                ;;
        --dbname )         
                check_value_follow "$2" "database name"
                shift
                DATABASENAME=$FOLLOWPARAM
                ;;
        --dbuser )         
                check_value_follow "$2" "database username"
                shift
                USERNAME=$FOLLOWPARAM
                ;;
        --dbpassword )     
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                USERPASSWORD=$FOLLOWPARAM
                ;;
        --listenport )      
                check_value_follow "$2" "HTTP listen port"
                shift
                WPPORT=$FOLLOWPARAM
                ;;
        --ssllistenport )   
                check_value_follow "$2" "HTTPS listen port"
                shift
                SSLWPPORT=$FOLLOWPARAM
                ;;
        --wpuser )          
               check_value_follow "$2" "WordPress user"
                shift
                WPUSER=$1
                ;;
        --wppassword )      
                check_value_follow "$2" ""
                if [ ! -z "$FOLLOWPARAM" ] ; then shift; fi
                WPPASSWORD=$FOLLOWPARAM
                ;;
        --wplang )          
                check_value_follow "$2" "WordPress language"
                shift
                WPLANGUAGE=$FOLLOWPARAM
                fixLangTypo
                ;;
        --prefix )         
                check_value_follow "$2" "Table Prefix"
                shift
                DBPREFIX=$FOLLOWPARAM
                ;;                
        --sitetitle )       
                check_value_follow "$2" "WordPress website title"
                shift
                WPTITLE=$FOLLOWPARAM
                ;;
        -[Uu] | --uninstall )       
                ACTION=UNINSTALL
                ;;
        --proxy-r )
                PROXY=1
                PROXY_TYPE='r'
                ;;     
        --proxy-c )
                PROXY=1
                PROXY_TYPE='c'
                ;;           
        --owasp-enable )
                if [ -e ${WEBCF} ]; then
                    SET_OWASP='ON'
                    main_owasp
                    exit 0
                else
                    SET_OWASP='ON'
                fi    
                ;;      
        --owasp-disable )
                disable_ols_modesec
                exit 0
                ;;                                                               
        -[Pp] | --purgeall )        
                ACTION=PURGEALL
                ;;
        -[qQ] | --quiet )           
                FORCEYES=1
                ;;
        -V | --version )     
                display_license
                exit 0
                ;;
        --update )         
                updatemyself
                ;;
        -v | --verbose )             
                VERBOSE=1
                APT='apt-get'
                YUM='yum'
                ;;
        -[hH] | --help )           
                usage
                ;;
        * )                     
                usage
                ;;
    esac
    shift
done

main
