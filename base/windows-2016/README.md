Supportive, helpful information & tips:

pynacl can fail to compile with something like "libtool:   error: object name conflicts in archive: .libs/libsodium.lax/libaesni.a//home/pynacl-master/build/temp.cygwin-2.10.0-x86_64-2.7/src/libsodium/./.libs/libaesni.a"

This is due to PATH being set incorrectly - we need to set Cygwin's path before Windows path. See https://stackoverflow.com/questions/12060186/libtool-object-name-conflicts-in-archive-netcdf-mingw

https://www.jeffgeerling.com/blog/running-ansible-within-windows
https://boneanu.blogspot.com/2017/07/upgrade-ansible-on-cygwin.html
https://boneanu.blogspot.com/2016/05/install-ansible-on-cygwin.html
https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058
