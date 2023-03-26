$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
$url = "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64-webinstall.exe"
$output = "python-3.8.10-amd64-webinstall.exe"

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

# Get python version or error
$p = & { python -V } 2>&1
$version = if ($p -is [System.Management.Automation.ErrorRecord]) {
    $p.Exception.Message
}
else {
    $p.Split(" ")[-1]
}

# Check if Python is already installed
if (-not (Is-Numeric $version)) {
    Write-Host "Downloading python installer..."
    # Download Python 3.8 installer
    Invoke-WebRequest -Uri $url -OutFile $output
    
    # Install Python 3.8
    Write-Host "Installing python..."
    $process = Start-Process -FilePath $output -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1" -PassThru

    while (!$process.HasExited) {
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 1
    }
    Write-Host " Done!"

    # Update path to include the newly installed python
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
else {
    Write-Host "Python is installed"
}

# Check for requests package, install if needed
$null = pip show requests
if ( -not $? ) {
    pip install requests --trusted-host pypi.org --trusted-host files.pythonhosted.org
}

# Start the script
python ./vWAN_automation.py
