# Intune Documentation

Automatic Intune Documentation to simplify the life of admins and consultants.

This Script will document:

 - Configuration Policies
 - Compliance Policies
 - Device Enrollment Restrictions
 - Terms and Conditions
 - Applications (Only Assigned)
 - Application Protection Policies
 - AutoPilot Configuration
 - Enrollment Page Configuration
 - Apple Push Certificate
 - Apple VPP
 - Device Categories
 - Exchange Connector


# Usage

Download the DocumentIntune.ps1 file and execute it with PowerShell.exe:

``` powershell

powershell.exe -executionpolicy bypass -file Invoke-IntuneDocumentation.ps1

```

The Documentation will be created in the same folder like the Invoke-IntuneDocumentation.ps1 file resides.

**Important:** Before using the Script the first time, you have to ensure, that you have installed the Microsoft.Graph.Intune and PSWord Module. To do that, you have to start PowerShell as an Adminstrator and install them:

```powershell

Install-Module Microsoft.Graph.Intune
Install-Module PSWord

```

# Issues / Feedback

For any issues or feedback related to this module, please register for GitHub, and post your inquiry to this project's issue tracker.

# Thanks to

@Microsoftgraph for the PowerShell Examples: https://github.com/microsoftgraph/powershell-intune-samples

@guidooliveira for the PSWord Module, which enables the creation of the Word file. https://github.com/guidooliveira/PSWord

@joslieben for extending and improving the script

@dads07a for adding Application protection Policies to the documentation

@mirkocolemberg for the help and testing of the script.

![Created by baseVISION](https://www.basevision.ch/wp-content/uploads/2015/12/baseVISION-Logo_RGB.png)
