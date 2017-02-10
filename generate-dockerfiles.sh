#!/usr/bin/env bash
#
# Generate all the repository Dockerfiles from templates
#

set -euo pipefail

declare -A modClusterVersions=(
	['1.3']='1.3.5.Final'
)

declare -A modClusterMd5sums=(
	['1.3']='91c54d6e87141acbbf854c39a48872c9'
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
		variant="$(basename "$variant")" # "tc8" or "tc8-alpine"
		tcVariant="${variant%-*}" # "tc7"
		tcMajor="${tcVariant:2:1}" # "7"
		shopt -s extglob
		subVariant="${variant##${tcVariant}?(-)}" # "" or "alpine"
		shopt -u extglob

		baseImage='tomcat'
		case "$variant" in
			tc*)
				baseImage+=":${tcVariant#tc}${subVariant:+-$subVariant}" # ":8" or ":8-alpine"
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

	done
done

