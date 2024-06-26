#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix git curl cacert nix-prefetch-git jq

set -euo pipefail

cd $(readlink -e $(dirname "${BASH_SOURCE[0]}"))

payload=$(curl -s https://api.github.com/repos/HMCL-dev/HMCL/releases/latest)

version=$(jq -r .tag_name <<<"$payload")

version="${version#v}"
jar_url=$(jq -r ".assets[] | select(.name == \"HMCL-$version.jar\") | .browser_download_url" <<<"$payload")
jar_hash=$(nix-prefetch-url $jar_url)

# use friendlier hashes
jar_hash=$(nix hash to-sri --type sha256 "$jar_hash")

cat >sources.nix <<EOF
# Generated by ./update.sh - do not update manually!
# Last updated: $(date +%F)
{
  version = "$version";
  jar_hash = "$jar_hash";
}
EOF
