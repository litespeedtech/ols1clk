# ols1clk
========

Description
--------

ols1clk is a one-click installation script for OpenLiteSpeed. Using this script,
you can quickly and easily install OpenLiteSpeed with its default settings. We
also provide a **-c** parameter to install ClassicPress at the same time. Both must still be configured through
the wp-config.php page. A MariaDB database can also be set up using this script
if needed. If you already have a ClassicPress installation running
on another server, it can be imported into OpenLiteSpeed with no hassle using the
**--classicpresspath** parameters. To completely install
ClassicPress with your OpenLiteSpeed installation, skipping the need for the
wp-config.php page, use the **--classicpressplus** flag. These can be used with
**--wpuser**, **--wppassword**, **--wplang**, and **--sitetitle** to configure
each of the settings normally set by wp-config.php.

## Installation

Our One-Click script comes with several options. Here are two commmon usages.

Install OpenLiteSpeed, LSPHP, MariaDB, ClassicPress, and LiteSpeed Cache plugin:
```
bash <( curl -k https://raw.githubusercontent.com/litespeedtech/ols1clk/classicpress/ols1clk.sh ) -c
```

Install OpenLiteSpeed and LSPHP only:
```
bash <( curl -k https://raw.githubusercontent.com/litespeedtech/ols1clk/classicpress/ols1clk.sh )
```

See below for additional options and usage examples.

### Options:
```
./ols1clk.sh [option] [option] …
```

|  Opt |    Options    | Description|
| :---: | ---------  | ---  |
|      |`--adminuser [USERNAME]`|          To set the WebAdmin username for OpenLiteSpeed instead of admin.|
| `-A` |`--adminpassword [PASSWORD]`|      To set the WebAdmin password for OpenLiteSpeed instead of using a random one.|
|      |`--adminport [PORTNUMBER]`|          To set the WebAdmin console port number instead of 7080.|
| `-E` |`--email [EMAIL]`|                 To set the administrator email.|
|      |`--lsphp [VERSION]`    |           To set the LSPHP version, such as 84. We currently support versions '74 80 81 82 83 84'.|
|      |`--mariadbver [VERSION]`  |        To set MariaDB version, such as 11.4. We currently support versions '10.11 11.4 11.6 11.8'.|
| `-C` |`--classicpress`|                     To install ClassicPress. You will still need to complete the ClassicPress setup by browser|
|      |  `--classicpressplus [SITEDOMAIN]`|  To install, set up, and configure ClassicPress, also LSCache will be enabled|
|      |  `--classicpresspath [WP_PATH]`|     To specify a location for the new ClassicPress installation or use for an existing ClassicPress.|
| `-R` | `--dbrootpassword [PASSWORD]` |   To set the database root password instead of using a random one.|
|      |  `--dbname [DATABASENAME]` |      To set the database name to be used by ClassicPress.|
|      |  `--dbuser [DBUSERNAME]`   |      To set the ClassicPress username in the database.|
|      |  `--dbpassword [PASSWORD]` |      To set the ClassicPress table password in MySQL instead of using a random one.|
|      |  `--prefix [PREFIXNAME]`   |      To set the ClassicPress table prefix.|
|      |  `--listenport [PORT]`  |         To set the HTTP server listener port, default is 80.|
|      |  `--ssllistenport [PORT]` |       To set the HTTPS server listener port, default is 443.|
|      |  `--wpuser [WP_USER]`   |         To set the ClassicPress admin user for ClassicPress dashboard login. Default value is wpuser.|
|      |   `--wppassword [PASSWORD]`    |  To set the ClassicPress admin user password for ClassicPress dashboard login.|
|      |   `--wplang [WP_LANGUAGE]` |      To set the ClassicPress language. Default value is "en_US" for English.|
|      |   `--sitetitle [WP_TITLE]` |      To set the ClassicPress site title. Default value is mySite.|
|      |   `--pure-mariadb`|               To install OpenLiteSpeed and MariaDB.|
|      |   `--pure-mysql`|                 To install OpenLiteSpeed and MySQL.|
|      |   `--pure-percona`|               To install OpenLiteSpeed and Percona.|
|      |   `--with-mysql`  |               To install OpenLiteSpeed/App with MySQL.|
|      |   `--with-percona`  |             To install OpenLiteSpeed/App with Percona.|
|      |   `--owasp-enable`  |             To enable mod_security with OWASP rules. If OLS is installed, then enable the owasp directly|
|      |   `--owasp-disable`  |            To disable mod_security with OWASP rules.|
|      |   `--fail2ban-disable`  |         To enable fail2ban for webadmin and ClassicPress login pages.| 
|      |   `--proxy-r`  |                  To set a proxy with rewrite type.|
|      |   `--proxy-c`  |                  To set a proxy with config type.|
| `-U` |   `--uninstall`  |                To uninstall OpenLiteSpeed and remove installation directory.|
| `-P` |   `--purgeall`   |                To uninstall OpenLiteSpeed, remove installation directory, and purge all data in MySQL.|
| `-Q` |   `--quiet`      |                To use quiet mode, won't prompt to input anything.|
| `-V` |   `--version`    |                To display the script version information.|
| `-v` |   `--verbose`    |                To display more messages during the installation.|
|      |   `--update`      |               To update ols1clk from github.|
| `-H` |    `--help`       |               To display help messages.|

### Examples
|    Examples    | Description|
|---|---|
|      `./ols1clk.sh`                       |To install OpenLiteSpeed with a random WebAdmin password.|
|      `./ols1clk.sh --lsphp 84 `           |To install OpenLiteSpeed with lsphp84.|
|      `./ols1clk.sh -A 123456 -e a@cc.com` |To install OpenLiteSpeed with WebAdmin password  "123456" and email a@cc.com.|
|      `./ols1clk.sh -R 123456 -W `         |To install OpenLiteSpeed with ClassicPress and MySQL root password "123456".|
|      `./ols1clk.sh --classicpressplus a.com` |To install OpenLiteSpeed with a fully configured ClassicPress installation at "a.com".|

## FAQ

### How do I create additional Virtual Hosts from the console?
Run the following command to create an additional virtual host in a few seconds. The example document root will be **/var/www/www.example.com**. Be sure to substitute your own domain. 
```
/bin/bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh ) -d www.example.com
```

### How do I create additional Virtual Hosts from the console?
The first time you create an additional Virtual Host, the script will need to get your database root password from **/usr/local/lsws/password**. If you have custom value, please update **/usr/local/lsws/password** or echo the password to the specified location: **/root/.db_password**. 
```
echo 'root_mysql_pass="DB_ROOT_PASSWORD"' > /root/.db_password
```

Then run the following command to create an additional virtual host.
```
/bin/bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh ) -d www.example.com
```

### How to I create additional Virtual Hosts and LE certificates from the console?
Please be sure that your domain is already pointing to the server.

Then run the following command to create an additional virtual host with a Let's Encrypt certificate applied. Be sure to substitute your own domain and your email address. 
```
/bin/bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh ) -d www.example.com -le admin@example.com -f
```
Note: The `-f` option is to force https redirection 

## Support & Feedback
If you still have a question after reading these instructions, you have a few options:
* Join [the GoLiteSpeed Slack community](https://litespeedtech.com/slack) for real-time discussion
* Report any issue on the [Github ols1clk](https://github.com/litespeedtech/ols1clk/issues) project
* Report any issue or discuss any OpenLiteSpeed topic on the [OLS Google Group](https://groups.google.com/forum/#!forum/openlitespeed-development)