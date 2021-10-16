# Get-MediaInfoValue
## SYNOPSIS
Get-MediaInfoValue.ps1 - Returns specific properties from media files.
## DESCRIPTION
Get-MediaInfoValue.ps1 - Returns specific properties from media files.
# PARAMETERS

## **-Path**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
Path to a media file.[-Path D:\path-to\video.ext]

  ## **-Kind**
> ![Foo](https://img.shields.io/badge/Type-String-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
A MediaInfo kind (General|Video|Audio|Text|Image|Menu).[-Kind Video] Kinds and their properties can be seen with MediaInfo.NET.

  ## **-Index**
> ![Foo](https://img.shields.io/badge/Type-Int32-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-0-Blue?color=5547a8)\
Zero based stream number.[-index 0]

  ## **-Parameter**
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

