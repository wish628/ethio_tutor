param(
    [string]$KeystorePath = "$env:USERPROFILE\\my-release-key.jks",
    [string]$Alias = "my-key-alias",
    [int]$ValidityDays = 10000
)

Write-Host "This script will create a Java keystore for signing your Android app.\n"
Write-Host "Keystore path: $KeystorePath"
Write-Host "Alias: $Alias"

$prompt = Read-Host "Proceed and create keystore? (y/n)"
if ($prompt -ne 'y') { Write-Host 'Aborted.'; exit 1 }

# Run keytool
$keytool = 'keytool'
if (-not (Get-Command $keytool -ErrorAction SilentlyContinue)) {
    Write-Error "keytool not found. Please install Java JDK and ensure keytool is on PATH."
    exit 1
}

# Generate keystore interactively
& keytool -genkey -v -keystore $KeystorePath -alias $Alias -keyalg RSA -keysize 2048 -validity $ValidityDays

if ($LASTEXITCODE -eq 0) {
    Write-Host "Keystore created at: $KeystorePath"
    Write-Host "Copy `android/key.properties.template` to `android/key.properties` and fill in the values (do NOT commit it)."
} else {
    Write-Error "keytool failed with exit code $LASTEXITCODE"
}
