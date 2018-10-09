# escape=`

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

FROM base-windows-2016:latest

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG SPLUNK_FILENAME
ARG SPLUNK_BUILD_URL
ARG SPLUNK_DEFAULTS_URL

ENV SPLUNK_HOME=C:\\opt\\splunk `
	SPLUNK_GROUP=Administrators `
	SPLUNK_USER=splunk `
	SPLUNK_ROLE=splunk_standalone `
	SPLUNK_FILENAME=${SPLUNK_FILENAME} `
	SPLUNK_DEFAULTS_URL=${SPLUNK_DEFAULTS_URL} `
	SPLUNK_ANSIBLE_HOME=C:\\opt\\ansible

# Setup users and download Splunk
RUN New-LocalUser -Name $env:SPLUNK_USER -Description "Splunk" -NoPassword; `
	Add-LocalGroupMember -Group $env:SPLUNK_GROUP -Member $env:SPLUNK_USER; `
	Write-Host "Downloading Splunk and validating the checksum at: $($env:SPLUNK_BUILD_URL)"; `
	Invoke-WebRequest $env:SPLUNK_BUILD_URL -OutFile C:\\$env:SPLUNK_FILENAME; `
	$SHA_FILENAME=$( $env:SPLUNK_FILENAME+'.sha512' ); `
	Invoke-WebRequest $( $env:SPLUNK_BUILD_URL+'.sha512' ) -OutFile C:\\$SHA_FILENAME; `
	$SHA=$(Get-Content C:\\$SHA_FILENAME).Split(' ')[0];`
	If ((Get-FileHash -Path C:\\$env:SPLUNK_FILENAME -Algorithm SHA512).Hash -ne $SHA) { `
		Write-Host "SHA mismatch - aborting!"; `
		exit 1; `
	}; `
	Remove-Item -Path C:\\$SHA_FILENAME -Force -Recurse; `
    Move-Item -Path C:\\$env:SPLUNK_FILENAME -Destination C:\splunk.msi

COPY splunk-ansible C:\\opt\\ansible
COPY [ "splunk/windows-2016/entrypoint.ps1", "splunk/windows-2016/checkstate.ps1", "splunk/windows-2016/createdefaults.py", "C:\\Users\\" ]

EXPOSE 4001 8000 8065 8088 8089 8191 9887 9997
VOLUME C:\opt\splunk\etc C:\opt\splunk\var

HEALTHCHECK --interval=30s --timeout=30s --start-period=5m --retries=5 CMD powershell C:\\Users\\checkstate.ps1

ENTRYPOINT [ "powershell" , "C:\\Users\\entrypoint.ps1" ]
CMD [ "start-service" ]
