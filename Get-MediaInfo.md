# Get-MediaInfo
## SYNOPSIS
Get-MediaInfo - Converts media file objects into MediaInfo objects.
## DESCRIPTION
Get-MediaInfo - Converts media file objects into MediaInfo objects.
# PARAMETERS

## **-Path**
> ![Foo](https://img.shields.io/badge/Type-String[]-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-TRUE-Red?) \
String array with audio or video files or FileInfo objects via pipeline.[-Path D:\Samples]

  ## **-Video**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\
Switch to cause only video files to be processed. [-Video]

  ## **-Audio**
> ![Foo](https://img.shields.io/badge/Type-SwitchParameter-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-FALSE-Green?) ![Foo](https://img.shields.io/badge/DefaultValue-False-Blue?color=5547a8)\
Switch to cause only audio files to be processed. [-Audio]

 #### EXAMPLE 1
```powershell
PS>Get-ChildItem 'D:\Samples' | Get-MediaInfo | Out-GridView ;

Displays media files of the defined folder using a grid view.
```
 #### EXAMPLE 2
```powershell
PS>gci | gmi | ogv ;

Same as first example but using the current folder and aliases.
```
 #### EXAMPLE 3
```powershell
PS>gci | gmi | select filename, duration, filesize |

group duration |
where { $_.count -gt 1 } |
select -expand group | format-list ;
Find duplicates by comparing the duration.
```

