FROM tomcat:8.0

MAINTAINER Antoine Cotten <tonio.cotten@gmail.com> (@antoineco)

ENV MOD_CLUSTER_VERSION=1.3.6.Final \
    MOD_CLUSTER_MD5SUM=71f91477fc872018d5857ddf74edbb8e

# install mod_cluster components
RUN set -x \
  && buildDeps=" \
       openjdk-${JAVA_VERSION%%[-~bu]*}-jdk=$JAVA_DEBIAN_VERSION \
       maven \
     " \
  && apt-get update \
  && apt-get install -y --no-install-recommends -V $buildDeps \
  && rm -r /var/lib/apt/lists/* \
  && cd /tmp \
  && wget https://github.com/modcluster/mod_cluster/archive/"$MOD_CLUSTER_VERSION".tar.gz -O mod_cluster.tgz \
  && echo "$MOD_CLUSTER_MD5SUM  /tmp/mod_cluster.tgz" | md5sum -c - \
  && modDir="$(tar -tf mod_cluster.tgz | head -1)" \
  && tar -xzvf mod_cluster.tgz && rm mod_cluster.tgz \
  && cd "$modDir" \
# build release tarball, twice
# see https://issues.jboss.org/browse/MODCLUSTER-571
  && mvn -P dist package && mvn -P dist package \
# extract compiled libraries to CATALINA_HOME
  && tar -xzvf target/mod_cluster-parent-"$MOD_CLUSTER_VERSION"-bin.tar.gz \
       --strip-components=2 -C "$CATALINA_HOME"/lib \
       --exclude=mod_cluster-container-tomcat6*.jar --exclude=mod_cluster-container-tomcat7*.jar \
       JBossWeb-Tomcat/lib \
# cleanup
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf ~/.m2 /tmp/"$modDir"

# add example Listener to server configuration
RUN listenerLine="$(grep -nE "^\s+<Listener" conf/server.xml | tail -1 | cut -d':' -f1)" \
  && sed -i \
       -e "${listenerLine}a\ \ <!-- ModCluster Listener. Documentation at http://modcluster.io/documentation/#worker-side-configuration-properties -->" \
       -e "${listenerLine}a\ \ <Listener className=\"org.jboss.modcluster.container.catalina.standalone.ModClusterListener\" advertise=\"true\" />" \
       conf/server.xml

# verify mod_cluster is working properly
RUN set -e \
  && clusterLines="$(catalina.sh configtest 2>&1)" \
  && clusterLines="$(echo "$clusterLines" | grep -i 'modcluster')" \
  && if ! echo "$clusterLines" | grep 'INFO: MODCLUSTER000001: Initializing mod_cluster' >&2; then \
       echo >&2 "$clusterLines"; \
       exit 1; \
     fi
