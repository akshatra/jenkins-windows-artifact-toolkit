enum DownloadOptions {
    downloadArtifact
    downloadAndReplace
}

#Setting the mode variable to current script scope.
$Mode= $null

function getJobs {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$projectName
    )
    
	# **** REPLACE "example" with OWN URL *****
    $apiUrl = "${jenkinsUrl}/job/example/job/${projectName}/api/json"   
    
    Write-Host "The Jenkins API URL for getting JOB names: $apiUrl"
    # Send the request and get the response
    $response = Invoke-WebRequest -Uri $apiUrl -Headers $headers
    # Convert the JSON response to PowerShell objects
    $jobsResponse = $response.Content | ConvertFrom-Json
    # Retrieve all job names 
    $jobNames = $jobsResponse.jobs.name
    # Double decode the job names
    $decodedJobNames = $jobNames | ForEach-Object {
        [System.Web.HttpUtility]::UrlDecode($_)
    }
    return $decodedJobNames
}

function ShowErrorMessage {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$errorMessage
    )

    Add-Type -AssemblyName System.Windows.Forms

    # Create a form
    $ErrorForm = New-Object System.Windows.Forms.Form
    $ErrorForm.Text = "Error Message"
    $ErrorForm.Size = New-Object System.Drawing.Size(410, 260)
    $ErrorForm.StartPosition = 'CenterScreen'

    # Show an error message in the GUI
    $errorLabel = New-Object System.Windows.Forms.Label
    $errorLabel.Location = New-Object System.Drawing.Point(10, 50)
    $errorLabel.Size = New-Object System.Drawing.Size(380, 100)
    $errorLabel.Text = $errorMessage
    $errorLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $errorLabel.ForeColor = [System.Drawing.Color]::Red
    $ErrorForm.Controls.Add($errorLabel)

    # Create Cancel button
    $buttonCancel = New-Object System.Windows.Forms.Button
    $buttonCancel.Location = New-Object System.Drawing.Point(150, 180)
    $buttonCancel.Size = New-Object System.Drawing.Size(100, 30)
    $buttonCancel.Text = "Cancel"
    $buttonCancel.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
    $buttonCancel.ForeColor = [System.Drawing.Color]::Black
    $buttonCancel.BackColor = [System.Drawing.Color]::LightGray
    $buttonCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $buttonCancel.Add_Click({
        $ErrorForm.Close()
    })
    $ErrorForm.CancelButton = $buttonCancel
    $ErrorForm.Controls.Add($buttonCancel)

    $ErrorForm.Topmost = $true
    $ErrorForm.ShowDialog()
} 

function ShowDownloadDialog {
    Add-Type -AssemblyName System.Windows.Forms

    # Create a form
    $VersionSelectionForm = New-Object System.Windows.Forms.Form
    $VersionSelectionForm.Text = "Download Dialog"
    $VersionSelectionForm.Size = New-Object System.Drawing.Size(410, 260)
    $VersionSelectionForm.StartPosition = 'CenterScreen'
    
    # Open the window atop other windows/dialog-boxes
    $VersionSelectionForm.Topmost = $true
    
    # Create 'project name' label
    $labelProject = New-Object System.Windows.Forms.Label
    $labelProject.Location = New-Object System.Drawing.Point(10, 30)
    $labelProject.Size = New-Object System.Drawing.Size(120, 20)
    $labelProject.Text = "Project Name:"
    $labelProject.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $labelProject.ForeColor = [System.Drawing.Color]::Black
    $VersionSelectionForm.Controls.Add($labelProject)
    
    # Create 'project name' dropdown list
    $dropDownListProject = New-Object System.Windows.Forms.ComboBox
    $dropDownListProject.Location = New-Object System.Drawing.Point(10, 50)
    $dropDownListProject.Size = New-Object System.Drawing.Size(350, 28)
    $dropDownListProject.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    # Add 'project names' to the dropdown list
    $dropDownListProject.Items.AddRange(@("bna.anexio.client", "bna.anexio.backend", "open.opc.client", "bna.anexio.import"))
    $VersionSelectionForm.Controls.Add($dropDownListProject)
    
    # Create 'job name' label
    $labelJob = New-Object System.Windows.Forms.Label
    $labelJob.Location = New-Object System.Drawing.Point(10, 100)
    $labelJob.Size = New-Object System.Drawing.Size(100, 20)
    $labelJob.Text = "Job Name:"
    $labelJob.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $labelJob.ForeColor = [System.Drawing.Color]::Black
    $VersionSelectionForm.Controls.Add($labelJob)
    
    # Create 'job name' dropdown list
    $dropDownListJob = New-Object System.Windows.Forms.ComboBox
    $dropDownListJob.Location = New-Object System.Drawing.Point(10, 120)
    $dropDownListJob.Size = New-Object System.Drawing.Size(350, 28)
    $dropDownListJob.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $VersionSelectionForm.Controls.Add($dropDownListJob)
    
    # Event handler to populate job names based on the selected project
    $dropDownListProject.Add_SelectedIndexChanged({
        # Call the function to get job names based on the project name. 
        $projectName = $dropDownListProject.SelectedItem.ToString()
        $jobNames = getJobs -projectName $projectName 
        
        # Clear the existing job names and add the new ones
        $dropDownListJob.Items.Clear()
        $dropDownListJob.Items.AddRange($jobNames)
    })
    
    # Create Download button
    $buttonDownload = New-Object System.Windows.Forms.Button
    $buttonDownload.Location = New-Object System.Drawing.Point(15, 180)
    $buttonDownload.Size = New-Object System.Drawing.Size(100, 30)
    $buttonDownload.Text = "Download"
    $buttonDownload.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
    $buttonDownload.ForeColor = [System.Drawing.Color]::White
    $buttonDownload.BackColor = [System.Drawing.Color]::DodgerBlue
    $buttonDownload.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $buttonDownload.Add_Click({
        $VersionSelectionForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $script:Mode = [DownloadOptions]::downloadArtifact
        $VersionSelectionForm.Close()
    })
    $VersionSelectionForm.AcceptButton = $buttonDownload
    $VersionSelectionForm.Controls.Add($buttonDownload)

    # Create Download & Replace button
    $buttonDownloadReplace = New-Object System.Windows.Forms.Button
    $buttonDownloadReplace.Location = New-Object System.Drawing.Point(150, 180)
    $buttonDownloadReplace.Size = New-Object System.Drawing.Size(200, 30)
    $buttonDownloadReplace.Text = "Download and Replace"
    $buttonDownloadReplace.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
    $buttonDownloadReplace.ForeColor = [System.Drawing.Color]::White
    $buttonDownloadReplace.BackColor = [System.Drawing.Color]::DodgerBlue
    $buttonDownloadReplace.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $buttonDownloadReplace.Add_Click({
        $VersionSelectionForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $script:Mode = [DownloadOptions]::downloadAndReplace 
        $VersionSelectionForm.Close()
    })
    $VersionSelectionForm.Controls.Add($buttonDownloadReplace)

    # Show the form
    $VersionSelectionForm.Topmost = $true
    $result = $VersionSelectionForm.ShowDialog()
    
    # Return the selected project name and job name if the 'Download' or 'Download-Replace' button is clicked
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedProjectName = $dropDownListProject.SelectedItem.ToString()
        $selectedJobName = $dropDownListJob.SelectedItem.ToString()
        
        # Check if the user has selected a project from the dropdown
        if ($null -eq $selectedProjectName -or $selectedProjectName -eq "") {
            Write-Host "Please select a project."
            Exit
        }
        
        # Check if the user has selected a job from the dropdown
        if ($null -eq $selectedJobName -or $selectedJobName -eq "") {
            Write-Host "Please select a job."
            Exit
        }

        return $selectedProjectName, $selectedJobName, $script:Mode
    }
    
}