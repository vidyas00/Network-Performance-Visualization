# Description
Network-Data-Visualization is a tool used to visualize the data produced by various network performance analysis tools. Currently, the project supports NTTTCP, LATTE, and CTStraffic. 
# Installation
## Manual Installation
Download this repo to your machine, and then move the Network-Performance-Visualization folder to C:\Program Files\WindowsPowerShell\Modules. After moving the folder, run the following command:
```PowerShell
Install-Module Network-Performance-Visualization
```
This should import the `New-Visualization` command from the module. You can double check that the module has been properly installed by running:
```PowerShell
Get-Module -ListAvailable
```
and checking that `Network-Performance-Visualization` is listed among the available modules.
# Usage
For help and options when running this command directly, use:
```PowerShell
Get-Help Network-Performance-Visualization
```
# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
