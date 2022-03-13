Write-Host "NOTE: Mako is still under development."
Write-Host "`nTo begin, press:"
Write-Host "[1] Init new starting point"
Write-Host "[2] Read existing starting point"

$mode = Read-Host -Prompt "Start mode ([1]/[2])"

Function generateHash($path) {
    $hash = Get-FileHash -Path $path -Algorithm SHA512
    return $hash
}

Function resetStartingPoint() {
    $point= Test-Path -Path .\starting-point.txt
    if($point) {
        #delete starting point
        Remove-Item -Path .\starting-point.txt
    }
}

if($mode -eq "1") {
    #if starting point exists already
    resetStartingPoint
    
    #calculate hashes for the target files and store in starting-point.txt
    Write-Host "[+] Calculating hashes. Create new starting point." -ForegroundColor Green

    #collect target files
    $target = Get-ChildItem -Path .
    
    #collect file hashes
    foreach($file in $target) {
        $hash = generateHash $file.FullName
        if($null -ne $hash.Hash) {
            "$($hash.Path) | $($hash.Hash)" | Out-File -FilePath .\starting-point.txt -Append
        }
    }

} elseif($mode -eq "2") {
    Write-Host "[!] Read existing starting-point.txt. Monitor target files" -ForegroundColor Yellow
    #load hash into hash table
    $hashTable = @{}
    $path_Hash = Get-Content -Path .\starting-point.txt
    foreach($pair in $path_Hash) {
        $hashTable.add($pair.Split("|")[0], $pair.Split("|")[1])
    }
 
    #monitor existing files with saved starting point
    while($true) {
        Start-Sleep -Seconds 5 
        Write-Host "Testing files..."
        $target = Get-ChildItem -Path . 
        foreach($file in $target) {
            $hash = Calculate-File-Hash $file.FullName
            if($null -eq $hashTable[$hash.Path]) {
                #new file created
                Write-Host "[+] $($hash.Path) has been created" -ForegroundColor Green
            }
        }
    }
} else {
    #display appropriate response
    Write-Host "[x] Mode does not exist. Please enter a valid mode." -ForegroundColor Magenta
} 