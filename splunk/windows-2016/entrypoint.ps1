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

powershell -Command "$ErrorActionPreference = 'Stop';"
$CONTAINER_STATE_FILE = "C:\Users\splunk-container.state"

function EntrypointSetup {
	If ($env:SPLUNK_START_ARGS -NotMatch "--accept-license") {
		Write-Host "License not accepted, please ensure the environment variable SPLUNK_START_ARGS contains the '--accept-license' flag"
		Write-Host "For example: docker run -e SPLUNK_START_ARGS=--accept-license splunk/splunk`n"
		Write-Host "For additional information and examples, see the help: docker run -it splunk/splunk help`n"
		exit 1
	}
}

function EntrypointTeardown {
	# Always run the stop command on termination
	$stop = Start-Process -FilePath $($env:SPLUNK_HOME+'\bin\splunk.exe') -ArgumentList "stop" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
	exit $stop.ExitCode
}

trap { EntrypointTeardown }

function PrepAnsible {
	cd $env:SPLUNK_ANSIBLE_HOME
	If ($env:DEBUG -Match "true") {
		Start-Process -FilePath "C:\cygwin64\bin\bash.exe" -ArgumentList "-c 'ansible-playbook --version'" -WorkingDirectory $env:SPLUNK_ANSIBLE_HOME -NoNewWindow -Wait
		Start-Process -FilePath "C:\cygwin64\bin\bash.exe" -ArgumentList "-c 'python inventory/environ.py --write-to-file'" -WorkingDirectory $env:SPLUNK_ANSIBLE_HOME -NoNewWindow -Wait
		Get-Content -Path $( $env:SPLUNK_ANSIBLE_HOME+'\inventory\ansible_inventory.json' ) | Write-Host
	}
}

function WatchForFailure($exit_code) {
	If ($exit_code -eq 0) {
		echo "started" | Set-Content $CONTAINER_STATE_FILE
	} Else {
		exit $exit_code
	}
	Write-Host
	Write-Host "==============================================================================="
	Write-Host "Ansible playbook complete, will begin streaming var\log\splunk\splunkd_ui_access.log"
	Get-Content -Path $($env:SPLUNK_HOME+'\var\log\splunk\splunkd_ui_access.log') -Wait | Out-Null
}

function CreateDefaults {
	Start-Process -FilePath "C:\cygwin64\bin\bash.exe" -ArgumentList "-c 'SPLUNK_ANSIBLE_HOME=/opt/ansible python /cygdrive/c/Users/createdefaults.py'" -NoNewWindow -Wait
}

function StartAndExit {
	If ( $env:SPLUNK_PASSWORD -eq $null ) {
		Write-Host "WARNING: No password ENV var. Stack may fail to provision if splunk.password is not set in ENV or a default.yml"
	}
	echo "starting" | Set-Content $CONTAINER_STATE_FILE
	EntrypointSetup
	PrepAnsible
	$ansible = Start-Process -FilePath "C:\cygwin64\bin\bash.exe" -ArgumentList "-c 'ansible-playbook -i inventory/environ.py site.yml'" -WorkingDirectory $env:SPLUNK_ANSIBLE_HOME -NoNewWindow -Wait -PassThru
	return $ansible.ExitCode
}

function EntrypointStart {
	$CODE = StartAndExit
	WatchForFailure($CODE)
}

function EntrypointRestart {
	echo "restarting" | Set-Content $CONTAINER_STATE_FILE
	PrepAnsible
	Start-Process -FilePath $( $env:SPLUNK_HOME+"\bin\splunk.exe" ) -ArgumentList "stop" -NoNewWindow -Wait
	$ansible = Start-Process -FilePath "C:\cygwin64\bin\bash.exe" -ArgumentList "-c 'ansible-playbook -i inventory/environ.py start.yml'" -WorkingDirectory $env:SPLUNK_ANSIBLE_HOME -NoNewWindow -Wait -PassThru
	WatchForFailure($ansible.ExitCode)
}

function Help {
	Write-Host @"
  ____        _             _      __  
 / ___| _ __ | |_   _ _ __ | | __  \ \
 \___ \| '_ \| | | | | '_ \| |/ /   \ \
  ___) | |_) | | |_| | | | |   <    / /
 |____/| .__/|_|\__,_|_| |_|_|\_\  /_/ 
       |_|                            
========================================

Environment Variables: 
  * SPLUNK_USER - user under which to run Splunk (default: splunk)
  * SPLUNK_GROUP - group under which to run Splunk (default: splunk)
  * SPLUNK_HOME - home directory where Splunk gets installed (default: /opt/splunk)
  * SPLUNK_START_ARGS - arguments to pass into the Splunk start command; you must include '--accept-license' to start Splunk (default: none)
  * SPLUNK_ROLE - the role of this Splunk instance (default: splunk_standalone)
      Acceptable values:
        - splunk_standalone
        - splunk_search_head
        - splunk_indexer
        - splunk_deployer
        - splunk_license_master
        - splunk_cluster_master
        - splunk_heavy_forwarder 
  * SPLUNK_LICENSE_URI - URI or local file path (absolute path in the container) to a Splunk license
  * SPLUNK_STANDALONE_URL, SPLUNK_INDEXER_URL, ... - comma-separated list of resolvable aliases to properly bring-up a distributed environment. 
                                                     This is optional for standalones, but required for multi-node Splunk deployments.
  * SPLUNK_BUILD_URL - URL to a Splunk build which will be installed (instead of the image's default build)
  * SPLUNK_APPS_URL - comma-separated list of URLs to Splunk apps which will be downloaded and installed

Examples:
  * docker run -it -p 8000:8000 splunk/splunk start 
  * docker run -it -e SPLUNK_START_ARGS=--accept-license -p 8000:8000 -p 8089:8089 splunk/splunk start
  * docker run -it -e SPLUNK_START_ARGS=--accept-license -e SPLUNK_LICENSE_URI=http://example.com/splunk.lic -p 8000:8000 splunk/splunk start
  * docker run -it -e SPLUNK_START_ARGS=--accept-license -e SPLUNK_INDEXER_URL=idx1,idx2 -e SPLUNK_SEARCH_HEAD_URL=sh1,sh2 -e SPLUNK_ROLE=splunk_search_head --hostname sh1 --network splunknet --network-alias sh1 -e SPLUNK_PASSWORD=helloworld -e SPLUNK_LICENSE_URI=http://example.com/splunk.lic splunk/splunk start
"@
    exit 1
}

$COMMAND = $args[0]
switch ( $COMMAND ) {
	"start" { $result = EntrypointStart }
	"start-service" { $result = EntrypointStart }
	"start-and-exit" { $result = StartAndExit }
	"create-defaults" { $result = CreateDefaults }
	"restart" { $result = EntrypointRestart }
	"no-provision" { Get-Content -Path "C:\License.txt" -Wait | Out-Null }
	"cmd" { cmd }
	"powershell" { powershell }
	"help" { $result = Help }
	default { $result = Help }
}
