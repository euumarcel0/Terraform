<powershell>
# Definindo diretórios temporários e de trabalho
$TEMP_DIR = $env:TEMP + "\installer_temp"
$workingFolder = "C:\temp\"
$packerFolder = "C:\DeployTemp\a\"

# Criando diretório temporário, se não existir
if (!(Test-Path -Path $TEMP_DIR -PathType Container)) {
    New-Item -Path $TEMP_DIR -ItemType Directory | Out-Null
}

# Baixando e instalando o Google Chrome
Write-Output "Baixando o instalador do Google Chrome..."
Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile "$TEMP_DIR\chrome_installer.exe"
Write-Output "Instalando o Google Chrome..."
Start-Process -FilePath "$TEMP_DIR\chrome_installer.exe" -ArgumentList "/silent", "/install" -Wait
Remove-Item -Path "$TEMP_DIR\chrome_installer.exe" -Force

# Baixando e instalando o Visual Studio Code
$vscode_installer_path = "$env:USERPROFILE\Downloads\vscode_installer.exe"
Write-Output "Baixando o instalador do Visual Studio Code..."
Invoke-WebRequest -Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' -OutFile $vscode_installer_path
Write-Output "Instalando o Visual Studio Code..."
Start-Process -FilePath $vscode_installer_path -ArgumentList "/silent", "/install" -Wait

# Configurando o ambiente para a instalação do Web Platform Installer e do Web Deploy
$webPIURL = "http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi"
$webPIInstaller = $workingFolder + "WebPlatformInstaller_amd64_en-US.msi"
$webPIExec = $env:ProgramFiles + "\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
$webDeployPackage = $packerFolder + "MyWebsite.API.zip"
$webDeployParams = $packerFolder + "MyWebsite.API.SetParameters.xml"

# Criando diretório de trabalho
New-Item $workingFolder -Type Directory -Force

# Instalando IIS e ASP.Net 4.5
Add-WindowsFeature Web-Server, Web-Asp-Net45

# Baixando e instalando o Web Platform Installer
Invoke-WebRequest $webPIURL -OutFile $webPIInstaller
Start-Process msiexec.exe -ArgumentList "/i $webPIInstaller /quiet" -NoNewWindow -Wait

# Instalando os componentes necessários com o Web Platform Installer
Start-Process $webPIExec -ArgumentList "/install /products:ASPNET45,ASPNET_REGIIS_NET4,WDeploy /AcceptEula" -NoNewWindow -Wait

# Encontrando o caminho de instalação do Web Deploy
$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select-Object -Last 1).GetValue("InstallPath") + "msdeploy.exe"

# Instalando a API Web usando o Web Deploy
cmd.exe /C "`"$MSDeployPath`" -verb:sync -source:package=`"$webDeployPackage`" -dest:auto,ComputerName=localhost -setParam:name='IIS Web Application Name',value='Default Web Site' -setParamFile:`"$webDeployParams`" 2> $workingFolder\err.log"

# Removendo o HTML inicial e adicionando o novo arquivo
Remove-Item C:\inetpub\wwwroot\iisstart.htm
Add-Content -Path "C:\inetpub\wwwroot\iisstart.htm" -Value ("Ola mundo de " + $env:computername)

Write-Output "Instalação concluída."
</powershell>