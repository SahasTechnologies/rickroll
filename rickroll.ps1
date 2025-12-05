Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Media

# Download the MP3 to a temp file
$mp3Url = "https://github.com/SahasTechnologies/rickroll/raw/refs/heads/main/rickroll.mp3"
$tempFile = [System.IO.Path]::Combine($env:TEMP, "rickroll.mp3")
Invoke-WebRequest -Uri $mp3Url -OutFile $tempFile

# Use Windows Media Player COM object to play MP3
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = $tempFile
$player.controls.play()

# Show lyric popups
$wshell = New-Object -ComObject WScript.Shell
$lyrics = @(
    "Never gonna give you up",
    "Never gonna let you down",
    "Never gonna run around and desert you",
    "Never gonna make you cry",
    "Never gonna say goodbye",
    "Never gonna tell a lie and hurt you"
)

foreach ($line in $lyrics) {
    $wshell.Popup($line,0,"Rickroll",64)
}
