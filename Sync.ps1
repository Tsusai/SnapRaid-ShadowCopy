#Install ShadowCopy utilities with 'Install-Module -Name CPolydorou.ShadowCopy'
$scriptPath = (Split-Path $MyInvocation.MyCommand.Path)
Set-Location -Path $scriptPath

$scriptPath = $scriptPath + "\snapraid-helper.ps1"

#Touch
Invoke-Expression -command ".\snapraid touch"

Write-Host "Creating Shadows"
#Repeat for each data drive. Can take Drive letter or mount path
$shadow1 = New-ShadowCopy -Drive "C:\mnt\HDD1" -Confirm:$false
$shadow2 = New-ShadowCopy -Drive "C:\mnt\HDD2" -Confirm:$false

Write-Host "Mounting Shadows"
#Repeat for each shadow/datadrive
Mount-ShadowCopy -Id $shadow1.Id -Path "C:\DataShadow1" -Confirm:$false
Mount-ShadowCopy -Id $shadow2.Id -Path "C:\DataShadow2" -Confirm:$false

$DoW = (get-date).DayOfWeek
if ($DoW -eq "Sunday")
{
    Write-Host "Sync & Scrub"
    $params = 'syncandscrub -scrubpercent 20'
    Invoke-Expression -command "$scriptPath $params"
} 
else
{
    Write-Host "Normal Sync"
    $params = '-N'
    Invoke-Expression -command "$scriptPath $params"
}

Write-Host "Unmounting Shadows"
#Repeat for each shadow/datadrive
Unmount-ShadowCopy -Path "C:\DataShadow1" -Confirm:$false
Unmount-ShadowCopy -Path "C:\DataShadow2" -Confirm:$false

Write-Host "Removing Shadows"
#Repeat for each shadow/datadrive
Remove-ShadowCopy -Id $shadow1.Id -Confirm:$false
Remove-ShadowCopy -Id $shadow2.Id -Confirm:$false