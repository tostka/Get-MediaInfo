#Get-MediaInfo.psm1
<#
.SYNOPSIS
Get-MediaInfo.psm1 - Get-MediaInfo is a PowerShell MediaInfo solution.
.NOTES
Version     : 3.7.3
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
# Get-MediaInfo

Get-MediaInfo is a PowerShell MediaInfo solution.

It consists of three functions:

- [Get-MediaInfo](#get-mediainfo)
- [Get-MediaInfoValue](#get-mediainfovalue)
- [Get-MediaInfoSummary](#get-mediainfosummary)
- [Get-MediaInfoRAW](#get-mediainforaw)

![-](Summary.jpg)

![-](GridView.png)


## Installation
------------

Installation or download via PowerShellGet:

No build provided for PSGallery. Options:
- Manually install repo files 
- Manually install the xxx.nupkg file: [Installing PowerShell scripts from a NuGet package](https://docs.microsoft.com/en-us/powershell/scripting/gallery/how-to/working-with-packages/manual-download?view=powershell-7.1#installing-powershell-scripts-from-a-nuget-package)
- Copy the \Packages\xxx.nupkg to a local share, configured with new-PsRepository, then install via install-module,
- or use Doug Finke's [Install-ModuleFromGitHub module](https://dfinke.github.io/powershell/2016/11/21/Quickly-Install-PowerShell-Modules-from-GitHub.html) to direct download from the repo and build a local module install.

.LINK
https://github.com/tostka/verb-XXX
#>

# add autodefs:
$script:ModuleRoot = $PSScriptRoot ;
$script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;

$script:videoExtensions = '264', '265', 'asf', 'avc', 'avi', 'divx', 'flv', 'h264', 'h265', 'hevc', 'm2ts', 'm2v', 'm4v',
    'mkv', 'mov', 'mp4', 'mpeg', 'mpg', 'mpv', 'mts', 'rar', 'ts', 'vob', 'webm', 'wmv'
$script:audioExtensions = 'aac', 'ac3', 'dts', 'dtshd', 'dtshr', 'dtsma', 'eac3', 'flac', 'm4a', 'mka', 'mp2', 'mp3',
    'mpa', 'ogg', 'opus', 'thd', 'w64', 'wav'
$script:cacheVersion    = 45
$script:culture         = [Globalization.CultureInfo]::InvariantCulture

function _convert-StringToInt($value)
{
    try {
        [int]::Parse($value, $culture)
    } catch {
        0
    }
}

function _convert-StringToDouble($value)
{
    try {
        [double]::Parse($value, $culture)
    } catch {
        0.0
    }
}

function _convert-StringToLong($value)
{
    try {
        [long]::Parse($value, $culture)
    } catch {
        [long]0
    }
}

#*------v Function _convert-BinaryToDecimalStorageUnits v------
Function _convert-BinaryToDecimalStorageUnits {
    <#
    .SYNOPSIS
    _convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 'kilo' is a prefix for base-10 or decimal numbers, which doesn't actually apply to that figure when it's a representation of a binary number (as memory etc represent). The correct prefix is instead kibi, so 1024 bits is really a kibibit.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : _convert-BinaryToDecimalStorageUnits.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    _convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 'kilo' is a prefix for base-10 or decimal numbers, which doesn't actually apply to that figure when it's a representation of a binary number (as memory etc represent). The correct prefix is instead kibi, so 1024 bits is really a kibibit.
    .PARAMETER Value
    String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .PARAMETER To
    Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']
    .PARAMETER Decimals
    decimal places of rounding[-Decimals 2]
    .OUTPUT
    decimal ize in converted decimal unit.
    .EXAMPLE
    $filesizeGB = '1.39 GiB' | _convert-BinaryToDecimalStorageUnits -To GB -Decimals 2;
    Example converting a binary Gibibyte value into a decimal gigabyte value, rounded to 2 decimal places.
    .LINK
    https://github.com/tostka/verb-IO
    #>

    #[Alias('convert-
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']")]
        #[ValidateNotNullOrEmpty()]
        [ValidatePattern("^([\d\.]+)((\s)*)([KMGTP]iB)$")]
        [string]$Value,
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']")]
        [validateset('Bytes','KB','MB','GB','TB')]
        [string]$To='MB',
        [Parameter(HelpMessage="decimal places of rounding[-Decimals 2]")]
        [int]$Decimals = 4
    )
    if($value.contains(' ')){
        $size,$unit = $value.split(' ') ;
    } else {
        #$size,$unit = $value -split '[KMGTP]' ;
        if($value  -match '^([\d\.]+)((\s)*)([KMGTP]iB)$'){
            $size = $matches[1] ;
            $unit = $matches[4] ;
        } ;
    }
    switch -regex ($unit){
        'PiB' {
            write-verbose "converting  PiB -> $($To)" ;
            $inBytes = ([double]$size * 1024 * 1024 * 1024 * 1024 * 1024) ;
        }
        'TiB' {
                # Tibibyte
                write-verbose "converting  TiB -> $($To)" ;
                $inBytes = ([double]$size * 1024 * 1024 * 1024 * 1024) ;
        }
        'GiB' {
            # gibibyte
            write-verbose "converting  GiB -> $($To)" ;
            $inBytes = ([double]$size * 1024 * 1024 * 1024) ;
        }
        'MiB' {
            # mebibyte (MiB):
            write-verbose "converting  MiB -> $($To)" ;
            # FileSize_String                577 MiB
            $inBytes = ([double]$size * 1024 * 1024 ) ;
        }
        'KiB' {
            write-verbose "converting  KiB -> $($To)" ;
            # kibibyte (KiB)
            # FileSize_String                577 MiB
            $inBytes = ([double]$size * 1024 ) ;
        }
    } ;
    switch($To){
        "Bytes" {$inBytes | write-output }
        "KB" {$output = $inBytes/1KB}
        "MB" {$output = $inBytes/1MB}
        "GB" {$output = $inBytes/1GB}
        "TB" {$output = $inBytes/1TB}
    } ;
    [Math]::Round($output,$Decimals,[MidPointRounding]::AwayFromZero) | write-output ;
} ;
#*------^ END Function _convert-BinaryToDecimalStorageUnits ^------

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
                        DAR            = _convert-StringToDouble $mi.GetInfo('Video', 0, 'DisplayAspectRatio')
                        Width          = _convert-StringToInt $mi.GetInfo('Video', 0, 'Width')
                        Height         = _convert-StringToInt $mi.GetInfo('Video', 0, 'Height')
                        BitRate        = (_convert-StringToInt $mi.GetInfo('Video', 0, 'BitRate')) / 1000
                        Duration       = (_convert-StringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        FileSize       = (_convert-StringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        FrameRate      = _convert-StringToDouble $mi.GetInfo('Video', 0, 'FrameRate')
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
                        Duration    = (_convert-StringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        BitRate     = (_convert-StringToInt $mi.GetInfo('Audio', 0, 'BitRate')) / 1000
                        FileSize    = (_convert-StringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
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
    Get-MediaInfoValue.ps1 - Returns specific properties from media files.
    .NOTES
    Version     : 3.7.2.0
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
    Get-MediaInfoValue.ps1 - Returns specific properties from media files.
    .PARAMETER  Path
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
    Get-MediaInfoSummary.ps1 -  - Shows a summary in text format for a media file.
    .NOTES
    Version     : 3.7.2.0
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
    Get-MediaInfoSummary.ps1 -  - Shows a summary in text format for a media file.
    .PARAMETER Path
    Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]
    .PARAMETER Full
    Switch to show a extended summary.[-Full]
    .PARAMETER Raw
    Switch to show not the friendly parameter names but rather the names as they are used in the MediaInfo API.[-Raw]
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
        [Switch]$Raw,
        [Parameter(ParameterSetName='Raw',HelpMessage="Switch to return object containing parsed version of the raw data output.[-RawParsed]")]
        [Switch]$RawParsed
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

#*------v Function Get-MediaInfoRAW v------
function Get-MediaInfoRAW
{
    <#
    .SYNOPSIS
    Get-MediaInfoRAW.ps1 - Returns an object reflecting all of the raw 'low-level' MediaInfo properties of a media file.
    .NOTES
    Version     : 3.7.2.0
    Author      : Frank Skare (stax76)
    Website     : https://stax76.github.io/frankskare/
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
    * 2:34 PM 10/16/2021 fixed $rgxTimeMMSS error, properly covers spurious spaces in the strings, expanded same to the $rgxTimeHHMM as well. Stronly [regex] typed the rgxs to force fails immed on load (rather silently went conversions fail and you get blank returns on some properties).
    * 7:44 PM 10/14/2021 added format string parser, adds an extra [property]_[unit] variant for the [property]_string values in the returned object.
    * 3:00 PM 10/9/2021 TK:variant of Get-MediaInfoSummary() that returns the full set of raw MediaInfo.dll properties, as an object.
    *3.7 7/31/21 - stax76's posted rev of orignal Get-MediaInfoSummary() lines
    .DESCRIPTION
    Created this variant because I want the full low-level range of MediaInfo.dll properties, and not simply a subset.
    So this function parses out the -RAW text returned, into a nested General|Video|Audio object
    .PARAMETER Path
    Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]
    .PARAMETER fixNames
    Switch to replace spaces and forward-slashes in default MediaInfo property names, with underscores (default's True)
    .EXAMPLE
    PS> $data = Get-MediaInfoRAW 'D:\Samples\Downton Abbey.mkv' ;
    Assign the Raw MediaInfo.dll properties for the specified video, as a System.Object to the $data variable.
    .LINK
    https://github.com/stax76/Get-MediaInfo
    .LINK
    https://github.com/tostka/Get-MediaInfo
    #>
    [CmdletBinding()]
    [Alias('gmir')]
    Param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [ValidateScript({Test-Path $_})]
        [string] $Path,
        [Parameter(HelpMessage="Default storage output units[Bytes|KB|MB|GB|TB].[-StorageUnits 'MB']")]
        [validateset('Bytes','KB','MB','GB','TB')]
        [string] $StorageUnits='MB',
        [Parameter(HelpMessage="Decimal places of rounding(where post-conversion occurs)[-Decimals 2]")]
        [int]$Decimals = 3,
        [Parameter(,HelpMessage="Switch to replace spaces in default MediaInfo property names, with underscores.(default's True).[-fixNames]")]
        [Switch]$fixNames = $true,
        [Parameter(,HelpMessage="Switch to disable additional conversion of string metrics to working numerics.[-fixNames]")]
        [Switch]$noPostConversion
    ) ;
    BEGIN{
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')

        [regex]$rgxKeyValue = '(.*)\s+:\s(.*)' ;
        [regex]$rgxRegion = '^(\w*)$' ;
        [regex]$rgxTimeHHMM = '^(?<Hours>\d+)((\s)*)h\s(?<Minutes>\d+)((\s)*)m((i)*)n$'
        [regex]$rgxTimeMMSS = '^(?<Minutes>\d+)((\s)*)m((i)*)n\s(?<Seconds>\d+)((\s)*)s$' # '25mn 53s', '21 min 38 s'
        [regex]$rgxDimensionPixels = '^(?<pixels>.*)\spixel((s)*)$' ; # 1 080 pixel
        [regex]$rgxKbps = '^(?<kbps>.*)\skb(/|p)s$' ;  # 2731 Kbps or 3 729 kb/s
        [regex]$rgxFrameRt = '^(?<framerate>.*)\sfps$' ; # 24.000 fps
        [regex]$rgxBit = '^(?<bit>.*)\sbit$';
        [regex]$rgxKHz = '^(?<khz>.*)\sKHz$'; # SamplingRate_String            48.0 KHz
        [regex]$rgxFileSizeBinary = '^(?<size>.*)\s(?<unit>((P|T|G|M|K)iB)|Bytes)$'

    }
    PROCESS{
        $mi = New-Object MediaInfoSharp -ArgumentList (Convert-Path -LiteralPath $Path) ;
        $value = $mi.GetSummary($false, $true) ;
        $mi.Dispose() ;
        $region = $null ;
        $hSummary = [ordered]@{
            General  = @();
            Video  = @();
            Audio  = @();
        } ;
        $hGeneral = [ordered]@{};
        $hVideo = [ordered]@{};
        $hAudio = [ordered]@{};
        
        $lines = $value.Split([Environment]::NewLine) | ?{$_.Length -gt 0} ;

        $regions = ($lines |?{$_.Length -gt 0})  -match $rgxRegion ; 
        # this code only supports a single stream per type, so test & warn:
        if(($regions | group | select -expand count) |?{$_ -gt 1}){
            $smsg = "$($Path)`ncontains more than a single 'stream' of 'General','Video' or 'Audio' type:`n$(($regions|out-string).trim())" ; 
            $smsg += "`nthe Get-MediaInfoRAW cmdlet does *not* support multi-stream files" ;
            $smsg += "`n(please try Get-MediaInfo, Get-MediaInfoSummary, or Get-MediaInfoValue)" ; 
            Write-Warning $smsg 
            break ; 
        } 

        $nGeneral= 0 ;
        $nVideo = 0 ; 
        $nAudio = 0 ;                 
        foreach($line in $lines){
            $TagParsed= $ValueParsed = $null ;
            switch -Regex ($line){
                $rgxRegion {
                    $region = $matches[0] ;
                    write-verbose "(region:$($region))" ;
                    switch ($region){
                        'General'{$nGeneral++ } 
                        'Video' {$nVideo++ }
                        'Audio' {$nAudio++ } ; 
                    } ;
                }; 
                $rgxKeyValue {
                    $key,$value = ($line-split $rgxKeyValue).Trim()|?{$_} ;
                    if($fixNames){
                        # sub out 'challenging' property name values with alts: \s, /, (, ), *
                        $key= $key -replace '(\s|\/)','_' -replace '(\(|\))','_'  -replace '\*','x'
                    } ;
                    # parse and convert fields for which we have format matches
                    switch -regex ($value){
                        #$rgxFileSizeBinary = '^(?<size>.*)\s(?<unit>((P|T|G|M|K)iB)|Bytes)$' ;
                        $rgxFileSizeBinary  {
                            $TagParsed = 'MB' ; # $matches.unit ; # no we're using common mb units
                            $ValueParsed  = $value | _convert-BinaryToDecimalStorageUnits -To $StorageUnits -Decimals $Decimal ;
                        }
                        #$rgxTimeHHMM = '^(?<Hours>\d+)h\s(?<Minutes>\d+)mn$' ; # 1h 37mn
                        $rgxTimeHHMM {
                            $ts = New-TimeSpan -Hours $matches.Hours -Minutes $matches.Minutes ;
                            $TagParsed= 'Mins' ;
                            $ValueParsed = $ts.TotalMinutes ;
                        }
                        #$rgxTimeMMSS = '^(?<Minutes>\d+)((\s)*)m((i)*)n\s(?<Seconds>\d+)((\s)*)s$' # '25mn 53s', '21 min 38 s'
                        $rgxTimeMMSS {
                            $ts = New-TimeSpan -Minutes $matches.Minutes -Seconds $matches.Seconds ;
                            $TagParsed= 'Mins' ;
                            $ValueParsed = $ts.TotalMinutes ;
                        }
                        #$rgxDimensionPixels = '^(?<pixels>.*)\spixel((s)*)$' ; # 1 080 pixel
                        $rgxDimensionPixels {
                            $TagParsed= 'Pixels' ;
                            $ValueParsed = $matches.pixels.replace(' ','') ;
                        }
                        #$rgxKbps = '^(?<kbps>.*)\skb(/|p)s$' ;  # 2731 Kbps or 3 729 kb/s
                        $rgxKbps {
                            $TagParsed= 'kbps' ;
                            $ValueParsed = $matches.kbps.replace(' ','') ;
                        }
                        #$rgxFrameRt = '^(?<framerate>.*)\sfps$' ; # 24.000 fps
                        $rgxFrameRt {
                            $TagParsed= 'fps' ;
                            $ValueParsed = $matches.framerate.replace(' ','') ;
                        }
                        #$rgxBit = '^(?<bit>.*)\sbit$';
                        $rgxBit {
                            $TagParsed= 'bit' ;
                            $ValueParsed = $matches.bit.replace(' ','') ;
                        }
                        #$rgxKHz = '^(?<khz>.*)\sKHz$'; # SamplingRate_String            48.0 KHz
                        $rgxKHz {
                            $TagParsed= 'bit' ;
                            $ValueParsed = $matches.khz.replace(' ','') ;
                        }
                        default{write-verbose "(unable to match `$value:$($value) to a parsable format" }
                    } # value parse

                    switch ($region){
                        'General' {
                            if($hGeneral.keys -contains $key){
                                write-host "skipping add of second General:$($key) property"
                            } else { 
                                $hGeneral.add($key,$value) ;
                                if($TagParsed -AND $ValueParsed -AND -not$noPostConversion){
                                    $keyAlt = ($key.split('_') | select -SkipLast 1) -join '_' ; 
                                    $keyAlt += "_$($TagParsed)" ; 
                                    if($hGeneral.keys -contains $keyAlt){
                                        write-host "skipping add of second General:$($keyAlt) property"
                                    } else { 
                                        $hGeneral.add($keyAlt,$ValueParsed) ;
                                    } ; 
                                } ;
                            } ; 
                            
                        }
                        'Video' {
                            if($hVideo.keys -contains $key){
                                write-host "skipping add of second Video:$($key) property"
                            } else { 
                                $hVideo.add($key,$value) ;
                                if($TagParsed -AND $ValueParsed -AND -not$noPostConversion){
                                    $keyAlt = ($key.split('_') | select -SkipLast 1) -join '_' ; 
                                    $keyAlt += "_$($TagParsed)" ; 
                                    if($hVideo.keys -contains $keyAlt){
                                        write-host "skipping add of second Video:$($keyAlt) property"
                                    } else { 
                                        $hVideo.add($keyAlt,$ValueParsed) ;
                                    } ; 
                                } ;
                            } ;                             
                            
                        }
                        'Audio' {
                            if($hAudio.keys -contains $key){
                                write-host "skipping add of second Audio:$($key) property"
                            } else { 
                                $hAudio.add($key,$value) ;
                                if($TagParsed -AND $ValueParsed -AND -not$noPostConversion){
                                    $keyAlt = ($key.split('_') | select -SkipLast 1) -join '_' ; 
                                    $keyAlt += "_$($TagParsed)" ; 
                                    if($hAudio.keys -contains $keyAlt){
                                        write-host "skipping add of second Audio:$($keyAlt) property"
                                    } else { 
                                        $hAudio.add($keyAlt,$ValueParsed) ;
                                    } ;                                 
                                } ;
                            } ;                                                            
                        } ;
                    } ; # region
                }  # key value
            } ; # switch line
        }  # loop-E ;
    } ;  # PROC-E
    END {
        # hash->object conversion 
        $oGeneral = [PSCustomObject]$hGeneral ; 
        $hSummary.general += $oGeneral ; 
        $oVideo = [PSCustomObject]$hVideo ; 
        $hSummary.video += $oVideo ; 
        $oAudio = [PSCustomObject]$hAudio
        $hSummary.audio += $oAudio; 
        New-Object PSObject -Property $hSummary | write-output ;
        
    } ;
} ;
#*------^ END Function Get-MediaInfoRAW  ^------


Export-ModuleMember -Function 'get-*' ;