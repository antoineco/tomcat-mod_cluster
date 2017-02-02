# Supported tags and respective `Dockerfile` links

* `1.3.5-tc7`, `1.3-tc7`, `1-tc7` [(1.3/tc7/Dockerfile)][dockerfile-tc7]
* `1.3.5-tc7-alpine`, `1.3-tc7-alpine`, `1-tc7-alpine` [(1.3/tc7/alpine/Dockerfile)][dockerfile-tc7-alpine]
* `1.3.5-tc8`, `1.3-tc8`, `1-tc8`, `1.3.5`, `1.3`, `1`, `latest` [(1.3/tc8/Dockerfile)][dockerfile-tc8]
* `1.3.5-tc8-alpine`, `1.3-tc8-alpine`, `1-tc8-alpine`, `1.3.5-alpine`, `1.3-alpine`, `1-alpine`, `alpine` [(1.3/tc8/alpine/Dockerfile)][dockerfile-tc8-alpine]
* `1.3.5-tc8.5`, `1.3-tc8.5`, `1-tc8.5` [(1.3/tc8.5/Dockerfile)][dockerfile-tc8.5]
* `1.3.5-tc8.5-alpine`, `1.3-tc8.5-alpine`, `1-tc8.5-alpine` [(1.3/tc8.5/alpine/Dockerfile)][dockerfile-tc8.5-alpine]

# What is `mod_cluster`?

mod_cluster is an httpd-based load balancer. Like mod_jk and mod_proxy, mod_cluster uses a communication channel to forward requests from httpd to one of a set of application server nodes. Unlike mod_jk and mod_proxy, mod_cluster leverages an additional connection between the application server nodes and httpd. The application server nodes use this connection to transmit server-side load balance factors and lifecycle events back to httpd via a custom set of HTTP methods, affectionately called the Mod-Cluster Management Protocol (MCMP). This additional feedback channel allows mod_cluster to offer a level of intelligence and granularity not found in other load balancing solutions.

> [JBoss mod_cluster project page][mod_cluster]

![JBoss mod_cluster][banner]

# What is the `tomcat-mod_cluster` image?

An extension of the upstream [`tomcat`][docker-tomcat] image with JBoss [`mod_cluster`][mod_cluster] worker components:
* `mod_cluster-core.jar`
* `mod_cluster-container-tomcat.jar`
* `mod_cluster-container-catalina.jar`
* `mod_cluster-container-catalina-standalone.jar`
* `mod_cluster-container-spi.jar`
* `jboss-logging.jar`

# How to use the `tomcat-mod_cluster` image?

This image inherits from the configuration options from the parent [`tomcat`][docker-tomcat] image.

The `ModCluster` Listener is configured by default to listen to multicast advertise messages in the Tomcat server configuration file (`conf/server.xml`). Please refer to the [mod_cluster documentation][mod_cluster-tc-conf] for a list of all available worker-side Configuration Properties.

# Rebuilding tags

All tags supported by this repository can be rebuilt using [Bashbrew][bashbrew], the tool used for cloning, building, tagging, and pushing the Docker official images. To do so, simply call the `bashbrew` utility, pointing it to the included `tomcat-mod_cluster` definition file as in the example below:
```
bashbrew --library . build tomcat-mod_cluster
```


[dockerfile-tc7]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc7/Dockerfile
[dockerfile-tc7-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc7/alpine/Dockerfile
[dockerfile-tc8]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc8/Dockerfile
[dockerfile-tc8-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc8/alpine/Dockerfile
[dockerfile-tc8.5]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc8.5/Dockerfile
[dockerfile-tc8.5-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/tc8.5/alpine/Dockerfile
[banner]: https://raw.githubusercontent.com/antoineco/tomcat-mod_cluster/master/modcluster_banner_r1v2.png
[docker-tomcat]: https://hub.docker.com/_/tomcat/
[mod_cluster]: http://modcluster.io/
[mod_cluster-tc-conf]: http://modcluster.io/documentation/#worker-side-configuration-properties
[bashbrew]: https://github.com/docker-library/official-images/blob/master/bashbrew/README.md
