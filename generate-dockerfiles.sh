#!/usr/bin/env bash
#
# Generate all the repository Dockerfiles from templates
#

set -euo pipefail

declare -A modClusterVersions=(
	['1.3']='1.3.6.Final'
)

declare -A modClusterMd5sums=(
	['1.3']='71f91477fc872018d5857ddf74edbb8e'
)

declare -a supportedTomcats=( 6 7 8 )

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	modClusterVersion="${modClusterVersions[$version]}"
	modClusterMd5sum="${modClusterMd5sums[$version]}"

	for variant in "$version"/*/; do
		variant="$(basename "$variant")" # "8" or "8-alpine"
		tcVariant="${variant%-*}" # "8" or "8.5"
		tcMajor="${tcVariant%.*}" # "8"
		shopt -s extglob
		subVariant="${variant##${tcVariant}?(-)}" # "" or "alpine"
		shopt -u extglob

		case "$subVariant" in
			centos)
				# no "centos" variant in official tomcat repo
				baseImage='antoineco\/tomcat'
				;;
			*)
				baseImage='tomcat'
				;;
		esac

		case "$variant" in
			[6-8]*)
				baseImage+=":${tcVariant}${subVariant:+-$subVariant}" # ":8" or ":8-alpine"
				;;
			*)
				echo >&2 "not sure what to do with $version/$variant re: baseImage; skipping"
				continue
				;;
		esac

		tarExclude=()
		for tomcat in "${supportedTomcats[@]}"; do
			if [ "$tomcat" != "$tcMajor" ]; then
				tarExclude+=( "--exclude=mod_cluster-container-tomcat${tomcat}*.jar" )
			fi
		done

		cp -v "Dockerfile${subVariant:+-$subVariant}.template" "$version/$variant/Dockerfile"

		sed -ri -e \
			" \
				s/__BASEIMAGE__/$baseImage/; \
				s/__MODCLUSTERVERSION__/$modClusterVersion/; \
				s/__MODCLUSTERMD5SUM__/$modClusterMd5sum/; \
				s/__TAREXCLUDE__/${tarExclude[*]}/ \
			" \
			"$version/$variant/Dockerfile"

		# proper smoke test impossible on Tomcat 6 due to missing 'configtest' subcommand
		if [ "$tcMajor" -eq 6 ]; then
			cat >> "$version/$variant/Dockerfile" <<-'EOD'

				# verify mod_cluster is working properly
				RUN set -e \
				  && catalina.sh start \
				  && while ! grep -q 'Server startup in' logs/catalina.out; do \
				       echo -n .; sleep .2; \
				     done; echo \
				  && catalina.sh stop \
				  && while pgrep java >/dev/null; do \
				       echo -n .; sleep .2; \
				     done; echo \
				  && clusterLines="$(grep -i 'modcluster' logs/catalina.out)" \
				  && if ! echo "$clusterLines" | grep 'INFO: MODCLUSTER000001: Initializing mod_cluster' >&2; then \
				       echo >&2 "$clusterLines"; \
				       exit 1; \
				     fi \
				  && rm -rf conf/Catalina work/Catalina logs/*
			EOD
		else
			cat >> "$version/$variant/Dockerfile" <<-'EOD'

				# verify mod_cluster is working properly
				RUN set -e \
				  && clusterLines="$(catalina.sh configtest 2>&1)" \
				  && clusterLines="$(echo "$clusterLines" | grep -i 'modcluster')" \
				  && if ! echo "$clusterLines" | grep 'INFO: MODCLUSTER000001: Initializing mod_cluster' >&2; then \
				       echo >&2 "$clusterLines"; \
				       exit 1; \
				     fi
			EOD
		fi
	done
done

