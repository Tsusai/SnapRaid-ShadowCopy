# SnapRaid-ShadowCopy
A basic Powershell Script to setup leverage shadowcopys of SnapRaid data drives.
Needs to be edited manually for now
As it is written now, requires snapraid-helper, but could be edited to fit one's needs. Runs snapraid touch prior to syncing. On Sundays, it will sync and scr

### Requirements
- [Shadow Copy powershell cmdlets](https://www.powershellgallery.com/packages/CPolydorou.ShadowCopy/ "Shadow Copy powershell cmdlets")
- Snapraid-Helper (Script could be rewritten to not use this)

### Crude Instructions
- Install the Shadow Copy Cmdlets
 - Run Powershell as an Administrator
    > Install-Module -Name CPolydorou.ShadowCopy
  
- Copy existing *SnapRaid.conf* to *SnapRaid-Shadow.conf*
SnapRaid-Shadow.conf will be used when syncing

- Edit SnapRaid-Shadow.conf
 - For each data disk, change the drive letter/mount to C:\DataShadow#
 Works with drives mounted as letters or in folders, and Drivepool Paths
 
 - Examples
   - DrivePool Example:
     > data d1 F:\PoolPart.0bbf942c-ec26-43de-80a7-991710a64511

     > data d2 C:\mnt\HDD2\PoolPart.cd009fd4-2ea6-4afb-ab47-96a1a5d71e2e

     Should be written as
     > data d1 C:\DataShadow1\PoolPart.0bbf942c-ec26-43de-80a7-991710a64511

     > data d2 C:\DataShadow2\PoolPart.cd009fd4-2ea6-4afb-ab47-96a1a5d71e2e
   - Regular Drive Example
     > data d1 E:\

     > data d2 F:\

     Should be written as
     > data d1 C:\DataShadow1

     > data d2 C:\DataShadow2
- If using Snapraid-Helper
 - Edit snapraid-helper.ini
  - Find and edit SnapRAIDConfig to snapraid_shadow.conf
    > SnapRAIDConfig=snapraid_shadow.conf

- Edit Sync.ps1
  -  For each section that states to repeat, add a line for each Data Drive
   - New-ShadowCopy: Make sure you reference the real drives
     > $shadow1 = New-ShadowCopy -Drive "F:\" -Confirm:$false
     > 
     > $shadow2 = New-ShadowCopy -Drive "c:\mnt\HDD2" -Confirm:$false
 - Mount-ShadowCopy, Unmount-ShadowCopy, Remove-ShadowCopy
  Repeat increasing the number for each data drive
  
  Run script as a daily task with administrative privliges.
 
 
 
 
 
 
 
 
 
 
