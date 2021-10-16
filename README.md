
Get-MediaInfo
=============

Get-MediaInfo is a PowerShell MediaInfo solution.

It consists of three functions:

- [Get-MediaInfo](#get-mediainfo)
- [Get-MediaInfoValue](#get-mediainfovalue)
- [Get-MediaInfoSummary](#get-mediainfosummary)
- [Get-MediaInfoRAW](#get-mediainforaw)

![-](Summary.jpg)

![-](GridView.png)


Installation
------------

Installation or download via PowerShellGet:

No build provided for PSGallery. Options:
- manually install repo files 
- copy the \Packages\xxx.nupkg to a local share, configured with new-PsRepository, then install via install-module,
- or use Doug Finke's [Install-ModuleFromGitHub module](https://dfinke.github.io/powershell/2016/11/21/Quickly-Install-PowerShell-Modules-from-GitHub.html) to direct download from the repo and build a local module install.


# <a name="Get-MediaInfoRAW"></a>Get-MediaInfoRAW
### SYNOPSIS
Get-MediaInfoRAW.ps1 - Returns an object reflecting all of the raw 'low-level' MediaInfo properties of a media file.
### DESCRIPTION
Created this variant because I want the full low-level range of MediaInfo.dll properties, and not simply a subset.
So this function parses out the -RAW text returned, into a nested General|Video|Audio object
# PARAMETERS

### **-Path**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]

  ### **-StorageUnits**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-MB-Blue?color=5547a8)\


  ### **-Decimals**
> ![Foo](https://img.shields.io/badge/Type-Int32-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-3-Blue?color=5547a8)\


  ### **-fixNames**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-True-Blue?color=5547a8)\
Switch to replace spaces and forward-slashes in default MediaInfo property names, with underscores (default's True)

  ### **-noPostConversion**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\


 #### EXAMPLE 1
```powershell
PS>$data = Get-MediaInfoRAW 'D:\Samples\Downton Abbey.mkv' ;

Assign the Raw MediaInfo.dll properties for the specified video, as a System.Object to the $data variable.
```

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

# <a name="Get-MediaInfoValue"></a>Get-MediaInfoValue
### SYNOPSIS
Get-MediaInfoValue.ps1 - Returns specific properties from media files.
### DESCRIPTION
Get-MediaInfoValue.ps1 - Returns specific properties from media files.
# PARAMETERS

### **-Path**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Path to a media file.[-Path D:\path-to\video.ext]

  ### **-Kind**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
A MediaInfo kind (General|Video|Audio|Text|Image|Menu).[-Kind Video] Kinds and their properties can be seen with MediaInfo.NET.

  ### **-Index**
> ![Foo](https://img.shields.io/badge/Type-Int32-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-0-Blue?color=5547a8)\
Zero based stream number.[-index 0]

  ### **-Parameter**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Name of the property to get.[-param 'Performer'] The property names can be seen with MediaInfo.NET with following setting enabled: Show parameter names as they are used in the MediaInfo API They can also be seen with Get-MediaInfoSummary with the -Raw flag enabled.

 #### EXAMPLE 1
```powershell
PS>Get-MediaInfoValue '.\Meg Myers - Desire (Hucci Remix).mp3' -Kind General -Parameter Performer

output:
Meg Myers
Get the artist from a MP3 file.
```
 #### EXAMPLE 2
```powershell
PS>'.\Meg Myers - Desire (Hucci Remix).mp3' | Get-MediaInfoValue -Kind Audio -Parameter 'Channel(s)'

output:
2
Get the channel count in a MP3 file. Return types are always strings and if necessary must be cast to integer.
```
 #### EXAMPLE 3
```powershell
PS C:\>Get-MediaInfoValue '.\The Warriors.mkv' -Kind Audio -Index 1 -Parameter 'Language/String'

output:
English
Get the language of the second audio stream in a movie.
The Index parameter is zero based.
```
 #### EXAMPLE 4
```powershell
PS C:\>Get-MediaInfoValue '.\The Warriors.mkv' -Kind General -Parameter 'TextCount'

output:
2
Get the count of subtitle streams in a movie.
```
 #### EXAMPLE 5
```powershell
PS C:\>$mi = New-Object MediaInfo -ArgumentList $Path ;

$value1 = $mi.GetInfo($Kind, $Index, $Parameter) ;
$value2 = $mi.GetInfo($Kind, $Index, $Parameter) ;
$mi.Dispose() ;
To retrieve specific properties with highest possible performance the .NET class must be used directly:
```

