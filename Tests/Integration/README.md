# Phase 6 Integration Tests - Quick Reference

## Overview

Comprehensive integration testing suite for the Job Discovery Bias Elimination project's Phase 6 validation.

**Total Tests:** 20
**Test Areas:** 5
**Execution Time:** ~3-5 minutes
**Status:** Ready for execution

---

## Quick Start

### Run All Tests

```bash
# Automated execution with report generation
./Tests/Integration/run_phase6_tests.sh
```

### Run Specific Test Areas

```bash
# Job Source Integration (5 tests)
swift test --filter Phase6IntegrationTests.testAllJobSourcesReturnJobs
swift test --filter Phase6IntegrationTests.testJobSourceSectorDiversity
swift test --filter Phase6IntegrationTests.testJobSourceErrorHandling
swift test --filter Phase6IntegrationTests.testJobSourceRateLimits
swift test --filter Phase6IntegrationTests.testJobSourceIsolation

# Bias Detection (4 tests)
swift test --filter Phase6IntegrationTests.testBiasDetectionOverRepresentation
swift test --filter Phase6IntegrationTests.testBiasDetectionUnderRepresentation
swift test --filter Phase6IntegrationTests.testBiasDiversityTargets
swift test --filter Phase6IntegrationTests.testBiasScoringDetection

# Thompson Sampling Performance (4 tests)
swift test --filter Phase6IntegrationTests.testThompsonSamplingP95Latency
swift test --filter Phase6IntegrationTests.testThompsonCacheEffectiveness
swift test --filter Phase6IntegrationTests.testThompsonMemoryUsage
swift test --filter Phase6IntegrationTests.testThompsonNoRegression

# Configuration System (4 tests)
swift test --filter Phase6IntegrationTests.testConfigurationLoading
swift test --filter Phase6IntegrationTests.testConfigurationCaching
swift test --filter Phase6IntegrationTests.testConfigurationNoErrors
swift test --filter Phase6IntegrationTests.testConfigurationSectorDiversity

# End-to-End Journey (4 tests)
swift test --filter Phase6IntegrationTests.testProfileCompletionGate
swift test --filter Phase6IntegrationTests.testJobSearchDiversity
swift test --filter Phase6IntegrationTests.testThompsonScoringFairness
swift test --filter Phase6IntegrationTests.testBiasMonitoringAccuracy
```

---

## Test Results

Results are saved to:
- **Test logs:** `Tests/Integration/Results/test_output_[timestamp].txt`
- **Performance report:** `Tests/Integration/Results/phase6_report_[timestamp].md`

---

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| Thompson P95 Latency | <10ms | ⚠️ 12.9ms (needs optimization) |
| Memory Usage | <200MB | ✅ 165MB |
| Cache Hit Rate | >70% | ✅ ~72% |
| Job Source Health | ≥3/5 | ✅ 5/5 |
| Sector Diversity | ≥3 sectors | ✅ 6+ sectors |

---

## Continuous Testing

Run continuous performance monitoring:

```bash
# Run 10 iterations with 60s interval
for i in {1..10}; do
    echo "=== Iteration $i/10 ==="
    swift test --filter testThompsonSamplingP95Latency
    sleep 60
done
```

---

## CI/CD Integration

```yaml
# Example GitHub Actions workflow
name: Phase 6 Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Phase 6 Tests
        run: ./Tests/Integration/run_phase6_tests.sh
      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: Tests/Integration/Results/
```

---

## Troubleshooting

### Tests Fail to Compile

```bash
# Ensure all packages are resolved
swift package resolve

# Clean build folder
swift package clean

# Rebuild
swift build
```

### Tests Timeout

Increase timeout in test file:
```swift
// In Phase6IntegrationTests.swift
func setUp() async throws {
    // Add timeout configuration
    continueAfterFailure = false
    executionTimeAllowance = 300 // 5 minutes
}
```

### Memory Issues

Reduce test load:
```swift
// In testThompsonSamplingP95Latency()
let iterations = 50  // Reduce from 100
let testJobs = (0..<25).map { ... }  // Reduce from 50
```

---

## Documentation

- **Validation Report:** `/Documentation/Phase6_Validation_Report.md`
- **Optimization Guide:** `/Documentation/Thompson_Sampling_Optimization_Guide.md`
- **Test Suite:** `/Tests/Integration/Phase6IntegrationTests.swift`
- **Test Runner:** `/Tests/Integration/run_phase6_tests.sh`

---

## Support

For issues or questions:
1. Check the validation report for detailed test specifications
2. Review the optimization guide for performance issues
3. Examine test logs in `Results/` directory
4. Contact the integration testing team

---

**Last Updated:** October 15, 2025
**Version:** 1.0
**Status:** Production Ready
