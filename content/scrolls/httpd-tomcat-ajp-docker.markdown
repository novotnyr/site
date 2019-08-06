---
title: Dockerized, loadbalanced, AJP-proxied Tomcats and HTTPD
date: 2019-08-04T00:30:12+02:00
---

In the demo, we show how one dockerized `httpd` loadbalances two dockerized Tomcats:

* AJP is the loadbalancing protocol
* `mod_proxy` does the AJP proxying on the `httpd` side
* `mod_proxy_balancer` handles the loadbalancing on the `httpd` side
* Tomcat AJP connector handles the AJP protocol with `httpd`.
* A `jvmRoute` is dynamically configured on the Tomcat side to provide sticky sessions.

See [GitHub README](https://github.com/novotnyr/httpd-tomcat-ajp-docker) for highly detailed description and tutorial.