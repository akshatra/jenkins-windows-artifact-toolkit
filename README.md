# jenkins-windows-artifact-toolkit

"JenkinsArtifactDownloader" is a versatile PowerShell script that enables you to easily download the 'Last Successful Artifact' from a specified Jenkins project and branch name. This script simplifies artifact management and enhances control and automation in deployment workflows. It supports both GUI and command-line modes, providing users with the flexibility they need.

## Features
- **Download Artifact Mode**: Retrieve specific artifacts by selecting the project and job name (artifact version) from Jenkins.
- **Download and Replace Artifact Mode**: Automatically replace previously installed versions with the newly downloaded artifact by specifying target locations on the operating system within the code.
- **User-Friendly Interface**: Offers an intuitive UI for easy navigation and interaction, even for users with limited PowerShell experience.

## How to Use
1. Clone or download the repository.
2. Run the `main.ps1` script.
3. Select the desired mode and provide the necessary information (project name*, job name*, mode).
4. Follow the prompts and let the script handle the artifact retrieval and installation process.

## Example
Running an image in GUI mode.
![image](https://github.com/akshatra/jenkins-windows-artifact-toolkit/assets/47113617/a73fb817-5a64-4e93-aeae-0e7351b9e23e)

## Requirements
- PowerShell 5.1 or later
- Access to a Jenkins server

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests for any improvements or bug fixes.

## License
This project is licensed under the [MIT License](LICENSE).

## Contact
For any inquiries or feedback, please contact akshatrabhatt@gmail.com
