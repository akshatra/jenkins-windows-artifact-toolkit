﻿[CmdletBinding()]
param (
    [string]$ProjectName,
    [string]$BranchName,
    [switch]$ReplaceArtifact
)

# Restting TLS security protocol configuration for network communication in PowerShell with Windows Server 2016
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls11,Tls12'

# Set Jenkins credentials from environment variables
$jenkinsUsername = "Jenkins_USERNAME" # Jenkins username
$jenkinsPassword = "Jenkins_Password" # Jenkins password
$jenkinsUrl = "https://jenkins-master.example.com" # Jenkins URL

# Encode Jenkins credentials
$base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${jenkinsUsername}:${jenkinsPassword}"))
# Create the headers for authorization
$headers = @{
    Authorization = "Basic ${base64Auth}"
}

# Receiving the selected projectName and jobName from the dropdown Or cmd
& ".\projectDownloader.ps1" -JenkinsUrl:$jenkinsUrl -Header:$headers -EnteredProjectName:$ProjectName -EnteredBranchName:$BranchName -ReplaceArtifact:$ReplaceArtifact 