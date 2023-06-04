#Requires -RunAsAdministrator

#########################User Editable Section#########################
$SnapraidConfig = "snapraid.conf"
$scrubdays = @("Sunday")

#Comma list of drives/Mount Paths to Ignore. Must end with \
#ie, C:\, S:\, C:\mnt\Drive1\, etc
$IgnoreDrives = @(
    "C:\", "S:\", "C:\mnt\1-4\", "C:\mnt\2-4\"
)

#Programs to use for each action
#If using snapraid-helper, use snapraid_shadow.conf as the config file
#in snapraid-helper.ini
$TouchCommand= ".\snapraid.exe"
$TouchParams = "touch"
$SyncCommand = ".\snapraid-helper.ps1"
$SyncParams = ""#"-N"
$ScrubCommand = ".\snapraid-helper.ps1"
$ScrubParams = 'syncandscrub -scrubpercent 20'

#######################################################################

# Not really meant to be customized below 

#Set to Script Path
$scriptPath = (Split-Path $MyInvocation.MyCommand.Path)
Set-Location -Path $scriptPath

#Get List of available drives/mountpoints
$MountedDrives = @()

Get-CimInstance Win32_Volume -Filter "DriveType='3'" | ForEach-Object {
    if ($IgnoreDrives -notcontains $_.Name -and
        $_.Name -inotlike "\\?\*"
    )
    {
        $MountedDrives += $_.Name.TrimEnd('\')
    }
}
#Write-Host "Mounted Drives: $($MountedDrives)"

#Drive Array, Holds information about the SnapRaid Data Disk
$DataDrives = @()

Write-Host "Reading $($SnapraidConfig)"
#Read the SnapRaid Config
[array] $SnapraidConfig = Get-Content $SnapraidConfig
for($i=0; $i -lt $SnapraidConfig.Length; $i++)
{
    # Find Disk Sections
    if ($SnapraidConfig[$i].StartsWith("disk") -or $SnapraidConfig[$i].StartsWith("data"))
    {
        $SnapRaidDrive = ""
        #Split the line by spaces
        #[0] disk
        #[1] d#
        #[2] drive/mount path
        $Disk = $SnapraidConfig[$i].Split(" ")

        #Test if the disk path is part of any of existing drive mounts
        foreach ($MDrive in $MountedDrives)
        {
            if ($Disk[2].StartsWith($MDrive))
            {
                $SnapRaidDrive = $MDrive
            }
        }
        if ($SnapRaidDrive -eq "") {
            Write-Host "A data disk was found in $SnapraidConfig, but it doesn't appear to be correct?"
            Write-Host "Or my shitty programmer can't do string comparisons right."
            Write-Host "It's something to do with the following line:"
            Write-Host "$SnapraidConfig[$i]"
            continue 
        } #Didn't find one, skip it
        
        #Collect and store the Data Disk Information
        $DataDrive = [PSCustomObject]@{
            ShadowID = "" #To be filled in later
            OrigDrive = "$($SnapraidDrive)"
            #Anything after the driveletter such as Drivepool's PoolPart.GUID folder name
            MiscPath = $Disk[2].Replace($SnapraidDrive,"")
            #Our Temporary mounting point for the Data Disk Shadow
            ShadowPath = "C:\SnapRaid_Shadow_$($Disk[1])"
        }
        # Add to Drive Array
        $DataDrives += $DataDrive

        #Edit Data Disk lines for Shadow Copy Location, Will be saved as a separate config file
        $Disk[2] = "$($DataDrive.ShadowPath)$($DataDrive.MiscPath)"
        $SnapraidConfig[$i] = $Disk -join " "
    }
}
#Save the shadow config version
Write-Host "Saving Shadow Copy version of snapraid configuration"
#$SnapraidConfig | Out-File "snapraid_shadow.conf" -Encoding "UTF8"
[System.IO.File]::WriteAllLines("$scriptPath\snapraid_shadow.conf", $SnapraidConfig)

#Create and Mount Shadow Copies. Save the ID of the Shadow Copy for later removal
Write-Host "Creating and Mounting Shadow Copies"
for($i=0; $i -lt $DataDrives.Length; $i++)
{
    #Create New Shadow Copy. New-ShadowCopy returns an object. Just need the ID
    $DataDrives[$i].ShadowID = (New-ShadowCopy -Drive $DataDrives[$i].OrigDrive -Confirm:$false | Select-Object -ExpandProperty Id)
    #MOUNT IT
    Mount-ShadowCopy -Id $DataDrives[$i].ShadowID -Path $DataDrives[$i].ShadowPath -Confirm:$false
}


#Touching actual files. Will Sync/scrub based on shadow copies
Write-Host "Running SnapRaid Touch"
Invoke-Expression -command "$TouchCommand $TouchParams"

$DoW = (get-date).DayOfWeek
if ($scrubdays -contains $DoW)
{
    Write-Host "Running Snapraid Sync & Scrub"
    Invoke-Expression -command "$ScrubCommand $ScrubParams"
} 
else
{
    Write-Host "Running Snapraid Sync"
    Invoke-Expression -command "$SyncCommand $SyncParams"
}

#Unmount and Remove Shadows
Write-Host "Unmounting & Removing Shadows"
for($i=0; $i -lt $DataDrives.Length; $i++)
{
    Unmount-ShadowCopy -Path $DataDrives[$i].ShadowPath -Confirm:$false
    Remove-ShadowCopy -Id $DataDrives[$i].ShadowID -Confirm:$false
}

Write-Host "Finished"
