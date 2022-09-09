#! /bin/bash

# Load the configuration file
[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

NPMRC_BASE=$(<.npmrc)

# Utils
bold=$(tput bold)
normal=$(tput sgr0)

# Get last version from package on registry
VERSION=$(curl -s $REGISTRY_URL$LIBRARY_NAME | jq -r '."dist-tags".latest')

increment_version() {
  local delimiter=.
  local array=($(echo "$1" | tr $delimiter '\n'))
  array[$2]=$((array[$2]+1))
  if [ $2 -lt 2 ]; then array[2]=0; fi
  if [ $2 -lt 1 ]; then array[1]=0; fi
  echo $(local IFS=$delimiter ; echo "${array[*]}")
}

UPDATED_VERSION=$(increment_version $VERSION 3)

echo "Last version available on registry: $VERSION"
echo "\n${bold}📦 New version: $UPDATED_VERSION${normal}"

# Move to library's folder
cd $LIBRARY_PATH

# Change registry to local
echo "\n✍🏽 Updating .npmrc file for local registry"

mv .npmrc .npmrc.bkp
echo "$NPMRC_BASE" > .npmrc

# Edit package.json from autofill
echo "\n📄 Edit package.json from $LIBRARY_PATH"

mv package.json temp.json
jq '.version = "'$UPDATED_VERSION'"' temp.json > package.json
rm temp.json

# Run build script
echo "\n${bold}⚡️ Run build script${normal}"
npm run --silent build 

# Publish to registry
echo "\n${bold}⚡️ Run publish${normal}"
npm publish

# Restore original npmrc
echo "\nRestoring .npmrc file"

rm .npmrc
mv .npmrc.bkp .npmrc

# Move to frontend's folder
cd $FRONTEND_PATH

# Change registry to local
echo "\n✍🏽 Updating .npmrc file for local registry"

mv .npmrc .npmrc.bkp
echo "$NPMRC_BASE" > .npmrc

# Update package.json from frontend
echo "\n📄 Edit package.json from $FRONTEND_PATH"

mv package.json temp.json
jq -r '.dependencies."'$LIBRARY_NAME'" = "'$UPDATED_VERSION'"' temp.json > package.json
rm temp.json

# Install dependencies
echo "\nUpdate dependencies..."
npm i --no-audit --no-fund --silent

# Restore original npmrc
echo "\nRestoring .npmrc file"

rm .npmrc
mv .npmrc.bkp .npmrc

echo "\n${bold}Ready to go! 🚀 ${normal}"