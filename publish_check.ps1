# ============================================================================
# SmartCart Production Publish Gatekeeper Script
# ============================================================================
# Run this script before building the APK for production release
# Validates code quality, tests, configuration, and builds production APK
# ============================================================================

$ErrorActionPreference = "Continue"
$script:failedChecks = @()
$script:warnings = @()

function Write-Status {
    param([string]$message, [string]$type = "info")
    
    switch ($type) {
        "success" { Write-Host "✅ $message" -ForegroundColor Green }
        "error" { 
            Write-Host "❌ $message" -ForegroundColor Red 
            $script:failedChecks += $message
        }
        "warning" { 
            Write-Host "⚠️  $message" -ForegroundColor Yellow 
            $script:warnings += $message
        }
        "info" { Write-Host "ℹ️  $message" -ForegroundColor Cyan }
        "step" { Write-Host "`n🔹 $message" -ForegroundColor Magenta }
        default { Write-Host $message }
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       SmartCart Production Publish Gatekeeper v2.0          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================================================
# STEP 1: Environment Validation
# ============================================================================
Write-Status "STEP 1: Validating Development Environment" "step"

# Check Flutter installation
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
    Write-Status "Flutter installed: $flutterVersion" "success"
} else {
    Write-Status "Flutter is not installed or not in PATH!" "error"
}

# Check Firebase CLI
if (Get-Command firebase -ErrorAction SilentlyContinue) {
    Write-Status "Firebase CLI is installed" "success"
} else {
    Write-Status "Firebase CLI not found (optional for deployment)" "warning"
}

# ============================================================================
# STEP 2: File Structure Validation
# ============================================================================
Write-Status "STEP 2: Validating Project Structure" "step"

# Critical files
$criticalFiles = @(
    "pubspec.yaml",
    "lib/main.dart",
    "lib/firebase_options.dart",
    "android/app/google-services.json",
    "firestore.rules",
    "firebase.json"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Status "Found: $file" "success"
    } else {
        Write-Status "Missing critical file: $file" "error"
    }
}

# ============================================================================
# STEP 3: Test Coverage Validation
# ============================================================================
Write-Status "STEP 3: Validating Test Suite" "step"

$testFiles = @(
    "test/models_test.dart",
    "test/app_logic_test.dart",
    "test/app_state_provider_test.dart",
    "test/auth_service_test.dart",
    "test/checkout_flow_test.dart",
    "test/product_tests.dart",
    "test/integration_test.dart",
    "test/performance_test.dart",
    "test/security_test.dart"
)

$missingTests = 0
foreach ($test in $testFiles) {
    if (Test-Path $test) {
        Write-Status "Found test: $test" "success"
    } else {
        Write-Status "Missing test file: $test" "warning"
        $missingTests++
    }
}

if ($missingTests -gt 0) {
    Write-Status "$missingTests test files are missing" "warning"
}

# ============================================================================
# STEP 4: Firebase Configuration Check
# ============================================================================
Write-Status "STEP 4: Validating Firebase Configuration" "step"

# Check google-services.json
if (Test-Path "android/app/google-services.json") {
    $googleServices = Get-Content "android/app/google-services.json" -Raw | ConvertFrom-Json
    $projectId = $googleServices.project_info.project_id
    Write-Status "Firebase Project: $projectId" "success"
} else {
    Write-Status "google-services.json not found!" "error"
}

# Check Firestore rules
if (Test-Path "firestore.rules") {
    $rulesContent = Get-Content "firestore.rules" -Raw
    if ($rulesContent -match "allow read, write") {
        Write-Status "Firestore rules file exists (verify security rules)" "warning"
    } else {
        Write-Status "Firestore rules file found" "success"
    }
} else {
    Write-Status "firestore.rules not found!" "error"
}

# ============================================================================
# STEP 5: Clean Build Environment
# ============================================================================
Write-Status "STEP 5: Cleaning Build Environment" "step"

Write-Host "Running flutter clean..." -ForegroundColor Gray
flutter clean | Out-Null
Write-Status "Build cleaned" "success"

Write-Host "Running flutter pub get..." -ForegroundColor Gray
flutter pub get | Out-Null
Write-Status "Dependencies fetched" "success"

# ============================================================================
# STEP 6: Code Analysis
# ============================================================================
Write-Status "STEP 6: Running Code Analysis" "step"

$analyzeOutput = flutter analyze 2>&1
$analyzeText = $analyzeOutput | Out-String

# Check for errors
if ($analyzeText -match "(\d+) issue[s]? found") {
    $issueCount = $matches[1]
    if ([int]$issueCount -gt 0) {
        Write-Status "Found $issueCount code issues" "error"
        Write-Host $analyzeText -ForegroundColor Red
    } else {
        Write-Status "No analysis issues found" "success"
    }
} elseif ($analyzeText -match "No issues found") {
    Write-Status "Code analysis passed" "success"
} else {
    Write-Status "Unable to parse analysis results" "warning"
}

# ============================================================================
# STEP 7: Run Test Suite
# ============================================================================
Write-Status "STEP 7: Running Complete Test Suite" "step"

Write-Host "Executing all tests..." -ForegroundColor Gray
$testOutput = flutter test 2>&1
$testText = $testOutput | Out-String

if ($LASTEXITCODE -eq 0) {
    # Extract test count
    if ($testText -match "\+(\d+):") {
        $testCount = $matches[1]
        Write-Status "All $testCount tests passed!" "success"
    } else {
        Write-Status "All tests passed!" "success"
    }
} else {
    Write-Status "Tests failed! Fix failing tests before publishing" "error"
    Write-Host $testText -ForegroundColor Red
}

# ============================================================================
# STEP 8: Security Validation
# ============================================================================
Write-Status "STEP 8: Security Checks" "step"

# Check for hardcoded secrets
$securityPatterns = @(
    @{Pattern = "AIzaSy[A-Za-z0-9_-]{33}"; Description = "Google API Key"},
    @{Pattern = "sk_live_[A-Za-z0-9]{24,}"; Description = "Stripe Live Key"},
    @{Pattern = "password\s*=\s*['\"][^'\"]+['\"]"; Description = "Hardcoded Password"}
)

$securityIssues = 0
foreach ($pattern in $securityPatterns) {
    $securityMatches = Get-ChildItem -Path lib -Filter *.dart -Recurse | 
        Select-String -Pattern $pattern.Pattern -CaseSensitive
    
    if ($securityMatches) {
        Write-Status "Found potential $($pattern.Description) in code" "warning"
        $securityIssues++
    }
}

if ($securityIssues -eq 0) {
    Write-Status "No obvious security issues detected" "success"
}

# ============================================================================
# STEP 9: Version Check
# ============================================================================
Write-Status "STEP 9: Version Information" "step"

if (Test-Path "pubspec.yaml") {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    if ($pubspec -match "version:\s*([0-9]+\.[0-9]+\.[0-9]+)") {
        $version = $matches[1]
        Write-Status "App Version: $version" "info"
    }
}

# ============================================================================
# STEP 10: Build Production APK
# ============================================================================
Write-Status "STEP 10: Building Production APK" "step"

if ($script:failedChecks.Count -gt 0) {
    Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║              ❌ BUILD BLOCKED - CRITICAL ERRORS              ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Red
    
    Write-Host "Failed Checks:" -ForegroundColor Red
    foreach ($check in $script:failedChecks) {
        Write-Host "  • $check" -ForegroundColor Red
    }
    
    if ($script:warnings.Count -gt 0) {
        Write-Host "`nWarnings:" -ForegroundColor Yellow
        foreach ($warning in $script:warnings) {
            Write-Host "  • $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n⛔ Fix all errors before building production APK!" -ForegroundColor Red
    exit 1
}

Write-Status "All checks passed! Proceeding with build..." "success"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$buildDir = Join-Path -Path "releases" -ChildPath "PROD_BUILD_$timestamp"

# Create build directory
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
Write-Status "Created build directory: $buildDir" "info"

Write-Host "`nBuilding release APK (split per ABI)..." -ForegroundColor Gray
flutter build apk --release --split-per-abi

if ($LASTEXITCODE -ne 0) {
    Write-Status "APK build failed!" "error"
    exit 1
}

Write-Status "APK build completed successfully" "success"

# ============================================================================
# STEP 11: Package Build Artifacts
# ============================================================================
Write-Status "STEP 11: Packaging Build Artifacts" "step"

$apkPath = "build/app/outputs/flutter-apk"
if (Test-Path $apkPath) {
    # Copy APKs
    Get-ChildItem -Path $apkPath -Filter "*.apk" | ForEach-Object {
        Copy-Item $_.FullName -Destination $buildDir
        Write-Status "Packaged: $($_.Name)" "success"
        
        # Generate SHA256 checksum
        $hash = Get-FileHash $_.FullName -Algorithm SHA256
        $hashFile = Join-Path $buildDir "$($_.Name).sha256"
        $hash.Hash | Out-File $hashFile
        Write-Status "Generated SHA256 checksum" "success"
    }
    
    # Generate build info
    $buildInfo = @{
        version = $version
        buildTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        flutterVersion = (flutter --version | Select-String "Flutter" | Select-Object -First 1).ToString()
        testsPassed = $true
        buildType = "release"
    }
    
    $buildInfoFile = Join-Path $buildDir "build_info.json"
    $buildInfo | ConvertTo-Json | Out-File $buildInfoFile
    Write-Status "Generated build_info.json" "success"
    
} else {
    Write-Status "Could not find APK output directory!" "error"
    exit 1
}

# ============================================================================
# FINAL REPORT
# ============================================================================
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          ✅ SmartCart Ready for Production Release!          ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Status "Production Build Location: $buildDir" "info"

Write-Host "`n📦 Build Artifacts:" -ForegroundColor Cyan
Get-ChildItem $buildDir | ForEach-Object { 
    $size = if ($_.Extension -eq ".apk") { 
        " ({0:N2} MB)" -f ($_.Length / 1MB) 
    } else { "" }
    Write-Host "   ✓ $($_.Name)$size" -ForegroundColor White 
}

if ($script:warnings.Count -gt 0) {
    Write-Host "`n⚠️  Warnings (non-critical):" -ForegroundColor Yellow
    foreach ($warning in $script:warnings) {
        Write-Host "   • $warning" -ForegroundColor Yellow
    }
}

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Test the APK on physical devices" -ForegroundColor White
Write-Host "   2. Deploy Firebase rules: firebase deploy --only firestore:rules" -ForegroundColor White
Write-Host "   3. Upload to Google Play Console" -ForegroundColor White
Write-Host "   4. Monitor Firebase Analytics and Crashlytics" -ForegroundColor White

Write-Host "`n✨ Build completed successfully at $(Get-Date -Format 'HH:mm:ss')`n" -ForegroundColor Green

exit 0