# SnapRaid-ShadowCopy
A basic Powershell Script to setup leverage shadowcopys of SnapRaid data drives.
Needs to be edited manually for now
As it is written now, requires snapraid-helper, but could be edited to fit one's needs. Runs snapraid touch prior to syncing. On Sundays, it will sync and scr

### Requirements
- [Shadow Copy powershell cmdlets](https://www.powershellgallery.com/packages/CPolydorou.ShadowCopy/ "Shadow Copy powershell cmdlets")
  - I believe these do not work with Powershell 7 due to Get-WMI being obsoleted. Works with Windows' built in Powershell
- (Optional) Snapraid-Helper

### Crude Instructions
- Place SnapRaid-ShadowCopy.ps1 with Snapraid
- Install the Shadow Copy Cmdlets as Administrator
    > Install-Module -Name CPolydorou.ShadowCopy
  
- Edit SnapRaid-ShadowCopy.ps1
   - In the User Editable Section:
     - Add Drives to be ignored (non-snapraid data disk, like parity and OS)
     - Select days you want scrubs to occur as a comma separated list (ie "Sunday","Tuesday","Friday")
     - Edit Command/Parameter to your liking
 
Run script as a daily task with administrative privliges.
 
 
 
 
 
 
 
 
 
 
