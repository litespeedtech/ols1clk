# ols1clk

[![Build Status](https://github.com/litespeedtech/ols1clk/workflows/ols1clk/badge.svg)](https://github.com/litespeedtech/ols1clk/actions/)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](https://litespeedtech.com/slack)
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

## Description

`ols1clk` is a **One-Click Script** for installing OpenLiteSpeed (OLS).

It can:

- Install OpenLiteSpeed with default settings.
- Install WordPress with OpenLiteSpeed using `-W` or `--wordpress`.
- Fully provision WordPress using `--wordpressplus`, with optional site settings.
- Use MariaDB by default, or MySQL or Percona Server for MySQL through command-line options.
- Import an existing WordPress installation using `--wordpresspath`.

## Installation

Common usage:

Install OpenLiteSpeed, LSPHP, MariaDB, WordPress, and LiteSpeed Cache:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh) -W
```

Install OpenLiteSpeed and LSPHP only:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh)
```

See below for additional options and usage examples.

## Options

### Essential Options

| Opt | Option | Description |
| :---: | --- | --- |
|  | `--adminuser <username>` | Sets the **WebAdmin Console** username instead of using `admin`. |
| `-A` | `--adminpassword <password>` | Sets the **WebAdmin Console** password instead of generating a random password. |
|  | `--adminport <port>` | Sets the **WebAdmin Console** port instead of using `7080`. |
| `-E` | `--email <email>` | Sets the administrator email address. |

### PHP Configuration

| Opt | Option | Description |
| :---: | --- | --- |
|  | `--lsphp <version>` | Sets the LSPHP version, such as `84`. Supported versions are `74`, `80`, `81`, `82`, `83`, `84`, and `85`. |

### Database Options

| Opt | Option | Description |
| :---: | --- | --- |
|  | `--mariadbver <version>` | Sets the MariaDB version. Supported versions are `10.6`, `10.11`, `11.4`, and `11.8`. |
| `-R` | `--dbrootpassword <password>` | Sets the database root password. |
|  | `--dbname <database-name>` | Sets the WordPress database name. |
|  | `--dbuser <database-username>` | Sets the WordPress database username. |
|  | `--dbpassword <password>` | Sets the WordPress database-user password. |
|  | `--prefix <prefix>` | Sets the WordPress database-table prefix. |
|  | `--pure-mariadb` | Installs OpenLiteSpeed and MariaDB. |
|  | `--pure-mysql` | Installs OpenLiteSpeed and MySQL. |
|  | `--pure-percona` | Installs OpenLiteSpeed and Percona Server for MySQL. |
|  | `--with-mysql` | Installs OpenLiteSpeed and the selected application with MySQL. |
|  | `--with-percona` | Installs OpenLiteSpeed and the selected application with Percona Server for MySQL. |

### Application Options

| Opt | Option | Description |
| :---: | --- | --- |
| `-W` | `--wordpress` | Installs WordPress. You must complete the WordPress setup in a browser. |
|  | `--wordpressplus <site-domain>` | Installs, sets up, and configures WordPress. It also enables LiteSpeed Cache. |
|  | `--wordpresspath <path>` | Specifies the location for a new or existing WordPress installation. |
|  | `--wpuser <username>` | Sets the WordPress administrator username. |
|  | `--wppassword <password>` | Sets the WordPress administrator password. |
|  | `--wplang <language>` | Sets the WordPress language. The default is `en_US`. |
|  | `--sitetitle <title>` | Sets the WordPress site title. The default is `mySite`. |

### System Configuration

| Opt | Option | Description |
| :---: | --- | --- |
|  | `--listenport <port>` | Sets the HTTP listener port. The default is `80`. |
|  | `--ssllistenport <port>` | Sets the HTTPS listener port. The default is `443`. |
|  | `--sitedomain <site-domain>` | Sets the domain mapping at the listener level. The default is `*`. |
|  | `--autocert` | Installs ACME and enables **Automatic SSL Certificates** at the server level. |
|  | `--proxy-r` | Configures a proxy that uses rewrite rules. |
|  | `--proxy-c` | Configures a proxy that uses server configuration. |
|  | `--proxy-s` | Configures a web socket proxy. |
|  | `--proxy-port <port>` | Sets the proxy port. The default is `8080`. |

### Security Configuration

| Opt | Option | Description |
| :---: | --- | --- |
|  | `--owasp-enable` | Enables ModSecurity with OWASP rules. If OLS is already installed, this option enables the rules directly. |
|  | `--owasp-disable` | Disables ModSecurity with OWASP rules. |
|  | `--fail2ban-enable` | Enables Fail2Ban protection for the **WebAdmin Console** and WordPress login pages. |

### Control

| Opt | Option | Description |
| :---: | --- | --- |
| `-U` | `--uninstall` | Uninstalls OpenLiteSpeed and removes the installation directory. |
| `-P` | `--purgeall` | Uninstalls OpenLiteSpeed, removes the installation directory, and purges all MySQL data. |
| `-Q` | `--quiet` | Uses quiet mode and does not prompt for input. |
| `-V` | `--version` | Displays script version information. |
| `-v` | `--verbose` | Displays additional installation messages. |
|  | `--update` | Updates `ols1clk` from GitHub. |
| `-H` | `--help` | Displays help information. |

## Usage Examples

### Web Server with PHP

```bash
# Install OpenLiteSpeed with the default PHP version.
./ols1clk.sh
```

### WordPress with MariaDB

```bash
# Install OpenLiteSpeed with WordPress and MariaDB.
./ols1clk.sh -W
```

### WordPress with MySQL

```bash
# Install OpenLiteSpeed with WordPress and MySQL.
./ols1clk.sh -W --with-mysql
```

### OWASP

```bash
# Enable OWASP rules. This option can be used after OLS is installed.
./ols1clk.sh --owasp-enable
```

### Autocert

Make sure that your domain points to the server.

Then run:

```bash
./ols1clk.sh --sitedomain www.example.com --autocert
```

### Proxy custom port

```bash
./ols1clk.sh --proxy-r --proxy-port 7860
```

## FAQ

### How do I create additional virtual hosts from the console?

Run the following command to create an additional virtual host. The example document root is `/var/www/www.example.com`. Replace `www.example.com` with your domain.

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com
```

### How do I create additional virtual hosts with WordPress from the console?

The first time you create an additional virtual host, the script requires the database root password from `/usr/local/ols/password`. If you use a custom value, update that file or write the password to `/root/.db_password`:

```bash
echo 'root_mysql_pass="DB_ROOT_PASSWORD"' > /root/.db_password
```

Then run:

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com -w
```

### How do I create additional virtual hosts and Let's Encrypt certificates from the console?

Make sure that your domain points to the server.

Then run:

```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com -le admin@example.com -f
```

`-f` forces HTTPS redirection.

### How do I set up a WordPress site with more features?

Follow the [Build WordPress Image guide](https://github.com/litespeedtech/ls-cloud-image/wiki/Build-WordPress-Image#what-if-i-want-to-use-it-directly) to quickly set up OpenLiteSpeed, WordPress, LiteSpeed Cache, phpMyAdmin, Let's Encrypt, and Redis with WebSocket support.

For additional supported CMS scripts, visit the [ls-cloud-image Wiki](https://github.com/litespeedtech/ls-cloud-image/wiki).

## Support & Feedback

If you still have questions after reading these instructions:

- Join the [GoLiteSpeed Slack community](https://litespeedtech.com/slack) for real-time discussion.
- Report issues in [GitHub ols1clk](https://github.com/litespeedtech/ols1clk/issues).
- Discuss OpenLiteSpeed topics in the [OLS Google Group](https://groups.google.com/forum/#!forum/openlitespeed-development).