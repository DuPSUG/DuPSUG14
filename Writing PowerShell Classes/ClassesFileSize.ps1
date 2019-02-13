$DemoFolder = 'C:\scripts\dupsug\files' #Replace with your own Folder

#region Retrieving the Default FileSize in Bytes
Get-ChildItem $DemoFolder -Recurse -File |
Select-Object BaseName, @{Name='FileSize';Expression={$_.Length}}

#Maybe format Size as we process the files
Get-ChildItem $DemoFolder -Recurse -File |
Select-Object BaseName,
   @{Name='FileSizeKB';Expression={'{0:N2} {1}' -f ($_.Length/1kb), 'KB'}}
#endregion

#region FileSize with method added
$files = Get-ChildItem $DemoFolder -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
        BaseName = $_.BaseName
        Size = $_.Length
        FullName = $_.FullName
    } | 
    Add-Member ScriptMethod SizeMB {'{0:N2} {1}' -f ($This.Size/1mb), 'MB' } -PassThru |
    Add-Member ScriptMethod SizeKB {'{0:N2} {1}' -f ($This.Size/1kb), 'KB' } -PassThru |
    Add-Member ScriptMethod SizeGB {'{0:N2} {1}' -f ($This.Size/1gb), 'GB' } -PassThru
}

#We can select Format in KB
$files |
Select-Object BaseName,
   @{Name='FileSizeKB';Expression={$_.SizeKB()}} 

#Why not put all three side by side
$files |
Select-Object BaseName,
   @{Name='FileSizeKB';Expression={$_.SizeKB()}},
   @{Name='FileSizeMB';Expression={$_.SizeMB()}},
   @{Name='FileSizeGB';Expression={$_.SizeGB()}}
#endregion

#region FileSize with SizeFormatted method
$Files = Get-ChildItem $DemoFolder -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
        BaseName = $_.BaseName
        FullName = $_.FullName
        Size = $_.Length
    } | 
    Add-Member ScriptMethod SizeFormatted {
        '{0:N2} {1}' -f $(
            if ($This.Size -lt 1kb) { $This.Size, 'Bytes' }
            elseif ($This.Size -lt 1mb) { ($This.Size / 1kb), 'KB' }
            elseif ($This.Size -lt 1gb) { ($This.Size / 1mb), 'MB' }
            elseif ($This.Size -lt 1tb) { ($This.Size / 1gb), 'GB' }
            elseif ($This.Size -lt 1pb) { ($This.Size / 1tb), 'TB' }
            else { ($This.Size /1pb), 'PB' }
        )
    } -PassThru 
}

$Files | 
Select-Object BaseName, Size, @{Name ='Formatted'; Expression ={ $_.SizeFormatted()}}
#endregion

#region FileSize Class
Class FileSize{
    [String]$BaseName
    [String]$FullName
     [Int64]$FileSize
    [String]$FileSizeFormatted

    FileSize($fn){
        if(Test-Path $fn -PathType Leaf){
            $item = Get-ChildItem -Path $fn

            $this.FullName = $item.FullName
            $this.FileSize = $item.Length
            $this.BaseName = $item.BaseName
            $this.SizeFormatted()
        }
        else{
            Write-Warning -Message "File $($fn) doesn't exists"
        }
    }

    SizeFormatted() {
        $This.FileSizeFormatted = '{0:N2} {1}' -f $(
            if ($This.FileSize -lt 1kb) { $This.FileSize, 'Bytes' }
            elseif ($This.FileSize -lt 1mb) { ($This.FileSize/ 1kb), 'KB' }
            elseif ($This.FileSize -lt 1gb) { ($This.FileSize / 1mb), 'MB' }
            elseif ($This.FileSize -lt 1tb) { ($This.FileSize / 1gb), 'GB' }
            elseif ($This.FileSize -lt 1pb) { ($This.FileSize / 1tb), 'TB' }
            else { ($This.FileSize /1pb), 'PB' }
        )
    }

   static [String] SizeFormatted($fs) {
       return '{0:N2} {1}' -f $(
            if     ($fs -lt 1kb) {  $fs, 'Bytes' }
            elseif ($fs -lt 1mb) { ($fs / 1kb), 'KB' }
            elseif ($fs -lt 1gb) { ($fs / 1mb), 'MB' }
            elseif ($fs -lt 1tb) { ($fs / 1gb), 'GB' }
            elseif ($fs -lt 1pb) { ($fs / 1tb), 'TB' }
            else { ($fs /1pb), 'PB' }
        )
    }
}

Clear-Host
Get-ChildItem $DemoFolder -Recurse -File |
ForEach-Object{
    [FileSize]::new($_.FullName)
} |
Format-List

Clear-Host
Get-ChildItem $DemoFolder -Recurse -File |
ForEach-Object{
    [PSCustomObject]@{
      BaseName = $_.BaseName
      FileSize = [FileSize]::SizeFormatted($_.Length)
   }
}
#endregion