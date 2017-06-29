FROM tomcat:7

MAINTAINER Antoine Cotten <tonio.cotten@gmail.com> (@antoineco)

ENV MOD_CLUSTER_VERSION=1.3.7.Final \
    MOD_CLUSTER_MD5SUM=ac5ad6cac05bfc2652fe8c4eb561d802

# install mod_cluster components
RUN set -x \
  && buildDeps=" \
       openjdk-${JAVA_VERSION%%[-~bu]*}-jdk=$JAVA_DEBIAN_VERSION \
     " \
  && apt-get update \
  && apt-get install -y --no-install-recommends -V $buildDeps \
  && rm -r /var/lib/apt/lists/* \
# debian 8 does not have a recent enough maven package (< 3.2.5)
# https://github.com/carlossg/docker-maven/blob/8c27861cd48f7aeeb99a925d32f13e2bfca2ba4d/jdk-8/Dockerfile
  && MAVEN_VERSION=3.3.9 \
     SHA=6e3e9c949ab4695a204f74038717aa7b2689b1be94875899ac1b3fe42800ff82 \
     BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-$MAVEN_VERSION-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
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
       --exclude=mod_cluster-container-tomcat6*.jar --exclude=mod_cluster-container-tomcat8*.jar \
       JBossWeb-Tomcat/lib \
# cleanup
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf ~/.m2 /usr/share/maven /usr/bin/mvn /usr/share/java /tmp/"$modDir"

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
