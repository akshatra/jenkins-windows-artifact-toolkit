[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$JenkinsUrl,    
    [Parameter(Position = 1, Mandatory = $true)]
    [hashtable]$Header,
    [Parameter(Position = 3)]
    [string]$EnteredProjectName,
    [Parameter(Position = 4)]
    [string]$EnteredBranchName,
    [Parameter(Position = 5)]
    [switch]$ReplaceArtifact
)
# Setting local variables for values from the main script
$jenkinsUrl = $JenkinsUrl
$headers = $Header

# Import or load the DialogueBox file
. ".\DialogueBox.ps1"

# Setting entered CMD variables to local variables
if ($null -ne $EnteredProjectName -and $null -ne $EnteredBranchName) {
    $selectedProjectName = $EnteredProjectName
    $selectedJobName = $EnteredBranchName
}

function downloadArtifact {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$selectedProjectName,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$selectedJobName
    )

    # Details for constructing artifactUrl
    # Set the artifact id based on the project name.
    # **** REPLACE WITH OWN PROJECT NAMES and ARTIFACT NAMES *****
    switch ($selectedProjectName) {
        "Project1" {
            $artifactPath = "repo1.zip"
        }
        "Project2" {
            $artifactPath = "repo2.zip"
        }
        "Project3" {
            $artifactPath = "repo3.zip"
        }
        "Project4" {
            $artifactPath = "repo4.zip"
        }
        default {
            Write-Host "Entered incorrect project name."
            Write-Host "Note : Enter project name in this syntax : bna.<project-name>.<job-name>"
        }
    }   
    # Setting the build-version to download
    $buildNumber = "lastSuccessfulBuild"
    # Setting the current Date
    $start_time = Get-Date
    # Setting destination path to save the downloaded artifact
    $destinationFile = "artifact.zip"
    # Encoded job name for URL
    $encodedJobName = [System.Uri]::EscapeDataString([System.Uri]::EscapeDataString($selectedJobName))
    
    # Building job name to pass in the URL.
    # all jobs in project respository
    # **** REPLACE EXAMPLE OWN URL *****
    $jobName = "example/job/${selectedProjectName}/job/${encodedJobName}"

    Write-Host " ********************************* "
    Write-Host "This is the jenkins Url:  $jenkinsUrl"
    Write-Host "This is the job Name: $jobName"
    Write-Host "This is the build Number: $buildNumber"
    Write-Host "This is the artifact Path: $artifactPath"
    Write-Host " ********************************* "
    # Construct artifact URL
    $artifactUrl = "{0}/job/{1}/{2}/artifact/{3}" -f $jenkinsUrl, $jobName, $buildNumber, $artifactPath
    Write-Host "Downloading : ${artifactUrl}"
    
    # To increase download speed for artifact.
    $ProgressPreference = 'SilentlyContinue'
    try {
    # Download the artifact
        Invoke-WebRequest -UseBasicParsing $artifactUrl -Headers $headers -OutFile $destinationFile
        
        Write-Host "Artifact downloaded successfully to ${destinationFile}."
        Write-Host "Time taken to download artifact : $((Get-Date).Subtract($start_time).Seconds) second(s)"
    }
    catch {
        Write-Host "THERE IS NO 'LAST SUCCESSFUL ARTIFACT' FOR BRANCH '${selectedJobName}'."
		Exit
    }
}

function downloadAndReplaceArtifact {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$selectedProjectName,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$selectedJobName
    )

    # Download the artifact
    downloadArtifact -selectedProjectName $selectedProjectName -selectedJobName $selectedJobName
    
    # Extract the downloaded artifact to the 'data' folder
    $artifactPath = "$PSScriptRoot\artifact.zip"
    $extractedFolderPath = "$PSScriptRoot\data"
    Expand-Archive -Path $artifactPath -DestinationPath $extractedFolderPath

    # Switch case to perform actions based on the project name
    # **** REPLACE WITH OWN PROJECT NAMES *****
    switch ($selectedProjectName) {
        "Project1" {
            # For a project that does not require service stop
            # **** REPLACE WITH OWN DIRECTORY PATH *****
            $destinationPath = "C:\Location\To\Directory\Project1"
            $copyCommand = "Copy-Item -Path '$extractedFolderPath\*' -Destination '$destinationPath' -Recurse -Force"

            Start-Process PowerShell.exe -Wait -Verb RunAs -WindowStyle Hidden -ArgumentList "-Command", $copyCommand
        }
        "Project2" {
            # **** REPLACE WITH OWN SERIVE NAME *****
            $stopServiceCommand = "Stop-Service -Name 'Service_of_Project2'"
            # **** REPLACE WITH OWN DIRECTORY PATH *****
            $destinationPath = "C:\Location\To\Directory\Project2"
            $copyCommand = "Copy-Item -Path '$extractedFolderPath\*' -Destination '$destinationPath' -Recurse -Force"
            $startServiceCommand = "Start-Service -Name 'Service_of_Project2'"
            
            Start-Process PowerShell.exe -Wait -Verb RunAs -WindowStyle Hidden -ArgumentList "-Command", "$stopServiceCommand; $copyCommand; $startServiceCommand"
        }
        "Project3" {
            # **** REPLACE WITH OWN SERIVE NAME *****
            $stopServiceCommand = "Stop-Service -Name 'Service_of_Project3'"
            # **** REPLACE WITH OWN DIRECTORY PATH *****
            $destinationPath = "C:\Location\To\Directory\Project3"
            $copyCommand = "Copy-Item -Path '$extractedFolderPath\*' -Destination '$destinationPath' -Recurse -Force"
            $startServiceCommand = "Start-Service -Name 'Service_of_Project3'"
            
            Start-Process PowerShell.exe -Wait -Verb RunAs -WindowStyle Hidden -ArgumentList "-Command", "$stopServiceCommand; $copyCommand; $startServiceCommand"
        }
        "Project4" {
            # **** REPLACE WITH OWN SERIVE NAME *****
            $stopServiceCommand = "Stop-Service -Name 'Service_of_Project4'"
            # **** REPLACE WITH OWN SERIVE NAME *****
            $destinationPath = "C:\Location\To\Directory\Project4"
            $copyCommand = "Copy-Item -Path '$extractedFolderPath\*' -Destination '$destinationPath' -Recurse -Force"
            $startServiceCommand = "Start-Service -Name 'Service_of_Project4'"
            
            Start-Process PowerShell.exe -Wait -Verb RunAs -WindowStyle Hidden -ArgumentList "-Command", "$stopServiceCommand; $copyCommand; $startServiceCommand"
        }
        Default {
            Write-Host "Unknown project name: $selectedProjectName"
            Exit
        }
    }
    
    # Delete the 'data' folder
    Remove-Item -Path $extractedFolderPath -Force -Recurse
    Write-Host "Artifact extraction and replacement completed."
    
    Exit
}

if($selectedProjectName -eq '' -or $selectedJobName -eq '') {
    # Running in interactive mode (with GUI)
    $selectedProjectName, $selectedJobName, $selectedmode  = ShowDownloadDialog
    switch ($selectedmode) {
        downloadArtifact { downloadArtifact -selectedProjectName $selectedProjectName -selectedJobName $selectedJobName }
        downloadAndReplace { downloadAndReplaceArtifact -selectedProjectName $selectedProjectName -selectedJobName $selectedJobName }
        Default { Write-Host "Incorrect option clicked"}
    }
}
else {
    # Running in command line input mode (with CMD)
    if ($ReplaceArtifact) {
        # When ReplaceArtifact is Switched-ON
        downloadAndReplaceArtifact -selectedProjectName $selectedProjectName -selectedJobName $selectedJobName
    } else {
        downloadArtifact -selectedProjectName $selectedProjectName -selectedJobName $selectedJobName
    }
}
