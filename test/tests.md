# SmartCart Test Suite Documentation

## Overview
SmartCart maintains a comprehensive test suite with **88 individual tests** covering unit tests, integration tests, widget tests, performance tests, and security tests. The test suite ensures code quality, security, and reliability across the entire application.

## Test Statistics
- **Total Tests**: 88
- **Test Files**: 11
- **Coverage Areas**: Logic, UI, Security, Performance, Integration

## Test Categories

### 🔧 App Logic Tests (5 tests)
1. AppStateProvider initializes correctly
2. Cart math with taxes and discounts (paise precision)
3. Inventory logic prevents negative stock
4. Stock decrement after purchase simulation
5. canPlaceOrder validates stock correctly

### 🛒 App State Provider Tests (5 tests)
1. initializes with empty cart
2. adds products to cart and calculates total correctly
3. removes item from cart and updates total
4. increases quantity when adding same product
5. clears cart

### 🔐 Auth Service Tests (6 tests)
1. Email validation - accepts valid emails
2. Email validation - rejects invalid emails
3. Password validation - strong passwords
4. Password validation - weak passwords rejected
5. New user profile has correct default values
6. Google Sign-In user has photoURL

### 💳 Checkout Flow Tests (15 tests)
1. Cart total calculated correctly in paise
2. Tax calculation (18% GST) is accurate
3. Discount calculation is accurate
4. Complex order calculation (tax + discount)
5. Cannot add more items than available stock
6. Can add items within stock limit
7. Stock decrements correctly after purchase
8. Order has all required fields
9. Order items contain required product information
10. Payment amount matches order total
11. Prevents negative payment amounts
12. Payment method is specified
13. Valid shipping address has all required fields
14. Invalid pincode is rejected
15. Invalid phone number is rejected

### 🏠 Home Screen Tests (2 tests)
1. displays stat cards correctly
2. displays GOOD MORNING greeting

### 🔄 Integration Tests (9 tests)
1. E2E: Browse → Add to Cart → Checkout
2. E2E: Empty cart handling
3. E2E: Order confirmation and history
4. E2E: User updates profile with Google photo
5. E2E: Membership tier progression
6. E2E: User searches and filters products
7. E2E: User receives and reads notification
8. E2E: Handle out of stock during checkout
9. E2E: Handle invalid payment

### 📋 Models Tests (5 tests)
1. should correctly parse from map
2. should default to customer role if unknown or missing
3. should serialize to map correctly
4. should initialize with quantity 1 by default
5. should initialize with specific quantity

### ⚡ Performance Tests (9 tests)
1. Large product list search performance
2. Large cart calculation performance
3. Filter and sort large dataset
4. Memory efficiency - product list
5. Pagination efficiency simulation
6. Order history query performance
7. Notification list performance
8. Validate 1000 email addresses quickly
9. Validate phone numbers in bulk

### 📦 Product Tests (12 tests)
1. Product initializes with correct values
2. Product out of stock detection
3. Price formatting is accurate (paise to rupees)
4. Product search by name (case insensitive)
5. Product filter by category
6. Product filter by price range
7. Product stock quantity validation
8. Stock decreases after purchase
9. Prevent negative stock
10. Low stock warning threshold
11. Sort by price ascending
12. Sort by name alphabetically

### 🛡️ Security Tests (17 tests)
1. SQL injection prevention in search
2. XSS prevention in user input
3. Email validation prevents injection
4. Password must meet minimum requirements
5. Email format strictly validated
6. Session timeout simulation
7. Sensitive data not logged
8. Price manipulation prevention
9. Order tampering prevention
10. User ID validation in requests
11. Admin-only operations require admin role
12. Product name length restricted
13. Description length restricted
14. Address field length validation
15. Prevent rapid repeated requests
16. Allowed file extensions only
17. File size limit enforced

### 🎨 UI Integrity Tests (3 tests)
1. HomeScreen header displays correct greeting and user name
2. StatCard widgets show non-null values
3. BottomNavigationBar and FAB are present

## Test File Structure

```
test/
├── app_logic_test.dart          (5 tests)
├── app_state_provider_test.dart (5 tests)
├── auth_service_test.dart       (6 tests)
├── checkout_flow_test.dart      (15 tests)
├── home_screen_test.dart        (2 tests)
├── integration_test.dart        (9 tests)
├── models_test.dart             (5 tests)
├── performance_test.dart        (9 tests)
├── product_tests.dart           (12 tests)
├── security_test.dart           (17 tests)
├── ui_integrity_test.dart       (3 tests)
└── README_TESTS.md
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/models_test.dart
flutter test test/security_test.dart
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Run Tests with Verbose Output
```bash
flutter test --verbose
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

## Quality Gates

The test suite is part of SmartCart's quality assurance pipeline:

- ✅ **76+ unit/integration tests** (actually 88 as documented)
- ✅ **Flutter analyze** - static code analysis
- ✅ **publish_check.ps1** - automated release validation
- ✅ **GitHub Actions CI/CD** - automated testing pipeline

## Test Categories Explained

### Unit Tests
Individual functions, classes, and methods tested in isolation using mocks and stubs.

### Integration Tests (E2E)
End-to-end user flows that test complete features from start to finish.

### Widget Tests
UI component testing to ensure proper rendering and interaction.

### Performance Tests
Efficiency testing for large datasets, memory usage, and response times.

### Security Tests
Input validation, injection prevention, and access control verification.

## Continuous Integration

Tests run automatically on:
- **GitHub Actions** - Every push and pull request
- **Local Development** - Via `publish_check.ps1` script
- **Pre-release** - Quality gate before publishing

## Contributing

When adding new features:
1. Write corresponding tests
2. Ensure all tests pass
3. Update this documentation
4. Run `publish_check.ps1` before committing

## Test Maintenance

- Keep test coverage above 80%
- Update tests when refactoring code
- Add tests for bug fixes
- Review test failures in CI/CD pipeline

---

*Last updated: February 13, 2026*
*Total Tests: 88*</content>
<parameter name="filePath">c:\Users\pawar\Desktop\Shrs\SmartCart\test\tests.md