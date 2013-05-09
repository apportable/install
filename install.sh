#!/bin/sh
SDK_URL="https://s3.amazonaws.com/engineering-apportable/ApportableSDK/mac/19893793928b82d96badca4fdd051d139ba2e8a9/ApportableSDK-19893793928b82d96badca4fdd051d139ba2e8a9_232e6c3bc7046dd3.tgz"
SDK_PATH="$HOME/.apportable/SDK"

echo "Downloading SDK"

# download and extract the client tarball
rm -rf $SDK_PATH
mkdir -p $SDK_PATH
cd $SDK_PATH

curl $SDK_URL | tar xz

mv SDK/* .
rmdir SDK

echo "SDK installed, now updating toolchain..."

# $SDK_PATH/site_scons/apportable.py update_toolchain

echo "Toolchain updated."

cd bin
ln -s ../site_scons/apportable.py apportable

echo "Apportable CLI is successfully installed."

# remind the user to add to $PATH
if [[ ":$PATH:" != *":$SDK_PATH/bin:"* ]]; then
  echo "Add the Apportable CLI to your PATH using:"
  echo "$ echo 'PATH=\"$SDK_PATH/bin:\$PATH\"' >> ~/.bash_profile"
  echo "$ source ~/.bash_profile"
fi
