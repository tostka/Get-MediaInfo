# Get-MediaInfoRAW
## SYNOPSIS
Get-MediaInfoRAW.ps1 - Returns an object reflecting all of the raw 'low-level' MediaInfo properties of a media file.
## DESCRIPTION
Created this variant because I want the full low-level range of MediaInfo.dll properties, and not simply a subset.
So this function parses out the -RAW text returned, into a nested General|Video|Audio object
# PARAMETERS

## **-Path**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]

  ## **-StorageUnits**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-MB-Blue?color=5547a8)\


  ## **-Decimals**
> ![Foo](https://img.shields.io/badge/Type-Int32-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-3-Blue?color=5547a8)\


  ## **-fixNames**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-True-Blue?color=5547a8)\
Switch to replace spaces and forward-slashes in default MediaInfo property names, with underscores (default's True)

  ## **-noPostConversion**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\


 #### EXAMPLE 1
```powershell
PS>$data = Get-MediaInfoRAW 'D:\Samples\Downton Abbey.mkv' ;

Assign the Raw MediaInfo.dll properties for the specified video, as a System.Object to the $data variable.
```

