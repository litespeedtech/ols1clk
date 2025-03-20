# ols1clk
[![Build Status](https://github.com/litespeedtech/ols1clk/workflows/ols1clk/badge.svg)](https://github.com/litespeedtech/ols1clk/actions/)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](litespeedtech.com/slack) 
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)


# OpenLiteSpeed Installation Enhancement

> This is a fork of the official OpenLiteSpeed one-click installation script, enhanced to improve installation reliability and compatibility across different operating systems.

## Original Project
- Original Repository: [OpenLiteSpeed/ols1clk](https://github.com/litespeedtech/ols1clk)

## Author
Ebrahim Shafiei (EbraSha)
- Email: Prof.Shafiei@Gmail.com
- GitHub: [EbraSha](https://github.com/EbraSha)

## Project Description
This enhanced version of the OpenLiteSpeed installation script focuses on fixing installation issues and improving compatibility across different Linux distributions. While maintaining the core functionality of the original script, we've added several improvements to make the installation process more reliable.

## Changes and Branches By EbraSha

### Branch: `ebrasha:fix-starting-system-tests`
**Date: 2025-03-21**

* Add robust system dependency installation function
* Implement retry mechanism for service and port testing
* Add better error handling and status reporting
* Support both CentOS and Debian/Ubuntu systems
* Add timeout and retry limits for network tests
* Improve test feedback messages
* Add service status verification
* Add port accessibility checks with retries



## Installation

Our One-Click script comes with several options. Here are two commmon usages.

Install OpenLiteSpeed, LSPHP, MariaDB, WordPress, and LiteSpeed Cache plugin:
```
bash <( curl -k https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh ) -w
```

Install OpenLiteSpeed and LSPHP only:
```
bash <( curl -k https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh )
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
|      |`--lsphp [VERSION]`    |           To set the LSPHP version, such as 83. We currently support versions '74 80 81 82 83'.|
|      |`--mariadbver [VERSION]`  |        To set MariaDB version, such as 11.4. We currently support versions '10.6 10.11 11.4 11.6'.|
| `-W` |`--wordpress`|                     To install WordPress. You will still need to complete the WordPress setup by browser|
|      |  `--wordpressplus [SITEDOMAIN]`|  To install, set up, and configure WordPress, also LSCache will be enabled|
|      |  `--wordpresspath [WP_PATH]`|     To specify a location for the new WordPress installation or use for an existing WordPress.|
| `-R` | `--dbrootpassword [PASSWORD]` |   To set the database root password instead of using a random one.|
|      |  `--dbname [DATABASENAME]` |      To set the database name to be used by WordPress.|
|      |  `--dbuser [DBUSERNAME]`   |      To set the WordPress username in the database.|
|      |  `--dbpassword [PASSWORD]` |      To set the WordPress table password in MySQL instead of using a random one.|
|      |  `--prefix [PREFIXNAME]`   |      To set the WordPress table prefix.|
|      |  `--listenport [PORT]`  |         To set the HTTP server listener port, default is 80.|
|      |  `--ssllistenport [PORT]` |       To set the HTTPS server listener port, default is 443.|
|      |  `--wpuser [WP_USER]`   |         To set the WordPress admin user for WordPress dashboard login. Default value is wpuser.|
|      |   `--wppassword [PASSWORD]`    |  To set the WordPress admin user password for WordPress dashboard login.|
|      |   `--wplang [WP_LANGUAGE]` |      To set the WordPress language. Default value is "en_US" for English.|
|      |   `--sitetitle [WP_TITLE]` |      To set the WordPress site title. Default value is mySite.|
|      |   `--pure-mariadb`|               To install OpenLiteSpeed and MariaDB.|
|      |   `--pure-mysql`|                 To install OpenLiteSpeed and MySQL.|
|      |   `--pure-percona`|               To install OpenLiteSpeed and Percona.|
|      |   `--with-mysql`  |               To install OpenLiteSpeed/App with MySQL.|
|      |   `--with-percona`  |             To install OpenLiteSpeed/App with Percona.|
|      |   `--owasp-enable`  |             To enable mod_security with OWASP rules. If OLS is installed, then enable the owasp directly|
|      |   `--owasp-disable`  |            To disable mod_security with OWASP rules.|    
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
|      `./ols1clk.sh --lsphp 81 `           |To install OpenLiteSpeed with lsphp80.|
|      `./ols1clk.sh -A 123456 -e a@cc.com` |To install OpenLiteSpeed with WebAdmin password  "123456" and email a@cc.com.|
|      `./ols1clk.sh -R 123456 -W `         |To install OpenLiteSpeed with WordPress and MySQL root password "123456".|
|      `./ols1clk.sh --wordpressplus a.com` |To install OpenLiteSpeed with a fully configured WordPress installation at "a.com".|

## FAQ

### How do I create additional Virtual Hosts from the console?
Run the following command to create an additional virtual host in a few seconds. The example document root will be **/var/www/www.example.com**. Be sure to substitute your own domain. 
```
/bin/bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh ) -d www.example.com
```

### How do I create additional Virtual Hosts with WordPress from the console?
The first time you create an additional Virtual Host, the script will need to get your database root password from **/usr/local/lsws/password**. If you have custom value, please update **/usr/local/lsws/password** or echo the password to the specified location: **/root/.db_password**. 
```
echo 'root_mysql_pass="DB_ROOT_PASSWORD"' > /root/.db_password
```

Then run the following command to create an additional virtual host with the WordPress.
```
/bin/bash <( curl -sk https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh ) -d www.example.com -w
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