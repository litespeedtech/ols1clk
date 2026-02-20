# ols1clk
[![Build Status](https://github.com/litespeedtech/ols1clk/workflows/ols1clk/badge.svg)](https://github.com/litespeedtech/ols1clk/actions/)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](https://litespeedtech.com/slack)
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

## Description

`ols1clk` is a one-click installation script for OpenLiteSpeed.

It can:
- Install OpenLiteSpeed with default settings
- Install WordPress with OpenLiteSpeed (`-W` / `--wordpress`)
- Fully provision WordPress (`--wordpressplus`) with optional site settings
- Use MariaDB by default, or MySQL/Percona via flags
- Import an existing WordPress path (`--wordpresspath`)

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
|  | `--adminuser [USERNAME]` | Set the WebAdmin username instead of `admin`. |
| `-A` | `--adminpassword [PASSWORD]` | Set the WebAdmin password instead of using a random one. |
|  | `--adminport [PORTNUMBER]` | Set the WebAdmin console port instead of `7080`. |
| `-E` | `--email [EMAIL]` | Set the administrator email. |

### PHP Configuration
| Opt | Option | Description |
| :---: | --- | --- |
|  | `--lsphp [VERSION]` | Set the LSPHP version (for example `84`). Supported: `74 80 81 82 83 84 85`. |

### Database Options
| Opt | Option | Description |
| :---: | --- | --- |
|  | `--mariadbver [VERSION]` | Set MariaDB version. Supported: `10.6 10.11 11.4 11.8`. |
| `-R` | `--dbrootpassword [PASSWORD]` | Set the database root password. |
|  | `--dbname [DATABASENAME]` | Set the WordPress database name. |
|  | `--dbuser [DBUSERNAME]` | Set the WordPress database user. |
|  | `--dbpassword [PASSWORD]` | Set the WordPress database password. |
|  | `--prefix [PREFIXNAME]` | Set the WordPress table prefix. |
|  | `--pure-mariadb` | Install OpenLiteSpeed and MariaDB. |
|  | `--pure-mysql` | Install OpenLiteSpeed and MySQL. |
|  | `--pure-percona` | Install OpenLiteSpeed and Percona. |
|  | `--with-mysql` | Install OpenLiteSpeed/App with MySQL. |
|  | `--with-percona` | Install OpenLiteSpeed/App with Percona. |

### Application Options
| Opt | Option | Description |
| :---: | --- | --- |
| `-W` | `--wordpress` | Install WordPress. You still need to complete setup in the browser. |
|  | `--wordpressplus [SITEDOMAIN]` | Install and fully configure WordPress, with LSCache enabled. |
|  | `--wordpresspath [WP_PATH]` | Specify a path for a new or existing WordPress install. |
|  | `--wpuser [WP_USER]` | Set the WordPress admin username. |
|  | `--wppassword [PASSWORD]` | Set the WordPress admin password. |
|  | `--wplang [WP_LANGUAGE]` | Set WordPress language (default: `en_US`). |
|  | `--sitetitle [WP_TITLE]` | Set WordPress site title (default: `mySite`). |

### System Configuration
| Opt | Option | Description |
| :---: | --- | --- |
|  | `--listenport [PORT]` | Set HTTP listener port (default: `80`). |
|  | `--ssllistenport [PORT]` | Set HTTPS listener port (default: `443`). |
|  | `--proxy-r` | Configure proxy with rewrite type. |
|  | `--proxy-c` | Configure proxy with config type. |

### Security Configuration
| Opt | Option | Description |
| :---: | --- | --- |
|  | `--owasp-enable` | Enable ModSecurity with OWASP rules. If OLS is installed, enable directly. |
|  | `--owasp-disable` | Disable ModSecurity with OWASP rules. |
|  | `--fail2ban-enable` | Enable Fail2ban for WebAdmin and WordPress login pages. |

### Control
| Opt | Option | Description |
| :---: | --- | --- |
| `-U` | `--uninstall` | Uninstall OpenLiteSpeed and remove the installation directory. |
| `-P` | `--purgeall` | Uninstall OpenLiteSpeed, remove install directory, and purge all MySQL data. |
| `-Q` | `--quiet` | Quiet mode (no prompts). |
| `-V` | `--version` | Display script version information. |
| `-v` | `--verbose` | Display more output during installation. |
|  | `--update` | Update `ols1clk` from GitHub. |
| `-H` | `--help` | Display help messages. |

## Usage Examples

### Web Server with PHP
```bash
# Install OpenLiteSpeed with default PHP version.
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
# Enable OWASP for OLS. This can also be used after OLS is already installed.
./ols1clk.sh --owasp-enable
```

## FAQ

### How do I create additional virtual hosts from the console?
Run the following command to create an additional virtual host. The example document root is `/var/www/www.example.com`. Replace with your domain.
```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com
```

### How do I create additional virtual hosts with WordPress from the console?
The first time you create an additional virtual host, the script needs the database root password from `/usr/local/ols/password`. If you use a custom value, update that file or write it to `/root/.db_password`:
```bash
echo 'root_mysql_pass="DB_ROOT_PASSWORD"' > /root/.db_password
```

Then run:
```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com -w
```

### How do I create additional virtual hosts and Let's Encrypt certificates from the console?
Make sure your domain already points to the server.

Then run:
```bash
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/litespeedtech/ls-cloud-image/master/Setup/vhsetup.sh) -d www.example.com -le admin@example.com -f
```

`-f` forces HTTPS redirection.

### How do I set up a WordPress site with more features?
Follow the [Build WordPress Image guide](https://github.com/litespeedtech/ls-cloud-image/wiki/Build-WordPress-Image#what-if-i-want-to-use-it-directly) to quickly set up OpenLiteSpeed, WordPress, LSCache, phpMyAdmin, Let's Encrypt, and Redis with WebSocket support.

For additional supported CMS scripts, visit the [ls-cloud-image Wiki](https://github.com/litespeedtech/ls-cloud-image/wiki).

## Support & Feedback

If you still have questions after reading these instructions:
- Join the [GoLiteSpeed Slack community](https://litespeedtech.com/slack) for real-time discussion
- Report issues in [GitHub ols1clk](https://github.com/litespeedtech/ols1clk/issues)
- Discuss OpenLiteSpeed topics in the [OLS Google Group](https://groups.google.com/forum/#!forum/openlitespeed-development)
