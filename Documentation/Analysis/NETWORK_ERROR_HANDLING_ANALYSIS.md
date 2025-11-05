# Network Error Handling Analysis Report
## Backend iOS Expert - Network Resilience Assessment

**Date:** 2025-10-16
**Status:** Analysis Complete
**Priority:** HIGH - Impacts Production Reliability

---

## Executive Summary

This analysis examines the network error handling across all job source integrations in the V7 iOS application. The codebase demonstrates solid foundational patterns but has critical gaps in retry logic, error telemetry, and user-facing error reporting that impact production reliability.

**Key Findings:**
- Circuit breaker pattern implemented but basic
- Exponential backoff exists for rate limiting only
- Silent failures in RSS feeds mask network issues
- No retry mechanism for transient failures
- Limited structured error telemetry
- Missing HTTP/HTTPS (ATS) specific handling

**Impact:**
- Some RSS feeds fail silently, reducing job discovery coverage
- Transient network failures result in no jobs shown to users
- Limited visibility into production network health
- No fallback mechanisms when primary sources fail

---

## 1. Current Error Handling Assessment

### 1.1 Circuit Breaker Implementation

**Location:** `/Packages/V7Services/Sources/V7Services/V7Services.swift` (Lines 706-771)

**Current State:**
```swift
actor CircuitBreaker {
    enum State { case closed, open, halfOpen }

    func canAttempt() -> Bool {
        // Opens after failureThreshold consecutive failures
        // Transitions to halfOpen after timeout period
        // Returns to closed on success
    }
}
```

**Strengths:**
- Actor-based thread safety
- Three-state pattern (closed, open, halfOpen)
- Automatic timeout-based recovery
- Per-source isolation
- Debug logging

**Weaknesses:**
- No jitter in halfOpen timeout (thundering herd risk)
- Fixed failure threshold (3) not configurable per source
- No exponential backoff between halfOpen attempts
- Missing metrics (open count, open duration)
- No health-based gradual recovery

**Used By:**
- GreenhouseAPIClient (line 68-72)
- LeverAPIClient (line 66-70)
- RSSFeedJobSource (line 88-93)
- JobSourceIntegrationService (line 274, 321-325)

### 1.2 Rate Limiting & Exponential Backoff

**Location:** `/Packages/V7Services/Sources/V7Services/CompanyAPIs/RateLimitManager.swift`

**Current State:**
```swift
actor RateLimitManager {
    // Token bucket algorithm for rate limiting
    // Exponential backoff on token exhaustion

    private var tokenBuckets: [String: TokenBucket]
    private var backoffStrategies: [String: ExponentialBackoff]
}

actor ExponentialBackoff {
    baseDelay: 1.0s
    maxDelay: 300.0s (5 minutes)
    multiplier: 2.0
    jitter: 0.1 (10%)

    // Formula: delay = min(maxDelay, baseDelay * 2^(failureCount-1) + jitter)
}
```

**Strengths:**
- Proper exponential backoff formula
- Jitter to prevent synchronized retries
- Per-source token buckets
- Backoff auto-resets on success

**Weaknesses:**
- Only applied to rate limiting, not general network failures
- No configurable backoff strategies per error type
- Missing correlation with circuit breaker state
- No backoff for HTTP 5xx vs 4xx errors

**Formula Validation:**
```
Attempt 1: 1s + jitter
Attempt 2: 2s + jitter
Attempt 3: 4s + jitter
Attempt 4: 8s + jitter
Attempt 5: 16s + jitter
Attempt 6: 32s + jitter
Attempt 7: 64s + jitter
Attempt 8: 128s + jitter
Attempt 9: 256s + jitter (capped at 300s)
```

### 1.3 Error Handling Patterns by Source

#### GreenhouseAPIClient

**Error Handling:**
```swift
// Lines 109-146: fetchJobs wrapper
do {
    let jobs = try await fetchJobsInternal(...)
    await circuitBreaker.recordSuccess()
    return jobs
} catch {
    await circuitBreaker.recordFailure()
    throw error  // Propagates up
}

// Lines 430-436: HTTP status code handling
guard httpResponse.statusCode == 200 else {
    if httpResponse.statusCode == 404 {
        return []  // NOT an error - company has no jobs
    }
    throw JobSourceError.sourceUnavailable("...")
}
```

**Assessment:**
- GOOD: 404 treated as valid empty response
- GOOD: Circuit breaker integration
- GAP: No retry on 5xx errors
- GAP: No distinction between transient (503, 504) vs permanent (400, 401)
- GAP: Network timeout throws generic error

#### LeverAPIClient

**Error Handling:**
```swift
// Lines 437-442: HTTP status handling
guard httpResponse.statusCode == 200 else {
    if httpResponse.statusCode == 429 {
        throw CompanyAPIError.rateLimitExceeded(...)
    }
    throw CompanyAPIError.apiUnavailable("...")
}
```

**Assessment:**
- GOOD: 429 specifically handled
- GAP: No retry mechanism
- GAP: 5xx errors treated same as 4xx
- SAME ISSUES: as Greenhouse

#### RSSFeedJobSource

**Error Handling:**
```swift
// Lines 451-458: Silent failure pattern
} catch {
    if ProductionConfiguration.debugJobSources {
        print("⚠️ Failed to fetch feed '\(feed.name)': \(error.localizedDescription)")
    }
    // Return empty array instead of throwing to allow other feeds to succeed
    return []
}
```

**Assessment:**
- CRITICAL GAP: Silent failures hide network issues
- GOOD: Partial failure doesn't kill entire RSS fetch
- GAP: No telemetry on which feeds fail
- GAP: No retry for transient failures
- CONCERN: Users don't know some sources failed

**HTTP Status Handling:**
```swift
// Lines 427-432: Status code checks
guard httpResponse.statusCode == 200 else {
    if httpResponse.statusCode == 429 {
        throw JobSourceError.rateLimitExceeded(...)
    }
    throw JobSourceError.sourceUnavailable("RSS feed returned \(httpResponse.statusCode)")
}
```

**Assessment:**
- Basic but functional
- No HTTP/HTTPS (ATS) specific error handling
- Missing parsing failure differentiation

### 1.4 Network Timeout Handling

**Configuration:**
```swift
// RSSFeedJobSource
private let feedTimeout: TimeInterval = 10.0

// GreenhouseAPIClient, LeverAPIClient
config.timeoutIntervalForRequest = ProductionConfiguration.networkTimeout

// JobSourceIntegrationService
private func getOptimalTimeout(...) -> TimeInterval {
    if companySources.contains(identifier) {
        return 4.0  // Company APIs
    } else {
        return 3.0  // RSS sources
    }
}
```

**Assessment:**
- GOOD: Different timeouts per source type
- GAP: Timeout throws generic error, not retried
- GAP: No adaptive timeout based on historical latency

### 1.5 Error Types & Classification

**Defined Errors:**
```swift
// JobSourceError
enum JobSourceError: Error {
    case networkError(String)
    case rateLimitExceeded(resetsAt: Date)
    case authenticationFailed(String)
    case invalidResponse(String)
    case sourceUnavailable(String)
    case quotaExhausted(String)
    case performanceBudgetExceeded(String)
    case circuitBreakerOpen(String)
}

// CompanyAPIError
enum CompanyAPIError: Error {
    case invalidCredentials(String)
    case rateLimitExceeded(resetsAt: Date)
    case invalidResponse(String)
    case apiUnavailable(String)
    case authenticationFailed(String)
}
```

**Assessment:**
- GOOD: Structured error types
- GAP: No distinction between transient vs permanent failures
- GAP: Missing HTTP/HTTPS ATS specific errors
- GAP: No error recovery hints for UI layer

---

## 2. Identified Failure Modes

### 2.1 Network-Level Failures

| Failure Mode | Current Behavior | Impact | Retry-able |
|-------------|------------------|--------|------------|
| DNS Resolution Failure | `networkError` thrown | No jobs | YES |
| Connection Timeout | `networkError` thrown | No jobs | YES |
| SSL/TLS Error | `networkError` thrown | No jobs | NO |
| Network Unreachable | `networkError` thrown | No jobs | YES (with delay) |
| Connection Reset | `networkError` thrown | No jobs | YES |
| Socket Timeout | `networkError` thrown | No jobs | YES |

**Current Gap:** All treated identically - no retry logic

### 2.2 HTTP Status Code Failures

| Status Code | Meaning | Current Handling | Should Retry? | Backoff? |
|------------|---------|------------------|---------------|----------|
| 400 Bad Request | Client error | Thrown as error | NO | NO |
| 401 Unauthorized | Auth failed | Thrown as error | NO | NO |
| 403 Forbidden | Auth failed | Thrown as error | NO | NO |
| 404 Not Found | Missing resource | Empty array (good!) | NO | NO |
| 408 Request Timeout | Timeout | Thrown as error | YES | LINEAR |
| 429 Too Many Requests | Rate limited | Thrown, backoff triggered | YES | EXPONENTIAL |
| 500 Internal Server Error | Server error | Thrown as error | YES | EXPONENTIAL |
| 502 Bad Gateway | Proxy error | Thrown as error | YES | EXPONENTIAL |
| 503 Service Unavailable | Overloaded | Thrown as error | YES | EXPONENTIAL |
| 504 Gateway Timeout | Timeout | Thrown as error | YES | LINEAR |

**Current Gap:** Only 404 and 429 handled specifically. No retry for 5xx.

### 2.3 RSS Feed Specific Failures

| Failure Mode | Current Behavior | Impact | Visibility |
|-------------|------------------|--------|-----------|
| Feed URL unreachable | Silent failure | Reduced job coverage | Debug logs only |
| Invalid XML | Silent failure | Reduced job coverage | Debug logs only |
| Malformed feed | Silent failure | Reduced job coverage | Debug logs only |
| HTTP feed blocked by ATS | Silent failure | Complete feed loss | Debug logs only |
| Feed parsing timeout | Silent failure | Reduced job coverage | Debug logs only |

**Critical Gap:** Silent failures hide production issues

### 2.4 App Transport Security (ATS) Issues

**Reported Problem:** "App Transport Security blocks HTTP-only endpoints"

**Current State:**
- No specific error detection for ATS blocks
- No fallback to HTTPS
- No user notification when ATS blocks a source
- No configuration validation at startup

**ATS Block Detection:**
```swift
// Current: Generic error thrown
// Needed: Specific ATS error detection
if error.localizedDescription.contains("App Transport Security") {
    // Handle ATS block specifically
}
```

### 2.5 Concurrent Fetch Failures

**Pattern in JobSourceIntegrationService:**
```swift
// Lines 398-401: Throw only if ALL sources fail
if successfulCompanies == 0 {
    let errorMessage = "All Greenhouse companies failed: \(errors.joined(separator: "; "))"
    throw JobSourceError.sourceUnavailable(errorMessage)
}
```

**Assessment:**
- GOOD: Partial failures tolerated
- GAP: No minimum success threshold (1 success = pass)
- GAP: User doesn't know some sources failed

---

## 3. Missing Capabilities

### 3.1 Retry Logic

**Current State:** NO RETRY MECHANISM EXISTS

**What's Needed:**
```swift
actor RetryManager {
    // Retry with exponential backoff for transient failures
    func executeWithRetry<T>(
        maxAttempts: Int,
        retryableErrors: [Error.Type],
        operation: () async throws -> T
    ) async throws -> T
}
```

**Use Cases:**
- Network timeouts (3 retries, exponential backoff)
- 5xx server errors (3 retries, exponential backoff)
- DNS failures (2 retries, linear backoff)
- Connection resets (3 retries, exponential backoff)

### 3.2 Error Telemetry

**Current State:** Debug print statements only

**What's Needed:**
```swift
actor ErrorTelemetry {
    // Track errors by source, type, frequency
    func recordError(
        source: String,
        errorType: ErrorCategory,
        httpStatus: Int?,
        isTransient: Bool,
        metadata: [String: String]
    )

    func getErrorStats() -> ErrorStatistics
}
```

**Metrics to Track:**
- Error rate by source
- Error type distribution
- Transient vs permanent failure ratio
- Time to recovery
- Circuit breaker open frequency

### 3.3 Fallback Mechanisms

**Current Gap:** No fallback strategies

**Needed Fallbacks:**
1. API → RSS fallback for dual-source companies
2. Primary source → backup source
3. Real-time → cached results
4. Full query → simplified query retry

### 3.4 User-Facing Error Messages

**Current State:** Errors propagate to UI as raw messages

**What's Needed:**
```swift
struct UserFacingError {
    let title: String
    let message: String
    let isRecoverable: Bool
    let suggestedAction: String?
    let retryAvailable: Bool
}
```

**Examples:**
- "Network issue. Pull to refresh to try again."
- "Some job sources are temporarily unavailable. Showing jobs from available sources."
- "Rate limit reached. Try again in 5 minutes."

---

## 4. Recommended Error Handling Strategy

### 4.1 Error Classification System

```swift
enum ErrorCategory {
    case transient          // Retry immediately
    case rateLimited        // Retry after backoff
    case serverError        // Retry with exponential backoff
    case clientError        // Don't retry
    case authError          // Don't retry
    case networkUnreachable // Retry after network check
    case atsBlocked         // Report to user, don't retry
}

extension Error {
    var category: ErrorCategory {
        // Classify error based on type and context
    }

    var isRetryable: Bool {
        // Determine if error should trigger retry
    }

    var recommendedBackoff: BackoffStrategy {
        // Return appropriate backoff for error type
    }
}
```

### 4.2 Retry Strategy Design

**Exponential Backoff Formula (Enhanced):**
```
delay = min(maxDelay, baseDelay * multiplier^(attempt-1)) * (1 + jitter * random(-1, 1))

Where:
- baseDelay = 1.0s (network), 5.0s (rate limit)
- maxDelay = 60.0s (network), 300.0s (rate limit)
- multiplier = 2.0
- jitter = 0.2 (20%)
- attempt = current retry count (1-indexed)
```

**Retry Decision Tree:**
```
Error Occurs
    |
    +-- Is Circuit Breaker Open?
    |       YES → Don't Retry
    |       NO  → Continue
    |
    +-- Is Error Retryable?
    |       NO  → Propagate Error
    |       YES → Continue
    |
    +-- Exceeded Max Retries?
    |       YES → Propagate Error
    |       NO  → Continue
    |
    +-- Calculate Backoff Delay
    |
    +-- Wait for Backoff
    |
    +-- Retry Operation
```

**Implementation:**
```swift
actor RetryManager {
    struct RetryConfig {
        let maxAttempts: Int
        let baseDelay: TimeInterval
        let maxDelay: TimeInterval
        let multiplier: Double
        let jitter: Double
    }

    func executeWithRetry<T>(
        operation: @Sendable () async throws -> T,
        config: RetryConfig,
        shouldRetry: @Sendable (Error) -> Bool
    ) async throws -> T {
        var attempt = 1
        var lastError: Error?

        while attempt <= config.maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                guard shouldRetry(error) else {
                    throw error
                }

                if attempt < config.maxAttempts {
                    let delay = calculateBackoff(
                        attempt: attempt,
                        config: config
                    )

                    if ProductionConfiguration.debugJobSources {
                        print("⏱️ Retry attempt \(attempt)/\(config.maxAttempts) after \(delay)s")
                    }

                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }

                attempt += 1
            }
        }

        throw lastError ?? JobSourceError.networkError("All retries exhausted")
    }

    private func calculateBackoff(attempt: Int, config: RetryConfig) -> TimeInterval {
        let exponential = config.baseDelay * pow(config.multiplier, Double(attempt - 1))
        let capped = min(config.maxDelay, exponential)
        let jitterAmount = capped * config.jitter * Double.random(in: -1...1)
        return max(0, capped + jitterAmount)
    }
}
```

### 4.3 Circuit Breaker Improvements

**Enhanced Implementation:**
```swift
actor EnhancedCircuitBreaker {
    struct Config {
        let failureThreshold: Int = 5
        let successThreshold: Int = 2  // Successes needed to close from halfOpen
        let timeout: TimeInterval = 60.0
        let halfOpenTimeout: TimeInterval = 30.0
        let halfOpenJitter: Double = 0.3  // 30% jitter
    }

    private var consecutiveFailures: Int = 0
    private var consecutiveSuccesses: Int = 0
    private var openSince: Date?
    private var halfOpenSince: Date?
    private var totalOpens: Int = 0

    func canAttempt() -> Bool {
        switch state {
        case .closed:
            return true

        case .open:
            guard let openTime = openSince else { return false }

            // Check if timeout has passed (with jitter)
            let timeout = config.timeout * (1 + Double.random(in: -config.halfOpenJitter...config.halfOpenJitter))

            if Date().timeIntervalSince(openTime) > timeout {
                transitionToHalfOpen()
                return true
            }
            return false

        case .halfOpen:
            // Limit requests in halfOpen state
            return consecutiveSuccesses < config.successThreshold
        }
    }

    func recordSuccess() {
        consecutiveFailures = 0

        switch state {
        case .closed:
            // Already closed, nothing to do
            break

        case .halfOpen:
            consecutiveSuccesses += 1
            if consecutiveSuccesses >= config.successThreshold {
                transitionToClosed()
            }

        case .open:
            // Shouldn't happen, but handle gracefully
            transitionToClosed()
        }
    }

    func recordFailure() {
        consecutiveSuccesses = 0
        consecutiveFailures += 1

        if consecutiveFailures >= config.failureThreshold {
            transitionToOpen()
        }
    }

    func getMetrics() -> CircuitBreakerMetrics {
        CircuitBreakerMetrics(
            state: state,
            consecutiveFailures: consecutiveFailures,
            consecutiveSuccesses: consecutiveSuccesses,
            totalOpens: totalOpens,
            currentOpenDuration: openSince.map { Date().timeIntervalSince($0) }
        )
    }
}
```

### 4.4 Error Telemetry System

**Implementation:**
```swift
actor ErrorTelemetryTracker {
    struct ErrorRecord {
        let timestamp: Date
        let source: String
        let category: ErrorCategory
        let httpStatus: Int?
        let errorMessage: String
        let wasRetried: Bool
        let retrySucceeded: Bool?
    }

    private var errorHistory: [ErrorRecord] = []
    private let maxHistorySize = 1000
    private let historyWindow: TimeInterval = 3600 // 1 hour

    func recordError(
        source: String,
        error: Error,
        httpStatus: Int?,
        wasRetried: Bool,
        retrySucceeded: Bool?
    ) {
        let record = ErrorRecord(
            timestamp: Date(),
            source: source,
            category: error.category,
            httpStatus: httpStatus,
            errorMessage: error.localizedDescription,
            wasRetried: wasRetried,
            retrySucceeded: retrySucceeded
        )

        errorHistory.append(record)
        cleanOldRecords()
    }

    func getErrorStatistics() -> ErrorStatistics {
        let now = Date()
        let recentErrors = errorHistory.filter {
            now.timeIntervalSince($0.timestamp) < historyWindow
        }

        // Calculate error rates by source
        let errorsBySource = Dictionary(grouping: recentErrors) { $0.source }
        let errorRates = errorsBySource.mapValues { errors in
            Double(errors.count) / historyWindow * 60.0 // Errors per minute
        }

        // Calculate retry success rate
        let retriedErrors = recentErrors.filter { $0.wasRetried }
        let successfulRetries = retriedErrors.filter { $0.retrySucceeded == true }
        let retrySuccessRate = retriedErrors.isEmpty ? 0.0 :
            Double(successfulRetries.count) / Double(retriedErrors.count)

        // Calculate error type distribution
        let errorsByCategory = Dictionary(grouping: recentErrors) { $0.category }
        let categoryDistribution = errorsByCategory.mapValues { errors in
            Double(errors.count) / Double(recentErrors.count)
        }

        return ErrorStatistics(
            totalErrors: recentErrors.count,
            errorRatesBySource: errorRates,
            retrySuccessRate: retrySuccessRate,
            errorCategoryDistribution: categoryDistribution,
            mostFrequentError: findMostFrequentError(recentErrors)
        )
    }

    private func cleanOldRecords() {
        let cutoff = Date().addingTimeInterval(-historyWindow)
        errorHistory = errorHistory.filter { $0.timestamp > cutoff }

        // Also enforce max size
        if errorHistory.count > maxHistorySize {
            errorHistory = Array(errorHistory.suffix(maxHistorySize))
        }
    }
}
```

### 4.5 HTTP/HTTPS ATS Handling

**Detection and Handling:**
```swift
extension URLError {
    var isATSBlock: Bool {
        // NSURLErrorAppTransportSecurityRequiresSecureConnection
        return code == .appTransportSecurityRequiresSecureConnection
    }
}

// In RSS Feed Source
private func fetchSingleFeed(_ feed: RSSFeedsConfiguration.RSSFeed) async throws -> [RawJobData] {
    do {
        // ... existing fetch logic
    } catch let error as URLError where error.isATSBlock {
        // ATS blocked this feed
        await telemetry.recordError(
            source: "rss-\(feed.id)",
            error: error,
            httpStatus: nil,
            wasRetried: false,
            retrySucceeded: nil
        )

        // Try HTTPS upgrade if feed is HTTP
        if feed.url.hasPrefix("http://") {
            let httpsURL = feed.url.replacingOccurrences(of: "http://", with: "https://")
            if ProductionConfiguration.debugJobSources {
                print("⚠️ ATS blocked \(feed.url), trying HTTPS: \(httpsURL)")
            }
            // Retry with HTTPS
            var httpsConfig = feed
            httpsConfig.url = httpsURL
            return try await fetchSingleFeedHTTPS(httpsConfig)
        }

        // Can't upgrade, report and skip
        throw JobSourceError.sourceUnavailable("Feed blocked by App Transport Security: \(feed.url)")
    }
}
```

### 4.6 User-Facing Error Reporting

**Error Presentation Layer:**
```swift
struct UserFacingError {
    let title: String
    let message: String
    let severity: Severity
    let isRecoverable: Bool
    let suggestedAction: String?
    let technicalDetails: String? // For support

    enum Severity {
        case info      // Partial failure, still showing results
        case warning   // Degraded experience
        case error     // No results available
    }

    static func from(jobSourceError: JobSourceError, context: ErrorContext) -> UserFacingError {
        switch jobSourceError {
        case .networkError(let message):
            return UserFacingError(
                title: "Network Issue",
                message: "Unable to connect to job sources. Please check your internet connection and try again.",
                severity: .error,
                isRecoverable: true,
                suggestedAction: "Pull to refresh",
                technicalDetails: message
            )

        case .rateLimitExceeded(let resetsAt):
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let resetTime = formatter.string(from: resetsAt)

            return UserFacingError(
                title: "Rate Limit Reached",
                message: "Job sources are temporarily rate limited. Try again after \(resetTime).",
                severity: .warning,
                isRecoverable: true,
                suggestedAction: "Try again later",
                technicalDetails: "Rate limit resets at \(resetsAt)"
            )

        case .circuitBreakerOpen(let source):
            return UserFacingError(
                title: "Source Temporarily Unavailable",
                message: "The \(source) job source is experiencing issues. We're showing jobs from other sources.",
                severity: .info,
                isRecoverable: true,
                suggestedAction: nil,
                technicalDetails: "Circuit breaker open for \(source)"
            )

        case .sourceUnavailable(let message):
            if context.partialResults {
                return UserFacingError(
                    title: "Some Sources Unavailable",
                    message: "We're showing jobs from available sources. Some job sources are temporarily unavailable.",
                    severity: .info,
                    isRecoverable: false,
                    suggestedAction: nil,
                    technicalDetails: message
                )
            } else {
                return UserFacingError(
                    title: "Job Sources Unavailable",
                    message: "Unable to fetch jobs right now. Please try again in a few minutes.",
                    severity: .error,
                    isRecoverable: true,
                    suggestedAction: "Pull to refresh",
                    technicalDetails: message
                )
            }

        default:
            return UserFacingError(
                title: "Something Went Wrong",
                message: "Unable to load jobs. Please try again.",
                severity: .error,
                isRecoverable: true,
                suggestedAction: "Pull to refresh",
                technicalDetails: String(describing: jobSourceError)
            )
        }
    }
}

struct ErrorContext {
    let partialResults: Bool  // Are we showing some results despite error?
    let sourceCount: Int      // How many sources were attempted?
    let successCount: Int     // How many succeeded?
}
```

---

## 5. Implementation Plan

### Phase 1: Critical Fixes (Week 1)

**Priority 1: Fix Silent RSS Failures**
- File: `RSSFeedJobSource.swift`
- Change: Replace silent failure with error telemetry
- Impact: Visibility into production RSS issues

```swift
// Before (Line 451-458)
} catch {
    if ProductionConfiguration.debugJobSources {
        print("⚠️ Failed to fetch feed '\(feed.name)': \(error.localizedDescription)")
    }
    return []
}

// After
} catch {
    // Record error for telemetry
    await errorTelemetry.recordError(
        source: "rss-\(feed.id)",
        error: error,
        httpStatus: extractHTTPStatus(error),
        wasRetried: false,
        retrySucceeded: nil
    )

    if ProductionConfiguration.debugJobSources {
        print("⚠️ Failed to fetch feed '\(feed.name)': \(error.localizedDescription)")
    }

    // Still return empty to allow other feeds to succeed
    // but now we have visibility into what's failing
    return []
}
```

**Priority 2: Add Basic Retry Logic**
- Files: All `*APIClient.swift` files
- Add: `RetryManager` actor
- Impact: Handle transient network failures

**Priority 3: Enhance Circuit Breaker**
- File: `V7Services.swift`
- Add: Jitter, metrics, halfOpen success threshold
- Impact: Better failure recovery

### Phase 2: Error Telemetry (Week 2)

**Task 1: Create ErrorTelemetryTracker**
- New file: `ErrorTelemetryTracker.swift`
- Integration: All fetch operations
- Output: Error statistics API

**Task 2: Add Health Dashboard**
- Endpoint: `getErrorStatistics()`
- UI: Network health indicator
- Alerts: High error rate warnings

### Phase 3: User Experience (Week 3)

**Task 1: User-Facing Error Messages**
- New file: `UserFacingError.swift`
- Integration: UI error display
- UX: Clear, actionable error messages

**Task 2: Partial Failure Handling**
- Logic: Show jobs from successful sources
- UI: Info banner "Some sources unavailable"
- Impact: Better user experience

### Phase 4: Advanced Features (Week 4)

**Task 1: Fallback Mechanisms**
- API → RSS fallback for RemotiveJobSource
- Cache fallback when all sources fail
- Simplified query retry

**Task 2: ATS Detection & Handling**
- HTTP → HTTPS upgrade attempts
- ATS error specific messaging
- Feed configuration validation

---

## 6. Code Changes Required

### 6.1 New Files to Create

1. **`RetryManager.swift`** (~150 lines)
   - Retry logic with exponential backoff
   - Error classification
   - Retry decision engine

2. **`ErrorTelemetryTracker.swift`** (~200 lines)
   - Error recording and storage
   - Statistics calculation
   - Health reporting

3. **`UserFacingError.swift`** (~100 lines)
   - Error translation for UI
   - Severity classification
   - Action recommendations

4. **`ErrorCategory.swift`** (~80 lines)
   - Error classification extensions
   - Retry-ability determination
   - Backoff strategy mapping

### 6.2 Files to Modify

1. **`RSSFeedJobSource.swift`**
   - Add retry logic to `fetchSingleFeed`
   - Replace silent failures with telemetry
   - Add ATS detection and HTTPS upgrade
   - ~50 lines changed

2. **`GreenhouseAPIClient.swift`**
   - Wrap fetch operations with retry
   - Add error telemetry
   - Enhance status code handling
   - ~30 lines changed

3. **`LeverAPIClient.swift`**
   - Same as Greenhouse
   - ~30 lines changed

4. **`V7Services.swift` (CircuitBreaker)**
   - Add jitter to halfOpen timeout
   - Add success threshold
   - Add metrics API
   - ~60 lines changed

5. **`RateLimitManager.swift`**
   - Integrate with retry manager
   - Add correlation with circuit breaker
   - ~20 lines changed

### 6.3 Testing Requirements

**Unit Tests:**
- RetryManager backoff calculation
- Error classification logic
- Circuit breaker state transitions
- Telemetry statistics calculation

**Integration Tests:**
- End-to-end retry scenarios
- Circuit breaker + retry interaction
- Partial failure handling
- ATS error detection

**Manual Tests:**
- Network failures (airplane mode)
- Rate limiting (rapid requests)
- Server errors (mock 5xx responses)
- RSS feed failures (invalid XML)

---

## 7. Performance Impact

### Memory Impact
- RetryManager: ~5KB per active operation
- ErrorTelemetryTracker: ~50KB for 1000 error records
- Enhanced CircuitBreaker: +2KB per source
- **Total:** ~60KB additional memory usage
- **Within budget:** Yes (200MB baseline)

### Latency Impact
- Retry delay: Only on failures (0ms on success)
- Telemetry recording: <1ms async
- Error classification: <0.1ms
- **Impact on Thompson <10ms budget:** None (async operations)

### Network Traffic Impact
- Retry attempts: Up to 3x traffic on failures
- Mitigation: Exponential backoff prevents thundering herd
- Expected: <5% increase in normal conditions

---

## 8. Monitoring & Alerts

### Metrics to Track

**Error Metrics:**
- Error rate by source (errors/minute)
- Error category distribution
- Retry success rate
- Circuit breaker open frequency
- ATS block count

**Performance Metrics:**
- Average retry count per request
- Time to recovery after failures
- Partial failure frequency
- User-facing error frequency

### Alert Thresholds

**Critical:**
- All sources failing for >5 minutes
- Error rate >50% for >2 minutes
- Circuit breaker open for all sources

**Warning:**
- Error rate >20% for >5 minutes
- Retry success rate <50%
- Partial failures >30% of requests

**Info:**
- Circuit breaker opened for any source
- ATS blocks detected
- Retry success after failures

---

## 9. Documentation Updates

### Developer Documentation
- Error handling patterns guide
- Retry strategy decision tree
- Circuit breaker configuration guide
- Telemetry API documentation

### Operations Documentation
- Error monitoring playbook
- Alert response procedures
- Network failure troubleshooting
- RSS feed validation process

---

## 10. Risk Assessment

### Implementation Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Retry storms overload servers | Medium | High | Exponential backoff + jitter |
| Increased network usage | High | Low | Max 3 retries, smart backoff |
| False positive retries | Low | Low | Careful error classification |
| Telemetry memory growth | Low | Medium | Size limits + time windows |
| Increased latency on failures | High | Medium | Fast fail on permanent errors |

### Rollout Strategy

**Phase 1: Dark Launch**
- Enable telemetry only
- Monitor error patterns
- Validate classification

**Phase 2: Retry Beta**
- Enable retry for 10% of users
- Monitor success rates
- Adjust backoff parameters

**Phase 3: Full Rollout**
- Enable for all users
- Monitor metrics closely
- Fast rollback if issues

---

## Appendices

### A. Error Classification Reference

```swift
extension Error {
    var category: ErrorCategory {
        // Network errors
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost:
                return .networkUnreachable

            case .timedOut:
                return .transient

            case .appTransportSecurityRequiresSecureConnection:
                return .atsBlocked

            case .cannotFindHost,
                 .cannotConnectToHost:
                return .transient

            case .secureConnectionFailed:
                return .clientError

            default:
                return .transient
            }
        }

        // Job source errors
        if let jobError = self as? JobSourceError {
            switch jobError {
            case .networkError:
                return .transient
            case .rateLimitExceeded:
                return .rateLimited
            case .authenticationFailed:
                return .authError
            case .invalidResponse:
                return .clientError
            case .sourceUnavailable:
                return .serverError
            case .circuitBreakerOpen:
                return .clientError // Don't retry when breaker open
            default:
                return .clientError
            }
        }

        // Default: transient (safer to retry)
        return .transient
    }
}
```

### B. Backoff Strategy Configurations

```swift
extension RetryManager {
    static let networkRetryConfig = RetryConfig(
        maxAttempts: 3,
        baseDelay: 1.0,
        maxDelay: 10.0,
        multiplier: 2.0,
        jitter: 0.2
    )

    static let rateLimitRetryConfig = RetryConfig(
        maxAttempts: 2,
        baseDelay: 5.0,
        maxDelay: 60.0,
        multiplier: 2.0,
        jitter: 0.3
    )

    static let serverErrorRetryConfig = RetryConfig(
        maxAttempts: 3,
        baseDelay: 2.0,
        maxDelay: 30.0,
        multiplier: 2.0,
        jitter: 0.2
    )
}
```

### C. Testing Scenarios

**Network Failure Simulation:**
```swift
class NetworkFailureSimulator {
    // Simulate various failure modes for testing

    func simulateDNSFailure() {
        // Returns NSURLErrorCannotFindHost
    }

    func simulateTimeout() {
        // Returns NSURLErrorTimedOut after delay
    }

    func simulateIntermittentFailure(successRate: Double) {
        // Fails randomly with given success rate
    }

    func simulate5xxErrors(statusCode: Int) {
        // Returns 500, 502, 503, 504
    }

    func simulateATSBlock() {
        // Returns NSURLErrorAppTransportSecurityRequiresSecureConnection
    }
}
```

---

## Conclusion

The V7 job source integration has solid foundations but needs systematic improvements in error handling, retry logic, and observability. The recommended changes will significantly improve production reliability and user experience while staying within performance budgets.

**Key Takeaways:**
1. Implement retry logic with exponential backoff
2. Fix silent RSS feed failures
3. Add comprehensive error telemetry
4. Enhance circuit breaker with jitter and metrics
5. Improve user-facing error messages
6. Add HTTP/HTTPS ATS detection and handling

**Estimated Effort:** 4 weeks for full implementation
**Risk Level:** Low-Medium (with phased rollout)
**Impact:** High (improved reliability and user experience)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-16
**Author:** Backend iOS Expert - Network Error Handling Analysis
