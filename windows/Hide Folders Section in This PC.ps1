function HideFolderInThisPC($folderId) {
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{$folderId}" /f *>&1 | Out-Null
}

(
    "088e3905-0323-4b02-9826-5d99428e115f", # Downloads
    "0DB7E03F-FC29-4DC6-9020-FF41B59E513A", # 3D Objects
    "24ad3ad4-a569-4530-98e1-ab02f9417aa8", # Pictures
    "3dfdf296-dbec-4fb4-81d1-6a3438bcf4de", # Music
    "B4BFCC3A-DB2C-424C-B029-7FE99A87C641", # Desktop
    "d3162b92-9365-467a-956b-92703aca08af", # Documents
    "f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a"  # Videos
) | % { HideFolderInThisPC $_ }
