param(
    $ProjectDir,
    $ProjectFileName,
    $LibrariesDirectory
)
if ($null -eq $LibrariesDirectory -Or $LibrariesDirectory -eq "") {
    $LibrariesDirectory = "E:\OTH_CODE\oLibraries"
}
Write-Host ("ProjectDir:" + $ProjectDir)
Write-Host ("ProjectFileName:" + $ProjectFileName)
Write-Host ("LibrariesDirectory:" + $LibrariesDirectory)
$csPath = $ProjectDir + '\' + $ProjectFileName
#$csPath = "E:\OTH_CODE\DH_CODE_MAIN\DH_ONGTRIEUHAU\PROJECT_HRM\HospitalHRM\RunCodeHRM\RunCodeHRM.csproj"
$oLibrariesPath = $LibrariesDirectory 
(Get-Content $csPath) | ForEach-Object {
    $line = $_.ToString()
    $newLine = $line
    if ($line.Contains('<HintPath>.') -And
        $line.Contains('</HintPath>') -And
        $line.Contains('.dll')) {
        $split = $line.Split('\')
        $fileName = $split[$split.Length - 1].Replace('</HintPath>', '')
        
        if ($fileName -ne '') {
            $root = [System.IO.Path]::GetDirectoryName($csPath)
            $searchFiles = Get-ChildItem $oLibrariesPath -Recurse -Include $fileName | Select-Object FullName, Name

            $findPath = ''
            try {
                $findPath = $searchFiles[0].FullName
            }
            catch {
                try {
                    $findPath = $searchFiles.FullName
                }
                catch {
                    $findPath = ''
                }                
            }
            if ($findPath -ne '') {
                try {
                    Write-Host $fileName
                    Write-Host ($findPath | ConvertTo-Json)
                    Set-Location $root
                    $newPath = (Resolve-Path -relative $findPath)
                    Write-Host ($newPath | ConvertTo-Json)
                    $newLine = '      <HintPath>' + $newPath + '</HintPath>'
                }
                catch {
                    $newLine = $line
                }
            }
        }
    }
    $newLine
} | Set-Content $csPath