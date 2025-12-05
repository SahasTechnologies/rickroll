# Rickroll.ps1
# Plays MP3 from GitHub and shows lyric popups with continuous volume control
# Secret escape hatch: Ctrl+Shift+Q  #secret hotkey
# Also sets desktop wallpaper

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import user32.dll for wallpaper change
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Save current wallpaper path
$regPath = "HKCU:\Control Panel\Desktop"
$originalWallpaper = (Get-ItemProperty -Path $regPath).WallPaper

# Change wallpaper to Rickroll image
$url = "https://raw.githubusercontent.com/SahasTechnologies/rickroll/refs/heads/main/wallpaper.png"
$tempFile = "$env:TEMP\rickwallpaper.png"
Invoke-WebRequest -Uri $url -OutFile $tempFile
[Wallpaper]::SystemParametersInfo(20, 0, $tempFile, 3)

# Create Windows Media Player COM object
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = "https://github.com/SahasTechnologies/rickroll/raw/refs/heads/main/rickroll.mp3"
$player.controls.play()

# Save original volume and set to 50
$originalVol = $player.settings.volume
$player.settings.volume = 50

# Popup lyrics
$wshell = New-Object -ComObject WScript.Shell
$lyrics = @(
    "We're no strangers to love",
    "You know the rules and so do I",
    "A full commitment's what I'm thinkin' of",
    "You wouldn't get this from any other guy",

    "I just wanna tell you how I'm feeling",
    "Gotta make you understand",

    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you",

    "We've known each other for so long",
    "Your heart's been aching, but you're too shy to say it",
    "Inside, we both know what's been goin' on",
    "We know the game, and we're gonna play it",

    "And if you ask me how I'm feeling",
    "Don't tell me you're too blind to see",

    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you",
    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you",

    "Ooh (Give you up)",
    "Ooh-ooh (Give you up)",
    "(Ooh-ooh)",
    "Never gonna give, never gonna give (Give you up)",
    "(Ooh-ooh)",
    "Never gonna give, never gonna give (Give you up)",

    "We've known each other for so long",
    "Your heart's been aching, but you're too shy to say it",
    "Inside, we both know what's been goin' on",
    "We know the game, and we're gonna play it",

    "I just wanna tell you how I'm feeling",
    "Gotta make you understand",

    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you",
    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you",
    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you"
)

# Start background job to monitor volume
$job = Start-Job -ScriptBlock {
    param($player,$wshell)
    while ($true) {
        Start-Sleep -Milliseconds 500
        $currentVol = $player.settings.volume
        if ($currentVol -lt 50) {
            if ($currentVol -ge 95) {
                $player.settings.volume = 100
            } else {
                $player.settings.volume = [math]::Min($currentVol + 5, 100)
            }
            $wshell.Popup("Hey, you can't mute it, nice try though. Penalty: +5 Volume",0,"Rickroll",48)
        }
    }
} -ArgumentList $player,$wshell

# Invisible hotkey listener
$form = New-Object Windows.Forms.Form
$form.ShowInTaskbar = $false
$form.WindowState = 'Minimized'
$form.Opacity = 0
$form.KeyPreview = $true
$form.Add_KeyDown({
    if ($_.Control -and $_.Shift -and $_.KeyCode -eq [System.Windows.Forms.Keys]::Q) {
        # Stop everything
        Stop-Job $job -Force
        Remove-Job $job
        $player.controls.stop()
        $player.settings.volume = $originalVol
        # Restore original wallpaper
        [Wallpaper]::SystemParametersInfo(20, 0, $originalWallpaper, 3)
        $form.Close()
    }
})

# Run lyric popups while form listens for hotkey
foreach ($line in $lyrics) {
    $wshell.Popup($line,0,"Rickroll",64)
}

# Keep invisible listener alive until closed by hotkey
[System.Windows.Forms.Application]::Run($form)
