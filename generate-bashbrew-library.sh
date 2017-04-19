#!/usr/bin/env bash
#
# Generate Bashbrew library definition
#

set -euo pipefail

declare -A latestVariant=(
	['1.3']='8.5'
)
declare -A aliases=(
	['1.3']='1 latest'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

cat <<-EOH
Maintainers: Antoine Cotten <tonio.cotten@gmail.com> (@antoineco)
GitRepo: https://github.com/antoineco/tomcat-mod_cluster.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version in "${versions[@]}"; do
	variants=( "$version"/*/ ) # "1.3/8.0/" or "1.3/8.0-alpine/"
	variants=( "${variants[@]#${version}/}" ) # "8.0/" or "8.0-alpine/"
	variants=( $(printf "%s\n" "${variants[@]%/}" | sort -V) ) # "8.0" or "8.0-alpine"

	for variant in "${variants[@]}"; do
		tcVariant="${variant%-*}" # "8.0"
		shopt -s extglob
		subVariant="${variant##${tcVariant}?(-)}" # "" or "alpine"
		shopt -u extglob

		[ -f "$version/$variant/Dockerfile" ] || continue

		commit="$(dirCommit "$version/$variant")"

		fullVersion="$(git show "$commit":"$version/$variant/Dockerfile" \
			| awk -F'[= ]' '$1 == "ENV" && $2 == "MOD_CLUSTER_VERSION" { print $3; exit }')" # "1.3.5.Final"
		fullVersion="${fullVersion%.*}" # "1.3.5"

		versionAliases=()
		while [ "$fullVersion" != "$version" -a "${fullVersion%[.-]*}" != "$fullVersion" ]; do
			versionAliases+=( $fullVersion )
			fullVersion="${fullVersion%[.-]*}"
		done # ( "1.3.5" )

		versionAliases+=(
			$version
			${aliases[$version]:-}
		) # ( "1.3.5" "1.3" "1" "latest" )

		variantAliases=(
			"${versionAliases[@]/%/-$variant}"
		) # ( "1.3.5-8.0" ... "1-8.0", "latest-8.0" ) or ( "1.3.5-8.0-alpine" ... "1-8.0-alpine", "latest-8.0-alpine" )
		variantAliases=(
			${variantAliases[@]##latest-*}
		) # ( "1.3.5-8.0" ... "1-8.0" ) or ( "1.3.5-8.0-alpine" ... "1-8.0-alpine" )

		if [ "$variant" = "${latestVariant[$version]}" ]; then # variant == "8.0"
			variantAliases+=( "${versionAliases[@]}" )
		elif [ "$subVariant" -a "${variant%-$subVariant}" = "${latestVariant[$version]}" ]; then # alpine && variant == "8.0"
			subVariantAliases=( "${versionAliases[@]/%/-$subVariant}" )
			subVariantAliases=( "${subVariantAliases[@]#latest-}" )
			variantAliases+=( "${subVariantAliases[@]}" )
		fi

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			GitCommit: $commit
			Directory: $version/$variant
		EOE
	done
done
