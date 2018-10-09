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

#This script is used to retrieve and report the state of the container
#Although not actively in the container, it can be used to check the health
#of the splunk instance
#NOTE: If you plan on running the splunk container while keeping Splunk
# inactive for long periods of time, this script may give misleading
# health results

$CONTAINER_STATE_FILE = "C:\Users\splunk-container.state"

function checkSplunkd {
	Invoke-RestMethod -Method GET -Uri "https://localhost:8089" -SkipCertificateCheck -TimeoutSec 30
	return $LASTEXITCODE
}

If ( $env:NO_HEALTHCHECK -eq $null ) {
	$STATE = Get-Content $CONTAINER_STATE_FILE
	switch ( $STATE ) {
		running { $result = checkSplunkd; exit $result }
		started { $result = checkSplunkd; exit $result }
		default { exit 1 }
	}
} Else {
	exit 0
}
