[CmdletBinding()]  
  param
  (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName = "$env:COMPUTERNAME",

    [Parameter(Mandatory=$true)]
    [pscredential] $Credential
  )

configuration InstallVSRemoteDebugger
{
  [CmdletBinding()]  
  param
  (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName = "$env:COMPUTERNAME"
  )
  
  Import-DscResource -ModuleName xNetworking

  Node $ComputerName
  {    
  
    File f
    {
      DestinationPath = "$env:windir\\Rtools"
      Ensure = 'Present'
      Type = 'Directory'
    }
    
    Script Download
    {
      TestScript = {Test-Path "$env:windir\rtools\Rtools.exe"}
      SetScript = {Invoke-WebRequest -Uri 'https://download.microsoft.com/download/E/7/A/E7AEA696-A4EB-48DD-BA4A-9BE41A402400/rtools_setup_x64.exe' -OutFile "$env:windir\\Rtools\\Rtools.exe"}
      GetScript = {return @{}}
    }  
    
    WindowsProcess Install
    {
      Path = "$env:windir\Rtools\Rtools.exe"
      Ensure = 'Present'
      Arguments = '/install /quiet /log /norestart rtools_Setup.txt'      
    }
    
    xFirewall AllowVSRemoteDebugger
    {
      Name = 'VS–RemoteDebugging'
      Program = "$env:ProgramFiles\Microsoft Visual Studio 14.0\Common7\IDE\Remote Debugger\x64\msvsmon.exe"
      Ensure = 'Present'
      Profile = 'Domain'
    }
  }
}

Invoke-Command -ComputerName $ComputerName {
  Install-Module xNetWorking -Verbose -Force -Confirm:$false
}

InstallVSRemoteDebugger -ComputerName $ComputerName
Start-DscConfiguration .\InstallVSRemoteDebugger -ComputerName $ComputerName -Credential $Credential -Wait -Force
