#!/bin/sh
APPORTABLE_PATH="$HOME/.apportable"
SDK_PATH="$APPORTABLE_PATH/SDK"
TOOLCHAIN_PATH="$APPORTABLE_PATH/toolchain"
APPORTABLE_TOOL_PATH="./lib/apportable/apportable.py"
SCONS_TOOL_PATH="./site_scons/apportable.py"
TOOL_PATH=$APPORTABLE_TOOL_PATH

echo "Checking Python version..."
python -c "import sys; print sys.version; sys.exit(sys.version_info<(2,7) or sys.version_info>=(3,))"

if [ $? -ne 0 ]; then
  echo "Your version of Python is not supported. We recommend Python 2.7.x."
  exit 1
fi

echo "Checking for latest SDK..."

SDK_URL=`curl -s --fail http://www.apportable.com/sdk?key=$LICENSE`
if [ -z "$SDK_URL" ]
then
  echo "Could not find your SDK, please contact sdk@apportable.com."
  exit 1
fi

echo "Downloading SDK from $SDK_URL"

# download and extract the client tarball into $SDK_PATH/SDK
mkdir -p $SDK_PATH
cd $SDK_PATH
rm -rf SDK
curl $SDK_URL | tar xz

# move $SDK_PATH/SDK to $SDK_PATH
cd $APPORTABLE_PATH
mv SDK SDK-old
mv SDK-old/SDK SDK
rm -rf SDK-old

echo "SDK installed into $SDK_PATH. Now updating toolchain."

cd $SDK_PATH
echo $LICENSE > LICENSE
mkdir -p $TOOLCHAIN_PATH
ln -s $TOOLCHAIN_PATH toolchain

if [ -f $APPORTABLE_TOOL_PATH ]; then
    TOOL_PATH=$APPORTABLE_TOOL_PATH
elif [ -f $SCONS_TOOL_PATH ]; then
    TOOL_PATH=$SCONS_TOOL_PATH
else
    echo "Unable to find build system tool."
    exit 1
fi

$TOOL_PATH update_toolchain --confirm-stable-updates

echo "Toolchain downloaded into $TOOLCHAIN_PATH."

cd bin
ln -s ".$TOOL_PATH" apportable
ln -s ../toolchain/macosx/android-sdk/platform-tools/adb adb

echo "Apportable CLI is successfully installed at $SDK_PATH/bin/apportable"

# remind the user to add to $PATH
if [[ ":$PATH:" != *":$SDK_PATH/bin:"* ]]; then
  echo "If you're using the default shell, add the Apportable CLI to your PATH using:"
  echo "(echo; echo 'PATH=\"$SDK_PATH/bin:\$PATH\"') >> ~/.bash_profile; source ~/.bash_profile"
fi
