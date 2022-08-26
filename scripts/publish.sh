#! /bin/zsh

# Constants
REGISTRY_URL="http://localhost:4873/"
LIBRARY_NAME="@cockpit/autofill"
LIBRARY_PATH="/Users/lucas/development/HIAE.COCKPIT.AutoPreenchimento.Frontend/"
FRONTEND_PATH="/Users/lucas/development/HIAE.COCKPIT.CorpoClinico.Frontend"

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
echo "${bold}New version: $UPDATED_VERSION${normal}"

# Move to library's folder
cd $LIBRARY_PATH

# Check if registry is local registry
CURRENT_REGISTRY=$(npm config get registry)

if [[ $CURRENT_REGISTRY != $REGISTRY_URL ]]; then
  echo "\n${bold}❌ Error${normal}"
  echo "\nThe registry at $LIBRARY_PATH is not local! Check .npmrc file."
  exit 1
fi

# Edit package.json from autofill
echo "\nEdit package.json from $LIBRARY_PATH"

mv package.json temp.json
jq '.version = "'$UPDATED_VERSION'"' temp.json > package.json
rm temp.json

# Run build script
echo "\n${bold}Run build script${normal}"
npm run build --silent

# Publish to registry
echo "\n${bold}Run publish${normal}"
npm publish

# Move to frontend's folder
cd $FRONTEND_PATH

# Check frontend path registry
CURRENT_REGISTRY=$(npm config get registry)

if [[ $CURRENT_REGISTRY != $REGISTRY_URL ]]; then
  echo "\n${bold}Set registry to local registry at $FRONTEND_PATH ${normal}"
  exit 1
fi

# Update package.json from frontend
echo "\nEdit package.json from $FRONTEND_PATH"

mv package.json temp.json
jq -r '.dependencies."'$LIBRARY_NAME'" = "'$UPDATED_VERSION'"' temp.json > package.json
rm temp.json

# Install dependencies
echo "\nUpdate dependencies..."
npm i --no-audit --no-fund --silent

echo "\n\n${bold}Ready to go! 🚀 ${normal}"