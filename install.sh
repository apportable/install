#!/bin/sh
SDK_PATH="$HOME/.apportable/SDK"
TOOLCHAIN_PATH="$HOME/.apportable/toolchain"

echo "Checking for latest SDK..."

SDK_URL=`curl -s --fail http://www.apportable.com/sdk?key=$LICENSE`
if [ -z "$SDK_URL" ]
then
  echo "Could not find your SDK, please contact sdk@apportable.com."
  exit 1
fi

echo "Downloading SDK..."

# download and extract the client tarball
rm -rf $SDK_PATH
mkdir -p $SDK_PATH
cd $SDK_PATH

curl $SDK_URL | tar xz

mv SDK/* .
rmdir SDK

echo "SDK installed. Now updating toolchain."

echo $LICENSE > $SDK_PATH/LICENSE

mkdir -p $TOOLCHAIN_PATH
ln -s $TOOLCHAIN_PATH toolchain
./site_scons/apportable.py update_toolchain --confirm-stable-updates

echo "Toolchain updated."

cd bin
ln -s ../site_scons/apportable.py apportable
ln -s ../toolchain/macosx/android-sdk/platform-tools/adb adb

echo "Apportable CLI is successfully installed at $SDK_PATH/bin/apportable"

# remind the user to add to $PATH
if [[ ":$PATH:" != *":$SDK_PATH/bin:"* ]]; then
  echo "If you're using the default shell, add the Apportable CLI to your PATH using:"
  echo "$ (echo; echo 'PATH=\"$SDK_PATH/bin:\$PATH\"') >> ~/.bash_profile"
  echo "$ source ~/.bash_profile"
fi
