/usr/bin/python <<DONE

import os
import tempfile

sdk_url = 'https://s3.amazonaws.com/engineering-apportable/ApportableSDK/mac/f3e73d34678e04c5b6dd4fd7217f76bb41fa9db8/ApportableSDK-f3e73d34678e04c5b6dd4fd7217f76bb41fa9db8_ae563d5092e2371c.tgz'
sdk_path = '/usr/local/apportable'
cli_path = '/usr/local/bin/apportable'

def download(url):
    output = os.path.join(tempfile.gettempdir(), url.split('/')[-1])
    err = os.system('curl ' + url + ' > ' + output)
    if err != 0:
        print "Download failed."
        exit(err)
    return output


def extract(path, destination):
    err = os.system('tar -xzvf ' + path + ' -C ' + destination)
    if err != 0:
        print "Unarchive failed."
        exit(err)
    return os.path.join(destination, 'SDK')


def update_toolchain(path):
    err = os.system(os.path.join(path, 'site_scons', 'apportable.py') + ' --confirm-stable-updates update_toolchain')
    if err != 0:
        print "Toolchain update failed."
        exit(err)


def install_sdk(path, destination):
    print "Requesting root privileges to move SDK to " + destination + " and create " + cli_path
    err = os.system('sudo mv ' + path + ' ' + destination)
    if err != 0:
        print "Install failed."
        exit(err)
    err = os.system('sudo ln -s ' + os.path.join(destination, 'site_scons', 'apportable.py') + ' ' + '/usr/local/bin/apportable')
    if err != 0:
        print "Unable to create " + cli_path
        exit(err)


tarball = download(sdk_url)
extracted = extract(tarball, os.path.join(tempfile.gettempdir()))
update_toolchain(extracted)
install_sdk(extracted, sdk_path)

DONE
