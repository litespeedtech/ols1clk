# ols1clk
========

Description
--------

ols1clk is a one-click installation script for OpenLiteSpeed. Using this script, you can quickly and easily install OpenLiteSpeed with it’s default settings. We also provide a **-w** parameter that will install WordPress at the same time. An openmysql database can also be set up using this script if needed. If you already have a WordPress installation running on another server, it can be imported into OpenLiteSpeed with no hassle using the **--wordpresspath** param.

Running ols1clk
--------

ols1clk can be run in the following way:
*./ols1clk.sh [options] [options] …*

When run with no options, ols1clk will install OpenLiteSpeed with the default settings and values.

####Possible Options:
* **-a**, **--adminpassword [-- webAdminPassword]:** used to set the webAdmin password for OpenLiteSpeed instead of a random one.
  * If you omit **[-- webAdminPassword]**, ols1clk will prompt you to provide this password during installation.
* **-e**, **--email EMAIL:** to set the email of the administrator.
* **-w**, **--wordpress:** set to install and setup wordpress.
* **--wordpresspath WORDPRESSPATH:** to use an existing wordpress installation instead of a new wordpress install.
* **-r**, **--rootpassworddb [-- mysqlRootPassword]:** to set the mysql server root password instead of using a random one.
  * If you omit **[-- mysqlRootPassword]**, ols1clk will prompt you to provide this password during installation.
* **-d**, **--databasename DATABASENAME:** to set the database name to be used by wordpress.
* **-u**, **--usernamedb DBUSERNAME:** to set the username of wordpress in mysql.
* **-p**, **--passworddb [-- databasePassword]:** to set the password of wordpress in mysql instead of using a random one.
  * If you omit **[-- databasePassword]**, ols1clk will prompt you to provide this password during installation.
* **-l**, **--listenport WORDPRESSPORT:** to set the listener port, default is 80.
* **--uninstall:** to uninstall OpenLiteSpeed and remove installation directory
* **--purgeall:** to uninstall OpenLiteSpeed, remove installation directory, and purge all data in mysql.
* **-h**, **--help:** to display usage.

Get in Touch
--------

OpenLiteSpeed has a [Google Group](https://groups.google.com/forum/#!forum/openlitespeed-development). If you find a bug, want to request new features, or just want to talk about OpenLiteSpeed, this is the place to do it.

