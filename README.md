# Supported tags and respective `Dockerfile` links

* `1.3.5-6`, `1.3-6`, `1-6` [(1.3/6/Dockerfile)][dockerfile-tc6]
* `1.3.5-7`, `1.3-7`, `1-7` [(1.3/7/Dockerfile)][dockerfile-tc7]
* `1.3.5-7-alpine`, `1.3-7-alpine`, `1-7-alpine` [(1.3/7-alpine/Dockerfile)][dockerfile-tc7-alpine]
* `1.3.5-8`, `1.3-8`, `1-8`, `1.3.5`, `1.3`, `1`, `latest` [(1.3/8/Dockerfile)][dockerfile-tc8]
* `1.3.5-8-alpine`, `1.3-8-alpine`, `1-8-alpine`, `1.3.5-alpine`, `1.3-alpine`, `1-alpine`, `alpine` [(1.3/8-alpine/Dockerfile)][dockerfile-tc8-alpine]
* `1.3.5-8.5`, `1.3-8.5`, `1-8.5` [(1.3/8.5/Dockerfile)][dockerfile-tc8.5]
* `1.3.5-8.5-alpine`, `1.3-8.5-alpine`, `1-8.5-alpine` [(1.3/8.5-alpine/Dockerfile)][dockerfile-tc8.5-alpine]

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

# Image Variants

The `tomcat-mod_cluster` images come in different flavors, each designed for a specific use case.

## Base operating system

### `tomcat-mod_cluster:<version>`

This is the defacto image, based on the [Debian](http://debian.org) operating system, available in [the `debian` official image](https://hub.docker.com/_/debian).

### `tomcat-mod_cluster:<version>-alpine`

This image is based on the [Alpine Linux](http://alpinelinux.org) operating system, available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

## Components

A tagging convention determines the version of the components distributed with the `tomcat-mod_cluster` image.

### `<version α>`

* mod_cluster release: **α**
* Tomcat release: *as distributed with the [`tomcat:latest`][docker-tomcat] upstream image*

### `<version α>-<version β>`

* mod_cluster release: **α**
* Tomcat release: **β** (latest patch version)

# Maintenance

## Updating configuration

After performing changes to the Dockerfile templates or sample httpd configuration, regenerate the repository tree with:

```
./generate-dockerfiles.sh
```

## Updating library definition

After committing changes to the repository, regenerate the library definition file with:

```
./generate-bashbrew-library.sh >| httpd-mod_cluster
```

## Rebuilding images

All images in this repository can be rebuilt and tagged manually using [Bashbrew][bashbrew], the tool used for cloning, building, tagging, and pushing the Docker official images. To do so, simply call the `bashbrew` utility, pointing it to the included `httpd-mod_cluster` definition file as in the example below:

```
bashbrew --library . build tomcat-mod_cluster
```

## Automated build pipeline

Any push to the upstream [`tomcat`][docker-tomcat] repository or to the source repository triggers an automatic rebuild of all the images in this repository. From a high perspective the automated build pipeline looks like the below diagram:

![Automated build pipeline][pipeline]


[dockerfile-tc6]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/6/Dockerfile
[dockerfile-tc7]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/7/Dockerfile
[dockerfile-tc7-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/7-alpine/Dockerfile
[dockerfile-tc8]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/8/Dockerfile
[dockerfile-tc8-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/8-alpine/Dockerfile
[dockerfile-tc8.5]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/8.5/Dockerfile
[dockerfile-tc8.5-alpine]: https://github.com/antoineco/tomcat-mod_cluster/blob/master/1.3/8.5-alpine/Dockerfile
[banner]: https://raw.githubusercontent.com/antoineco/tomcat-mod_cluster/master/modcluster_banner_r1v2.png
[docker-tomcat]: https://hub.docker.com/_/tomcat/
[mod_cluster]: http://modcluster.io/
[mod_cluster-tc-conf]: http://modcluster.io/documentation/#worker-side-configuration-properties
[bashbrew]: https://github.com/docker-library/official-images/blob/master/bashbrew/README.md
[pipeline]: https://raw.githubusercontent.com/antoineco/tomcat-mod_cluster/master/build_pipeline.png
