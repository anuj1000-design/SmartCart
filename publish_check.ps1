# SmartCart Publish Gatekeeper Script
# Run this script before building the APK for production

Write-Host "SmartCart Publish Gatekeeper Starting..." -ForegroundColor Green

# Step 1: Clean and get dependencies
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

# Step 2: Analyze code
Write-Host "Running flutter analyze..." -ForegroundColor Yellow
$analyzeResult = flutter analyze

# Check for errors, warnings, or hints
$hasIssues = $analyzeResult | Select-String -Pattern "error|warning|hint" -CaseSensitive:$false

if ($hasIssues) {
    Write-Host "Code analysis failed! Fix the following issues:" -ForegroundColor Red
    $analyzeResult | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
} else {
    Write-Host "Code analysis passed!" -ForegroundColor Green
}

# Step 3: Run all tests
Write-Host "Running all tests..." -ForegroundColor Yellow

# Verify critical test files exist
$criticalTests = @("test/models_test.dart", "test/app_logic_test.dart")
foreach ($test in $criticalTests) {
    if (-not (Test-Path $test)) {
        Write-Host "CRITICAL WARNING: Test file $test is missing!" -ForegroundColor Red
        # You might want to exit 1 here if these are mandatory, 
        # or just warn. specific to requirement
    } else {
        Write-Host "Found critical test: $test" -ForegroundColor DarkGray
    }
}

flutter test

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed! Fix the failing tests before publishing." -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed!" -ForegroundColor Green
}


# Step 4: Build release APK
Write-Host "Building release APK..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$buildDir = Join-Path -Path "releases" -ChildPath "PROD_BUILD_$timestamp"

# Create build directory
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
Write-Host "Created output directory: $buildDir" -ForegroundColor Cyan

flutter build apk --release --split-per-abi

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Move APKs to build directory
$apkPath = "build/app/outputs/flutter-apk"
if (Test-Path $apkPath) {
    Get-ChildItem -Path $apkPath -Filter "*.apk" | Copy-Item -Destination $buildDir
    Write-Host "APKs copied to $buildDir" -ForegroundColor Green
    
    # Generate checksums
    Get-ChildItem -Path $buildDir -Filter "*.apk" | ForEach-Object {
        $hash = Get-FileHash $_.FullName -Algorithm SHA256
        $hash.Hash | Out-File "$($_.FullName).sha256"
        Write-Host "Generated SHA256 for $($_.Name)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "Warning: Could not find APK output directory at $apkPath" -ForegroundColor Yellow
}

# Step 5: Move APK to production folder
Write-Host "Moving APK to production folder..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
Move-Item -Path "build\app\outputs\flutter-apk\*" -Destination $buildDir

Write-Host "SmartCart is ready for publishing!" -ForegroundColor Green
Write-Host "Production build available at: $buildDir" -ForegroundColor Cyan
Write-Host "APK files:" -ForegroundColor Cyan
Get-ChildItem $buildDir | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor Cyan }