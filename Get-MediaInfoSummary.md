# <a name="Get-MediaInfoSummary"></a>Get-MediaInfoSummary
### SYNOPSIS
Get-MediaInfoSummary.ps1 -  - Shows a summary in text format for a media file.
### DESCRIPTION
Get-MediaInfoSummary.ps1 -  - Shows a summary in text format for a media file.
# PARAMETERS

### **-Path**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]

  ### **-Full**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\
Switch to show a extended summary.[-Full]

  ### **-Raw**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\
Switch to show not the friendly parameter names but rather the names as they are used in the MediaInfo API.[-Raw]

  ### **-RawParsed**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\


 #### EXAMPLE 1
```powershell
PS>Get-MediaInfoSummary 'D:\Samples\Downton Abbey.mkv'

Output the default Full media summary for the specified video.
```

