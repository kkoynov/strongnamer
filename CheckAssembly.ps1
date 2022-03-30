
Function Check-Assembly{
    [CmdletBinding()]
    Param(
    [Parameter(ValueFromPipeline)]
    [string[]]$items)
    
    Process  
    {
            $result = (& cmd.exe /c sn -vf $_)
            $isSigned = "NO";
            if($result -like "*test-signed*")
            {
                $isSigned = "Delay Signed";
            }
            if($result -like "* valid")
            {
                $isSigned = "Signed"
            }

            if( -not($isSigned -eq "NO"))
            {
                $pkt = (& cmd.exe /c sn -Tp $_)
                $pkt = $pkt | Select-String -Pattern "Public key token is *"
                $pkt = ([string]$pkt).SubString(20);
            }
            $path = (pwd).Path + "\"+ $_
            $version = (Get-Command $path).FileVersionInfo.FileVersion

            #$processArchitecture = [reflection.assemblyname]::GetAssemblyName("${pwd}\$_") | select -Property "ProcessorArchitecture";

            return  [PSCustomObject]@{Assembly = $_; IsSigned = $isSigned;PublicKeyToken=$pkt; ProductName = ( Get-ItemProperty $_).VersionInfo.ProductName; Version = $version}
    }
}

#Usage example
Write-Host SingedAssemblyCheck Sample Usage: @'
ls | where {$_.extension -eq ".dll" -or $_.extension -eq ".exe"} | Check-Assembly | Format-Table -AutoSize
'@
Write-Host 

Write-Host Or just call "Check-Assemblies"" to get report for all .dll and .exe files in the current working directory
Function Check-Assemblies{
ls | where {$_.extension -eq ".dll" -or $_.extension -eq ".exe"} | Check-Assembly | Format-Table -AutoSize
}