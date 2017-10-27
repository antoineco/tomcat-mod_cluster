FROM antoineco/tomcat:7-centos

LABEL maintainer="Antoine Cotten <tonio.cotten@gmail.com> (@antoineco)"

ENV MOD_CLUSTER_VERSION=1.3.8.Final \
    MOD_CLUSTER_MD5SUM=93dc6218d6dd14ae4ce24c5c09f20ab5

# install mod_cluster components
RUN set -x \
  && buildDeps=" \
       java-1.${JAVA_VERSION%%[-~bu]*}.0-openjdk-devel-$JAVA_CENTOS_VERSION \
     " \
  && yum install -y $buildDeps \
  && yum clean all \
# centos 7 does not have a recent enough maven package (< 3.2.5)
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
  && curl -sSL https://github.com/modcluster/mod_cluster/archive/"$MOD_CLUSTER_VERSION".tar.gz -o mod_cluster.tgz \
  && echo "$MOD_CLUSTER_MD5SUM  /tmp/mod_cluster.tgz" | md5sum -c - \
  && modDir="$(tar -tf mod_cluster.tgz | head -1)" \
  && tar -xzvf mod_cluster.tgz && rm mod_cluster.tgz \
  && cd "$modDir" \
# build release tarball, twice
# see https://issues.jboss.org/browse/MODCLUSTER-571
  && mvn -P dist package -DskipTests && mvn -P dist package -DskipTests \
# extract compiled libraries to CATALINA_HOME
  && tar -xzvf target/mod_cluster-parent-"$MOD_CLUSTER_VERSION"-bin.tar.gz \
       --strip-components=2 -C "$CATALINA_HOME"/lib \
       --exclude=mod_cluster-container-tomcat6*.jar --exclude=mod_cluster-container-tomcat8*.jar \
       JBossWeb-Tomcat/lib \
# cleanup
  && yum history -y undo last \
  && rm -rf /tmp/"$modDir" ~/.m2 /usr/share/maven /usr/bin/mvn

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
