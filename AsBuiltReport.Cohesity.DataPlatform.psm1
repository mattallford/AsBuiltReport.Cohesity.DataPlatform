# Get public function definition files.
   $Public  = @( Get-ChildItem -Path $PSScriptRoot\Src\Public\*.ps1 -ErrorAction SilentlyContinue )
   $Private = @( Get-ChildItem -Path $PSScriptRoot\Src\Private\*.ps1 -ErrorAction SilentlyContinue )
# Dot source the files
   Foreach($Module in $Public + $Private)
   {
       Try
       {
           . $Module.fullname
       }
       Catch
       {
           Write-Error -Message "Failed to import function $($Module.fullname): $_"
       }
   }
# Export the Public modules
Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Function $Private.Basename