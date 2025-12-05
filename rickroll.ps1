# Rickroll.ps1
# Plays MP3 from GitHub and shows lyric popups

# Create Windows Media Player COM object
$player = New-Object -ComObject WMPlayer.OCX
$player.URL = "https://github.com/SahasTechnologies/rickroll/raw/refs/heads/main/rickroll.mp3"
$player.controls.play()

# Popup lyrics
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
