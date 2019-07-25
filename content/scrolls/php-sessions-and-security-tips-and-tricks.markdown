---
title: PHP Sessions and Security – Tips and Tricks
date: 2008-01-31T00:00:00+01:00
---

And now: 30 seconds o' fun:

## Misc notes
* take MD5 of USER_AGENT into account (and possibly other HTTP headers) -- changing of it between sessions may be possible hijack
* use cookies as extra security level (put fingerprint into cookie)
	* Store md5 of sid, ip, login time into cookie and into db table to compare them later
* use prevention of logging into existing session -- always generate new session ID after login.
* try to issue session id only after successful authentication
* take note of IP-verifying. Some proxies may change your IP. However, you can limit it to C-class network.
* SSL is your friend

## Other issues in PHP

* enabled transparent SID may cause problems with HTTP Content-length
* definition of classes stored in session must be included prior to starting session (beware of auto_start)

## Links

### Interval.cz
* http://interval.cz/clanek.asp?article=2730
* http://interval.cz/clanek.asp?article=1408 (session stealing and XSS)
* http://interval.cz/clanek.asp?article=734 (authorization in PHP)

### Shiflett.org
* http://shiflett.org/php-security.pdf (PHP Security Issues)
* http://shiflett.org/articles (General Articles)
* http://shiflett.org/articles/security-corner-feb2004 (Session fixation)

### Misc
* http://stock.ter.dk/session.php
* http://www.sitepoint.com/blog-post-view.php?id=156260
* [Security Aspects of a PHP-MySQL-Based Login System for Web Sites](http://my.opera.com/community/articles/php/securitysystem/secaspects.pdf )
