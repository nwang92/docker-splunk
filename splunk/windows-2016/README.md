Don't use USER in Dockerfile because there are errors with "Error response from daemon: container c007e557cb243a221d6a95a193fdca7e9457a82894562e78659d1f9e83ea5570 encountered an error during CreateProcess: failure in a Windows system call: The user name or password is incorrect."
https://github.com/docker/for-win/issues/636

Another cool thing is you can't mount files into Windows containers, ex: `docker run -v C:\file.txt:C:\tmp\ microsoft/windowsservercore` will fail with "C:\Program Files\Docker\docker.exe: Error response from daemon: invalid bind mount spec "C:\\Dockerfile.txt:C:\\tmp\\":invalid volume specification: 'C:\Dockerfile.txt:C:\tmp\': invalid mount config for type "bind": source path must be a directory."
