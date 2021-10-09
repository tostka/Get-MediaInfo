#Get-MediaInfo.psm1
<#
.SYNOPSIS
Get-MediaInfo.psm1 - Get-MediaInfo is a PowerShell MediaInfo solution.
.NOTES
Version     : 3.7.1.1
Author      : Frank Skare (stax76)
Website     : https://stax76.github.io/frankskare/
Twitter     : 
CreatedDate : 2021-10-07
FileName    : 
License     : (none asserted)
Copyright   : (C) 2020-2021 Frank Skare (stax76). All rights reserved.
Github      : https://github.com/tostka/verb-XXX
Tags        : Powershell,mp3, media, video, audio,  
AddedCredit : Todd Kadrie
AddedWebsite: http://www.toddomation.com
AddedTwitter: @tostka / http://twitter.com/tostka
REVISIONS
*3.7.1.0 - forked vers: added CBH (to make get-help functional), spliced in readme examples, expanded Params, added validator); _-prefixed & script-scoped internal funcs (and added min CBH to pass pester); added .psm1 version & Export-ModuleMember, exporting solely the get-* funcs
*3.7 7/31/21 - stax76's posted rev
.DESCRIPTION
Get-MediaInfo.psm1 - Get-MediaInfo is a PowerShell MediaInfo solution.
[stax76/Get-MediaInfo: Get-MediaInfo is a PowerShell MediaInfo solution - github.com/](https://github.com/stax76/Get-MediaInfo)

Get-MediaInfo is a PowerShell MediaInfo solution.

It consists of three functions:

-   [Get-MediaInfo](https://github.com/stax76/Get-MediaInfo#get-mediainfo)
-   [Get-MediaInfoValue](https://github.com/stax76/Get-MediaInfo#get-mediainfovalue)
-   [Get-MediaInfoSummary](https://github.com/stax76/Get-MediaInfo#get-mediainfosummary)

[![-](https://github.com/stax76/Get-MediaInfo/raw/master/Summary.jpg)](https://github.com/stax76/Get-MediaInfo/blob/master/Summary.jpg)

[![-](https://github.com/stax76/Get-MediaInfo/raw/master/GridView.png)](https://github.com/stax76/Get-MediaInfo/blob/master/GridView.png)

## Installation

Installation or download via PowerShellGet:

[https://www.powershellgallery.com/packages/Get-MediaInfo](https://www.powershellgallery.com/packages/Get-MediaInfo)
.LINK
https://github.com/tostka/verb-XXX
#>

# add autodefs:
$script:ModuleRoot = $PSScriptRoot ;
$script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;

# flipped these to 'module private' scope
$script:videoExtensions = '264', '265', 'asf', 'avc', 'avi', 'divx', 'flv', 'h264', 'h265', 'hevc', 'm2ts', 'm2v', 'm4v', 
    'mkv', 'mov', 'mp4', 'mpeg', 'mpg', 'mpv', 'mts', 'rar', 'ts', 'vob', 'webm', 'wmv'
$script:audioExtensions = 'aac', 'ac3', 'dts', 'dtshd', 'dtshr', 'dtsma', 'eac3', 'flac', 'm4a', 'mka', 'mp2', 'mp3', 
    'mpa', 'ogg', 'opus', 'thd', 'w64', 'wav'
$script:cacheVersion    = 45
$script:culture         = [Globalization.CultureInfo]::InvariantCulture

function _convertStringToInt($value)
{
    <#
    .SYNOPSIS
    _convertStringToInt - Coerce a string to integer
    .NOTES
    REVISIONS
    8:28 PM 10/8/2021 ren'd with _ prefix (tag as private); added min CBH for pester passage
    .DESCRIPTION
    _convertStringToInt - Coerce a string to integer
    .PARAMETER  value
    String value to be coerced to integer
    .EXAMPLE
    PS> _convertStringToInt "1"
    #>
    try {
        [int]::Parse($value, $culture)
    } catch {
        0
    }
}

function _convertStringToDouble($value)
{
    <#
    .SYNOPSIS
    _convertStringToDouble - Coerce a string to double
    .NOTES
    REVISIONS
    8:28 PM 10/8/2021 ren'd with _ prefix (tag as private); added min CBH for pester passage
    .DESCRIPTION
    _convertStringToDouble - Coerce a string to double
    .PARAMETER  value
    String value to be coerced to double
    .EXAMPLE
    PS> _convertStringToDouble "4940656458"
    #>
    try {
        [double]::Parse($value, $culture)
    } catch {
        0.0
    }
}

function _convertStringToLong($value)
{
    <#
    .SYNOPSIS
    _convertStringToLong - Coerce a string to long
    .NOTES
    REVISIONS
    8:28 PM 10/8/2021 ren'd with _ prefix (tag as private); added min CBH for pester passage
    .DESCRIPTION
    _convertStringToLong - Coerce a string to long
    .PARAMETER  value
    String value to be coerced to long
    .EXAMPLE
    PS> _convertStringToLong "-9,223,372,036,854,775,808"
    #>
    try {
        [long]::Parse($value, $culture)
    } catch {
        [long]0
    }
}

#*------v Function Get-MediaInfo v------
function Get-MediaInfo
{
    <#
    .SYNOPSIS
    Get-MediaInfo - Converts media file objects into MediaInfo objects.
    .NOTES
    Version     : 3.7.1.1
    Author      : Frank Skare (stax76)
    Website     : https://stax76.github.io/frankskare/
    Twitter     : 
    CreatedDate : 2021-10-07
    FileName    : 
    License     : (none asserted)
    Copyright   : (C) 2020-2021 Frank Skare (stax76). All rights reserved.
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    *3.7.1.0 - forked vers: added CBH (to make get-help functional), spliced in readme examples, expanded Params, added validator)
    *3.7 7/31/21 - stax76's posted rev
    .DESCRIPTION
    Get-MediaInfo - Converts media file objects into MediaInfo objects.
    .PARAMETER Path
    String array with audio or video files or FileInfo objects via pipeline.[-Path D:\Samples]
    .PARAMETER Video
    Switch to cause only video files to be processed. [-Video]
    .PARAMETER Audio
    Switch to cause only audio files to be processed. [-Audio]
    .EXAMPLE
    PS> Get-ChildItem 'D:\Samples' | Get-MediaInfo | Out-GridView ; 
    Displays media files of the defined folder using a grid view.
    .EXAMPLE
    PS> gci | gmi | ogv ; 
    Same as first example but using the current folder and aliases.
    .EXAMPLE
    PS> gci | gmi | select filename, duration, filesize | 
        group duration | 
        where { $_.count -gt 1 } | 
        select -expand group | format-list ; 
    Find duplicates by comparing the duration.
    .LINK
    https://github.com/stax76/Get-MediaInfo   
    .LINK
    https://github.com/tostka/Get-MediaInfo
    #>
    [CmdletBinding(DefaultParameterSetName='Video')]
    [Alias('gmi')]
    Param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="String array with audio or video files or FileInfo objects via pipeline.[-Path D:\Samples]")]
        [Alias('FullName')]
        [string[]] $Path,
        [Parameter(ParameterSetName='Video',HelpMessage="Switch to cause only video files to be processed. [-Video]")]
        [Switch]$Video,
        [Parameter(ParameterSetName='Audio',HelpMessage="Switch to cause only audio files to be processed. [-Audio]")]
        [Switch]$Audio
    )    
    Begin
    {
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }

    Process
    {
        foreach ($file in $Path)
        {
            $file = Convert-Path -LiteralPath $file

            if (-not (Test-Path -LiteralPath $file -PathType Leaf))
            {
                continue
            }

            $extension = [IO.Path]::GetExtension($file).TrimStart([char]'.')
            $chacheFileBase = $file + '-' + (Get-Item -LiteralPath $file).Length + '-' + $cacheVersion

            foreach ($char in [IO.Path]::GetInvalidFileNameChars())
            {
                if ($chacheFileBase.Contains($char))
                {
                    $chacheFileBase = $chacheFileBase.Replace($char.ToString(), '-' + [int]$char + '-')
                }
            }

            $cacheFile = Join-Path ([IO.Path]::GetTempPath()) ($chacheFileBase + '.json')

            if (-not $Video -and -not $Audio)
            {
                if ($videoExtensions -contains $extension)
                {
                    $Video = $true
                }
                elseif ($audioExtensions -contains $extension)
                {
                    $Audio = $true
                }
            }

            if ($Video -and $videoExtensions -contains $extension)
            {
                if (Test-Path -LiteralPath $cacheFile)
                {
                    Get-Content -LiteralPath $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfoSharp -ArgumentList $file

                    $format = $mi.GetInfo('Video', 0, 'Format')

                    if ($format -eq 'MPEG Video')
                    {
                        $format = 'MPEG'
                    }

                    $obj = [PSCustomObject]@{
                        FileName       = [IO.Path]::GetFileName($file)
                        Ext            = $extension
                        Format         = $format
                        DAR            = _convertStringToDouble $mi.GetInfo('Video', 0, 'DisplayAspectRatio')
                        Width          = _convertStringToInt $mi.GetInfo('Video', 0, 'Width')
                        Height         = _convertStringToInt $mi.GetInfo('Video', 0, 'Height')
                        BitRate        = (_convertStringToInt $mi.GetInfo('Video', 0, 'BitRate')) / 1000
                        Duration       = (_convertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        FileSize       = (_convertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        FrameRate      = _convertStringToDouble $mi.GetInfo('Video', 0, 'FrameRate')
                        AudioCodec     = $mi.GetInfo('General', 0, 'Audio_Codec_List')
                        TextFormat     = $mi.GetInfo('General', 0, 'Text_Format_List')
                        ScanType       = $mi.GetInfo('Video',   0, 'ScanType')
                        Range          = $mi.GetInfo('Video',   0, 'colour_range')
                        Primaries      = $mi.GetInfo('Video',   0, 'colour_primaries')
                        Transfer       = $mi.GetInfo('Video',   0, 'transfer_characteristics')
                        Matrix         = $mi.GetInfo('Video',   0, 'matrix_coefficients')
                        FormatProfile  = $mi.GetInfo('Video',   0, 'Format_Profile')
                        Directory      = [IO.Path]::GetDirectoryName($file)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File -LiteralPath $cacheFile -Encoding UTF8
                    $obj
                }
            }
            elseif ($Audio -and $audioExtensions -contains $extension)
            {
                if (Test-Path -LiteralPath $cacheFile)
                {
                    Get-Content -LiteralPath $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfoSharp -ArgumentList $file

                    $obj = [PSCustomObject]@{
                        FileName    = [IO.Path]::GetFileName($file)
                        Ext         = $extension
                        Format      = $mi.GetInfo('Audio',   0, 'Format')
                        Performer   = $mi.GetInfo('General', 0, 'Performer')
                        Track       = $mi.GetInfo('General', 0, 'Track')
                        Album       = $mi.GetInfo('General', 0, 'Album')
                        Year        = $mi.GetInfo('General', 0, 'Recorded_Date')
                        Genre       = $mi.GetInfo('General', 0, 'Genre')
                        Duration    = (_convertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        BitRate     = (_convertStringToInt $mi.GetInfo('Audio', 0, 'BitRate')) / 1000
                        FileSize    = (_convertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        Directory   = [IO.Path]::GetDirectoryName($file)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File -LiteralPath $cacheFile -Encoding UTF8
                    $obj
                }
            }
        }
    }
}
#*------^ END Function Get-MediaInfo  ^------

#*------v Function Get-MediaInfoValue v------
function Get-MediaInfoValue
{
    <#
    .SYNOPSIS
    Get-MediaInfoValue - Returns specific properties from media files.
    .NOTES
    Version     : 1.0.0
    Author      : Frank Skare (stax76)
    Website     : https://stax76.github.io/frankskare/
    Twitter     : 
    CreatedDate : 2021-10-07
    FileName    : 
    License     : (none asserted)
    Copyright   : (C) 2020-2021 Frank Skare (stax76). All rights reserved.
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    *3.7.1.0 - forked vers: added CBH (to make get-help functional), added examples)
    *3.7 7/31/21 - stax76's posted rev
    .DESCRIPTION
    Get-MediaInfoValue - Returns specific properties from media files.
    .PARAMETER Path
    Path to a media file.[-Path D:\path-to\video.ext]
    .PARAMETER Kind
    A MediaInfo kind (General|Video|Audio|Text|Image|Menu).[-Kind Video]
    Kinds and their properties can be seen with MediaInfo.NET.
    .PARAMETER Index
    Zero based stream number.[-index 0]
    .PARAMETER Parameter
    Name of the property to get.[-param 'Performer']
    The property names can be seen with MediaInfo.NET with following setting enabled:
    Show parameter names as they are used in the MediaInfo API
    They can also be seen with Get-MediaInfoSummary with the -Raw flag enabled.
    .INPUT
    Input can be defined with the Path parameter, pipe input supports a path as string or a FileInfo object.
    .OUTPUT
    System.String
    Output will always be of type string and must be cast to other types like integer if necessary.
    .EXAMPLE
    PS> Get-MediaInfoValue '.\Meg Myers - Desire (Hucci Remix).mp3' -Kind General -Parameter Performer
        output: 
        Meg Myers
    Get the artist from a MP3 file.
    .EXAMPLE
    PS> '.\Meg Myers - Desire (Hucci Remix).mp3' | Get-MediaInfoValue -Kind Audio -Parameter 'Channel(s)'
        output:
        2
    Get the channel count in a MP3 file. Return types are always strings and if necessary must be cast to integer.
    .EXAMPLE
    Get-MediaInfoValue '.\The Warriors.mkv' -Kind Audio -Index 1 -Parameter 'Language/String'
        output:
        English
    Get the language of the second audio stream in a movie.
    The Index parameter is zero based.
    .EXAMPLE
    Get-MediaInfoValue '.\The Warriors.mkv' -Kind General -Parameter 'TextCount'
        output:
        2
    Get the count of subtitle streams in a movie.
    .EXAMPLE
    $mi = New-Object MediaInfo -ArgumentList $Path ;
    $value1 = $mi.GetInfo($Kind, $Index, $Parameter) ;
    $value2 = $mi.GetInfo($Kind, $Index, $Parameter) ;
    $mi.Dispose() ;
    To retrieve specific properties with highest possible performance the .NET class must be used directly:
    .LINK
    https://github.com/stax76/Get-MediaInfo   
    .LINK
    https://github.com/tostka/Get-MediaInfo
    #>
    [CmdletBinding()]
    [Alias('gmiv')]
    Param(        
        [Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file.[-Path D:\path-to\video.ext]")]        
        [ValidateScript({Test-Path $_})]
        [string] $Path,
        [Parameter(Mandatory=$true,HelpMessage="A MediaInfo kind (General|Video|Audio|Text|Image|Menu).[-Kind Video]")] 
        [ValidateSet('General', 'Video', 'Audio', 'Text', 'Image', 'Menu')]
        [String] $Kind,
        [Parameter(HelpMessage="Zero based stream number.[-index 0]")] 
        [int] $Index,
        [Parameter(Mandatory=$true,HelpMessage="Name of the property to get.[-param 'Performer']")]
        [string] $Parameter
    )

    begin
    {
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }

    Process
    {
        $mi = New-Object MediaInfoSharp -ArgumentList (Convert-Path -LiteralPath $Path)
        $value = $mi.GetInfo($Kind, $Index, $Parameter)
        $mi.Dispose()
        return $value
    }
}
#*------^ END Function Get-MediaInfoValue  ^------

#*------v Function Get-MediaInfoSummary v------
function Get-MediaInfoSummary
{
    <#
    .SYNOPSIS
    Get-MediaInfoSummary - Shows a summary in text format for a media file.
    .NOTES
    Version     : 1.0.0
    Author      : Frank Skare (stax76)
    Website     : https://stax76.github.io/frankskare/
    Twitter     : 
    CreatedDate : 2021-10-07
    FileName    : 
    License     : (none asserted)
    Copyright   : (C) 2020-2021 Frank Skare (stax76). All rights reserved.
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    *3.7.1.0 - forked vers: added CBH (to make get-help functional), added examples)
    *3.7 7/31/21 - stax76's posted rev
    .DESCRIPTION
    Get-MediaInfoSummary - Shows a summary in text format for a media file.
    .PARAMETER Path
    Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]
    .PARAMETER Full
    Switch to show a extended summary.[-Full]
    .PARAMETER Raw
    Switch to show not the friendly parameter names but rather the names as they are used in the MediaInfo API.[-Raw]
    .INPUT
    Path as string to a media file. Can also be passed via pipeline.
    .OUTPUT
    A summary line by line as string array.
    .EXAMPLE
    PS> Get-MediaInfoSummary 'D:\Samples\Downton Abbey.mkv'
    Output the default Full media summary for the specified video.
    .LINK
    https://github.com/stax76/Get-MediaInfo   
    .LINK
    https://github.com/tostka/Get-MediaInfo
    #>
    [CmdletBinding(DefaultParameterSetName='Full')]
    [Alias('gmis')]
    Param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]        
        [ValidateScript({Test-Path $_})]
        [string] $Path,
        [Parameter(ParameterSetName='Full',HelpMessage="Switch to show a extended summary.[-Full]")]
        [Switch]$Full,
        [Parameter(ParameterSetName='Raw',HelpMessage="Switch to show not the friendly parameter names but rather the names as they are used in the MediaInfo API.[-Raw]")]
        [Switch]$Raw
    )
    Begin
    {
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }
    Process
    {
        $mi = New-Object MediaInfoSharp -ArgumentList (Convert-Path -LiteralPath $Path)
        $value = $mi.GetSummary($Full, $Raw)
        $mi.Dispose()
        ("`r`n" + $value) -split "`r`n"
    }
}
#*------^ END Function Get-MediaInfoSummary  ^------

Export-ModuleMember -Function 'get-*' ; 