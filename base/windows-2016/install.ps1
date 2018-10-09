#!C:\Windows\System32\WindowsPowershell\v1.0\powershell
# Copyright 2018 Splunk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Write-Host "Set execution permission policy..."
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Stop
$ErrorActionPreference = "Stop"

Write-Host "Installing Cygwin and packages..."
Invoke-WebRequest https://cygwin.com/setup-x86_64.exe -OutFile C:\setup-x86_64.exe
Start-Process C:\setup-x86_64.exe -Wait -NoNewWindow -ArgumentList "-q -n -l C:\cygwin64\packages -s http://mirrors.kernel.org/sourceware/cygwin/ -R C:\cygwin64 -P python2,python2-devel,python2-cffi,libffi6,libffi-devel,openssl,openssl-devel,openssh,wget,binutils,curl,gmp,cygrunsrv,tar,qawk,bzip2,vim,make,gcc-g++,gcc-core,nano,git,unzip,zip"
Remove-Item C:\setup-x86_64.exe
$env:Path = "C:\cygwin64\bin;"+$env:Path

Write-Host "Setting path..."
$newPath = 'C:\cygwin64\bin;\cygwin\bin;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

Write-Host "Installing pip and Python packages..."
# TLSL protocol is used for download pip
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://bootstrap.pypa.io/get-pip.py -Outfile C:\cygwin64\bin\get-pip.py
C:\cygwin64\bin\python2.7.exe -V
C:\cygwin64\bin\python2.7.exe /bin/get-pip.py
C:\cygwin64\bin\python2.7.exe -m pip install --upgrade pip setuptools ansible

Write-Host "Setup other system directories..."
# Use soft link to solve path error
New-Item C:\tmp -Type directory -Force
Remove-Item C:\cygwin64\tmp
C:\cygwin64\bin\ln -s /cygdrive/c/tmp /tmp
C:\cygwin64\bin\ln -s /cygdrive/c/opt /opt
C:\cygwin64\bin\ln -s /etc /cygdrive/c/etc
