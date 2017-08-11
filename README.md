# ols1clk
========

Description
--------

ols1clk is a one-click installation script for OpenLiteSpeed. Using this script, you can quickly and easily install OpenLiteSpeed with it’s default settings. We also provide a **-w** parameter that will install WordPress at the same time but it must still be configured through the wp-config.php page. An openmysql database can also be set up using this script if needed. If you already have a WordPress installation running on another server, it can be imported into OpenLiteSpeed with no hassle using the **--wordpresspath** parameter. To completely install WordPress with your OpenLiteSpeed installation, skipping the need for the wp-config.php page, use the **--wordpressplus** flag. This can be used with **--wpuser**, **--wppassword**, **--wplang**, and **--sitetitle** to configure each of the settings normally set by wp-config.php.

Running ols1clk
--------

ols1clk can be run in the following way:
*./ols1clk.sh [options] [options] …*

When run with no options, ols1clk will install OpenLiteSpeed with the default settings and values.

####Possible Options:
* **--adminpassword(-a) [PASSWORD]:** To set set the webAdmin password for OpenLiteSpeed instead of a random one.
  * If you omit **[PASSWORD]**, ols1clk will prompt you to provide this password during installation.
* **--email(-e) EMAIL:** to set the email of the administrator.
* **--lsphp VERSION:** to set the version of lsphp, such as 56, we currently support 54 55 56 and 70.
* **--mariadbver VERSION:** to set the version of mariadb server, such as 10.1, we currently support 10.0 10.1 and 10.2.
* **--wordpress(-w):** to install and setup wordpress. You will still need to access the /wp-admin/wp-config.php file to finish your wordpress installation.
* **--wordpressplus SITEDOMAIN:** to install, setup, and configure wordpress, eliminating the need to use the wp-config.php setup. 
* **--wordpresspath WORDPRESSPATH:** to specify a location for the new wordpress installation or use an existing wordpress installation.
* **--dbrootpassword(-r) [PASSWORD]:** to set the mysql server root password instead of using a random one.
  * If you omit **[PASSWORD]**, ols1clk will prompt you to provide this password during installation.
* **--dbname DATABASENAME:** to set the database name to be used by wordpress.
* **--dbuser DBUSERNAME:** to set the username of wordpress in mysql.
* **--dbpassword [PASSWORD]:** to set the password of wordpress in mysql instead of using a random one.
  * If you omit **[PASSWORD]**, ols1clk will prompt you to provide this password during installation.
* **--listenport WORDPRESSPORT:** to set the listener port, default is 80.
* **--wpuser WORDPRESSUSER:** to set the wordpress user for dmin login to the wordpress dashboard, default is wpuser.
* **--wppassword [PASSWORD]:** to set the wordpress password for admin login to the wordpress dashboard.
  * If you omit **[PASSWORD]**, ols1clk will prompt you to provide this password during installation.
* **--wplang WORDPRESSLANGUAGE:** to set the wordpress language, default is "en" for English.
* **--sitetitle WORDPRESSSITETITLE:** To set the wordpress site title, default is mySite.
* **--uninstall:** to uninstall OpenLiteSpeed and remove the installation directory.
* **--purgeall:** to uninstall OpenLiteSpeed, remove the installation directory, and purge all data in mysql.
* **--version(-v):** to display version information.
* **--help(-h):** to display usage.

Get in Touch
--------

OpenLiteSpeed has a [Google Group](https://groups.google.com/forum/#!forum/openlitespeed-development). If you find a bug, want to request new features, or just want to talk about OpenLiteSpeed, this is the place to do it.

