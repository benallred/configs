if (Configured $forHome, $forWork, $forTest) {
    $driverArch = (Test-IsArm) ? "arm64" : "amd64"
    InstallFromGitHubAssetBlock imbushuo mac-precision-touchpad Drivers-$driverArch-ReleaseMSSigned.zip {
        pnputil /add-driver .\drivers\$driverArch\AmtPtpDevice.inf /install
    } {
        pnputil /enum-drivers | sls AmtPtpDevice.inf
    }

    InstallFromWingetBlock 9WZDNCRFJB8P # Surface

    Block "Install Keymapp" {
        Download-File https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.exe $env:tmp\keymapp-latest.exe
        . $env:tmp\keymapp-latest.exe /SILENT /NORESTART /LOG=$env:tmp\KeymappInstallLog.txt
    } {
        Test-ProgramInstalled Keymapp
    }

    Block "Install Razer Synapse" {
        Download-File https://rzr.to/synapse-3-pc-download $env:tmp\RazerSynapseInstaller.exe
        . $env:tmp\RazerSynapseInstaller.exe
        Write-ManualStep "Install only Razer Synapse (no optional modules)"
        WaitWhileProcess RazerInstaller
    }

    InstallFromWingetBlock Logitech.Options

    InstallFromGitHubBlock benallred qmk_firmware {
        git pull --unshallow
        git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
        git submodule update --init --recursive
        git remote add upstream_qmk https://github.com/qmk/qmk_firmware.git
        git remote add upstream_zsa https://github.com/zsa/qmk_firmware.git
        git co ben
    } -CloneDepth 1

    InstallFromGitHubAssetBlock qmk qmk_distro_msys QMK_MSYS.exe {
        Start-Process QMK_MSYS.exe "/silent" -Wait
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.hide_welcome=True"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.qmk_home=$($git -replace "\\", "/")/qmk_firmware"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk setup"
    } {
        Test-ProgramInstalled "QMK MSYS"
    }
}
