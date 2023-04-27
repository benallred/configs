param (
    [Parameter(Mandatory)]
    [ValidateSet("Start", "Stop", "Checkpoint", "Destroy", "Status", "Connect")]
    [string]
    $Action
)

$vmName = "configs Test VM"
$resetCheckpoint = "Post-install"
$vhdx = "C:\BenLocal\vhd\configs.vhdx"

$vm = Get-VM $vmName -ErrorAction Ignore

if ($Action -eq "Start") {
    if ($vm) {
        $connectProcess = Get-Process vmconnect -ErrorAction Ignore
        if ($connectProcess) {
            Stop-Process $connectProcess
        }
        Restore-VMSnapshot $vm -Name $resetCheckpoint -Confirm:$false
        Write-Output "Checkpoint '$resetCheckpoint' restored"
        Start-VM $vm
    }
    else {
        Write-Output "Creating VM '$vmName'"
        $vm = New-VM -Name $vmName -NewVHDPath $vhdx -NewVHDSizeBytes 60GB -MemoryStartupBytes 4GB -Generation 2 -SwitchName "Default Switch"
        Set-VMProcessor $vm.Name -Count 2 -ExposeVirtualizationExtensions $true
        Write-Output "Windows 11 download: https://www.microsoft.com/en-us/software-download/windows11"
        $dvdDrive = Add-VMDvdDrive $vm.Name -Path (Read-Host "Path to Windows ISO").Trim('"') -Passthru
        Set-VMFirmware $vm.Name -EnableSecureBoot On -BootOrder $dvdDrive, (Get-VMHardDiskDrive $vm.Name)
        Set-VMKeyProtector $vm.Name -NewLocalKeyProtector
        Enable-VMTPM $vm.Name
        Start-VM $vm
        Write-Output "Finish Windows install and return here before testing. Press Enter when ready."
        Start-Sleep -Seconds 3
        vmconnect $env:COMPUTERNAME $vm.Name
        Read-Host
        Set-VMDvdDrive $vm.Name -Path $null
        Checkpoint-VM $vm $resetCheckpoint
        Write-Output "Checkpoint '$resetCheckpoint' created"
    }

    Write-Output "Don't forget to stop the machine when done testing"
    if (!(Get-Process vmconnect -ErrorAction Ignore)) {
        Start-Sleep -Seconds 3
        vmconnect $env:COMPUTERNAME $vm.Name
    }
}
elseif ($Action -eq "Stop" -and $vm) {
    Stop-Process -Name vmconnect -ErrorAction Ignore
    Save-VM $vm
    Write-Output "Saved '$vmName'"
}
elseif ($Action -eq "Checkpoint" -and $vm) {
    Checkpoint-VM $vm (Read-Host "Checkpoint name")
}
elseif ($Action -eq "Destroy" -and $vm) {
    if ((Read-Host "Are you sure? You will have to go through the install process next time. (y/n)") -eq "y") {
        Stop-VM $vm -Force -ErrorAction Ignore
        Remove-VM $vm -Force
        Remove-Item $vhdx
        Write-Output "Removed '$vmName' and '$vhdx'"
    }
}
elseif ($Action -eq "Status") {
    if ($vm) {
        Write-Output $vm
    }
    else {
        Write-Output "'$vmName' not created"
    }
}
elseif ($Action -eq "Connect") {
    vmconnect $env:COMPUTERNAME $vm.Name
}
