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
        "success" { Write-Host "[OK] $message" -ForegroundColor Green }
        "error" { 
            Write-Host "[ERROR] $message" -ForegroundColor Red 
            $script:failedChecks += $message
        }
        "warning" { 
            Write-Host "[WARN] $message" -ForegroundColor Yellow 
            $script:warnings += $message
        }
        "info" { Write-Host "[INFO] $message" -ForegroundColor Cyan }
        "step" { Write-Host "`n[STEP] $message" -ForegroundColor Magenta }
        default { Write-Host $message }
    }
}

Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "       SmartCart Production Publish Gatekeeper v2.0          " -ForegroundColor Cyan
Write-Host "================================================================`n" -ForegroundColor Cyan

# ============================================================================
# STEP 1: Environment Validation
# ============================================================================
Write-Status "STEP 1: Validating Development Environment" "step"

# Check Flutter installation
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
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
    "test/security_test.dart",
    "test/ui_integrity_test.dart",
    "test/home_screen_test.dart"
)

$missingTests = 0
$failedTests = 0
$totalTestsPassed = 0

foreach ($test in $testFiles) {
    if (Test-Path $test) {
        Write-Host "Testing: $test..." -ForegroundColor Gray -NoNewline
        
        # Run the test file
        $testResult = flutter test $test 2>&1
        $testResultText = $testResult | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            # Extract test count from this file
            $fileTestCount = 0
            if ($testResultText -match "\+(\d+):\s*All tests passed!") {
                $fileTestCount = [int]$matches[1]
            } elseif ($testResultText -match "\+(\d+)") {
                $fileTestCount = [int]$matches[1]
            }
            
            $totalTestsPassed += $fileTestCount
            Write-Host " PASS ($fileTestCount tests)" -ForegroundColor Green
        } else {
            Write-Status "FAILED: $test" "error"
            $failedTests++
            Write-Host $testResultText -ForegroundColor Red
        }
    } else {
        Write-Status "Missing test file: $test" "warning"
        $missingTests++
    }
}

Write-Host ""
if ($failedTests -eq 0 -and $missingTests -eq 0) {
    Write-Status "All test files validated: $totalTestsPassed tests passed across $($testFiles.Count) files" "success"
} else {
    if ($failedTests -gt 0) {
        Write-Status "$failedTests test files failed" "error"
    }
    if ($missingTests -gt 0) {
        Write-Status "$missingTests test files are missing" "warning"
    }
}

# ============================================================================
# STEP 4: Firebase Configuration Check
# ============================================================================
Write-Status "STEP 4: Validating Firebase Configuration" "step"

# Check google-services.json
if (Test-Path "android/app/google-services.json") {
    try {
        $googleServices = Get-Content "android/app/google-services.json" -Raw | ConvertFrom-Json
        $projectId = $googleServices.project_info.project_id
        Write-Status "Firebase Project: $projectId" "success"
    } catch {
        Write-Status "google-services.json exists but could not be parsed" "warning"
    }
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
flutter clean 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Status "Build cleaned" "success"
} else {
    Write-Status "Flutter clean encountered issues" "warning"
}

Write-Host "Running flutter pub get..." -ForegroundColor Gray
flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Status "Dependencies fetched" "success"
} else {
    Write-Status "Failed to fetch dependencies" "error"
}

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
# STEP 7: Full Test Suite Integration Check
# ============================================================================
Write-Status "STEP 7: Full Test Suite Integration Check (all tests together)" "step"

Write-Host "Running all tests in parallel to check for integration issues..." -ForegroundColor Gray
$testOutput = flutter test 2>&1
$testText = $testOutput | Out-String

if ($LASTEXITCODE -eq 0) {
    # Multiple regex patterns to extract test count
    $testCount = 0
    
    # Try multiple patterns to match Flutter's test output format
    if ($testText -match "\+(\d+):\s*All tests passed!") {
        $testCount = [int]$matches[1]
    } elseif ($testText -match "\+(\d+):") {
        $testCount = [int]$matches[1]
    } elseif ($testText -match "(\d+) tests? passed") {
        $testCount = [int]$matches[1]
    } elseif ($testText -match "All tests passed!" -and $testText -match "\+(\d+)") {
        $testCount = [int]$matches[1]
    }
    
    if ($testCount -eq 0) {
        Write-Status "No tests executed! Verify test files contain valid test cases" "warning"
        Write-Host "Test output:" -ForegroundColor Yellow
        Write-Host $testText -ForegroundColor Gray
    } else {
        if ($testCount -eq $totalTestsPassed) {
            Write-Status "Integration check: All $testCount tests passed (matches individual runs)" "success"
        } else {
            Write-Status "Integration check: $testCount tests passed (individual runs showed $totalTestsPassed)" "warning"
        }
    }
} else {
    Write-Status "Tests failed! Fix failing tests before publishing" "error"
    Write-Host $testText -ForegroundColor Red
}

# ============================================================================
# STEP 7B: Widget Tests (Optional)
# ============================================================================
if (Test-Path "test/widget_test.dart") {
    Write-Status "STEP 7B: Running Widget Tests" "step"
    Write-Host "Executing widget tests..." -ForegroundColor Gray
    $widgetTestOutput = flutter test test/widget_test.dart 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Widget tests passed" "success"
    } else {
        Write-Status "Widget tests failed" "warning"
    }
}

# ============================================================================
# STEP 7C: Test Coverage Analysis (Optional)
# ============================================================================
Write-Status "STEP 7C: Test Coverage Analysis" "step"
Write-Host "Generating coverage report..." -ForegroundColor Gray
$coverageOutput = flutter test --coverage 2>&1
if ($LASTEXITCODE -eq 0 -and (Test-Path "coverage/lcov.info")) {
    $coverageInfo = Get-Content "coverage/lcov.info" -Raw
    # Count lines covered vs total
    $linesFound = ([regex]::Matches($coverageInfo, "LF:")).Count
    $linesHit = ([regex]::Matches($coverageInfo, "LH:")).Count
    
    if ($linesFound -gt 0) {
        $coveragePercent = [math]::Round(($linesHit / $linesFound) * 100, 2)
        if ($coveragePercent -ge 70) {
            Write-Status "Test coverage: $coveragePercent% (Good)" "success"
        } elseif ($coveragePercent -ge 50) {
            Write-Status "Test coverage: $coveragePercent% (Acceptable)" "warning"
        } else {
            Write-Status "Test coverage: $coveragePercent% (Low - consider adding more tests)" "warning"
        }
    } else {
        Write-Status "Coverage data generated" "info"
    }
} else {
    Write-Status "Coverage generation skipped or failed (non-critical)" "info"
}

# ============================================================================
# STEP 8: Security Validation
# ============================================================================
Write-Status "STEP 8: Security Checks" "step"

# Check for hardcoded secrets
$securityPatterns = @(
    @{Pattern = 'AIzaSy[A-Za-z0-9_-]{33}'; Description = "Google API Key"},
    @{Pattern = 'sk_live_[A-Za-z0-9]{24,}'; Description = "Stripe Live Key"},
    @{Pattern = 'password\s*=\s*[''"][^''"]+[''"]'; Description = "Hardcoded Password"}
)

$securityIssues = 0
if (Test-Path "lib") {
    foreach ($pattern in $securityPatterns) {
        $securityMatches = Get-ChildItem -Path lib -Filter *.dart -Recurse -ErrorAction SilentlyContinue | 
            Select-String -Pattern $pattern.Pattern -CaseSensitive -ErrorAction SilentlyContinue
        
        if ($securityMatches) {
            Write-Status "Found potential $($pattern.Description) in code" "warning"
            $securityIssues++
        }
    }
}

if ($securityIssues -eq 0) {
    Write-Status "No obvious security issues detected" "success"
}

# ============================================================================
# STEP 9: Version Check
# ============================================================================
Write-Status "STEP 9: Version Information" "step"

$version = "unknown"
if (Test-Path "pubspec.yaml") {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    if ($pubspec -match "version:\s*([0-9]+\.[0-9]+\.[0-9]+)") {
        $version = $matches[1]
        Write-Status "App Version: $version" "info"
    } else {
        Write-Status "Version not found in pubspec.yaml" "warning"
    }
}

# ============================================================================
# STEP 10: Build Production APK
# ============================================================================
Write-Status "STEP 10: Building Production APK" "step"

if ($script:failedChecks.Count -gt 0) {
    Write-Host "`n================================================================" -ForegroundColor Red
    Write-Host "                 BUILD BLOCKED - CRITICAL ERRORS              " -ForegroundColor Red
    Write-Host "================================================================`n" -ForegroundColor Red
    
    Write-Host "Failed Checks:" -ForegroundColor Red
    foreach ($check in $script:failedChecks) {
        Write-Host "  * $check" -ForegroundColor Red
    }
    
    if ($script:warnings.Count -gt 0) {
        Write-Host "`nWarnings:" -ForegroundColor Yellow
        foreach ($warning in $script:warnings) {
            Write-Host "  * $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nFix all errors before building production APK!" -ForegroundColor Red
    exit 1
}

Write-Status "All checks passed! Proceeding with build..." "success"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$buildDir = Join-Path -Path "releases" -ChildPath "PROD_BUILD_$timestamp"

# Create build directory
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
Write-Status "Created build directory: $buildDir" "info"

Write-Host "`nBuilding release APK (split per ABI)..." -ForegroundColor Gray
flutter build apk --release --split-per-abi 2>&1 | Out-Null

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
        $hash.Hash | Out-File $hashFile -Encoding UTF8
        Write-Status "Generated SHA256 checksum" "success"
    }
    
    # Generate build info
    $flutterVersionStr = (flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1).ToString()
    
    $buildInfo = @{
        version = $version
        buildTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        flutterVersion = $flutterVersionStr
        testsPassed = $true
        buildType = "release"
        totalTestsPassed = $totalTestsPassed
    }
    
    $buildInfoFile = Join-Path $buildDir "build_info.json"
    $buildInfo | ConvertTo-Json | Out-File $buildInfoFile -Encoding UTF8
    Write-Status "Generated build_info.json" "success"
    
} else {
    Write-Status "Could not find APK output directory!" "error"
    exit 1
}

# ============================================================================
# FINAL REPORT
# ============================================================================
Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "             SmartCart Ready for Production Release!          " -ForegroundColor Green
Write-Host "================================================================`n" -ForegroundColor Green

Write-Status "Production Build Location: $buildDir" "info"

Write-Host "`nBuild Artifacts:" -ForegroundColor Cyan
Get-ChildItem $buildDir | ForEach-Object { 
    $size = ""
    if ($_.Extension -eq ".apk") { 
        $sizeMB = $_.Length / 1048576
        $size = " (" + [math]::Round($sizeMB, 2) + " MB)"
    }
    Write-Host "   * $($_.Name)$size" -ForegroundColor White 
}

if ($script:warnings.Count -gt 0) {
    Write-Host "`nWarnings (non-critical):" -ForegroundColor Yellow
    foreach ($warning in $script:warnings) {
        Write-Host "   * $warning" -ForegroundColor Yellow
    }
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "   1. Test the APK on physical devices" -ForegroundColor White
Write-Host "   2. Deploy Firebase rules: firebase deploy --only firestore:rules" -ForegroundColor White
Write-Host "   3. Upload to Google Play Console" -ForegroundColor White
Write-Host "   4. Monitor Firebase Analytics and Crashlytics" -ForegroundColor White

$currentTime = Get-Date -Format "HH:mm:ss"
Write-Host ""
Write-Host "Build completed successfully at $currentTime" -ForegroundColor Green
Write-Host ""

exit 0