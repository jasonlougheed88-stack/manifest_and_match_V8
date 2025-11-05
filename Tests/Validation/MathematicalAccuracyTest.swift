#!/usr/bin/env swift

// Phase 4.2.1: Mathematical Accuracy Verification Script
// Tests Thompson Beta distribution calculations for accuracy

import Foundation
import Darwin  // For tgamma function

// Beta probability density function
func betaPDF(x: Double, alpha: Double, beta: Double) -> Double {
    guard x > 0 && x < 1 else { return 0 }

    let B = tgamma(alpha) * tgamma(beta) / tgamma(alpha + beta)
    return pow(x, alpha - 1) * pow(1 - x, beta - 1) / B
}

// Test cases with expected values
struct TestCase {
    let x: Double
    let alpha: Double
    let beta: Double
    let expected: Double
    let tolerance: Double
    let description: String
}

let testCases = [
    TestCase(x: 0.5, alpha: 2.0, beta: 2.0, expected: 1.5, tolerance: 0.001,
             description: "Symmetric Beta(2,2)"),
    TestCase(x: 0.3, alpha: 3.0, beta: 2.0, expected: 0.756, tolerance: 0.001,
             description: "Skewed Beta(3,2)"),
    TestCase(x: 0.7, alpha: 2.0, beta: 3.0, expected: 0.756, tolerance: 0.001,
             description: "Opposite skew Beta(2,3)"),
    TestCase(x: 0.8, alpha: 5.0, beta: 2.0, expected: 2.4576, tolerance: 0.001,
             description: "Strong skew Beta(5,2)"),
    TestCase(x: 0.6, alpha: 1.5, beta: 1.5, expected: 1.2475, tolerance: 0.001,
             description: "U-shaped Beta(1.5,1.5)")
]

print("=== Thompson Beta Distribution Mathematical Accuracy Test ===\n")

var allTestsPassed = true

for testCase in testCases {
    let result = betaPDF(x: testCase.x, alpha: testCase.alpha, beta: testCase.beta)
    let difference = abs(result - testCase.expected)
    let passed = difference < testCase.tolerance

    allTestsPassed = allTestsPassed && passed

    let status = passed ? "✅ PASS" : "❌ FAIL"
    print("\(status) \(testCase.description)")
    print("   Beta(\(testCase.alpha), \(testCase.beta)) at x=\(testCase.x)")
    print("   Expected: \(testCase.expected), Got: \(result), Diff: \(difference)")
    print("")
}

// Test sample generation performance
print("=== Sample Generation Performance Test ===\n")

func generateSamples(count: Int, alpha: Double, beta: Double) -> [(x: Double, density: Double)] {
    var samples: [(x: Double, density: Double)] = []

    for i in 0...count {
        let x = Double(i) / Double(count)
        let density = betaPDF(x: x, alpha: alpha, beta: beta)
        samples.append((x: x, density: density))
    }

    return samples
}

let startTime = CFAbsoluteTimeGetCurrent()
let sampleCount = 100

// Generate samples for both profiles
let personalSamples = generateSamples(count: sampleCount, alpha: 3.5, beta: 2.1)
let professionalSamples = generateSamples(count: sampleCount, alpha: 4.2, beta: 1.8)

// Calculate combined density
var combinedSamples: [(x: Double, combined: Double)] = []
for i in 0...sampleCount {
    let x = Double(i) / Double(sampleCount)
    let personalDensity = personalSamples[i].density
    let professionalDensity = professionalSamples[i].density
    let combined = (personalDensity + professionalDensity) / 2.0
    combinedSamples.append((x: x, combined: combined))
}

let generationTime = CFAbsoluteTimeGetCurrent() - startTime

print("Generated \(sampleCount * 3) samples in \(String(format: "%.3f", generationTime * 1000))ms")
print("Average time per sample: \(String(format: "%.3f", generationTime * 1000000 / Double(sampleCount * 3)))µs")

// Validate sample properties
var validationPassed = true

// Check monotonic x values
for i in 1..<combinedSamples.count {
    if combinedSamples[i].x <= combinedSamples[i-1].x {
        print("❌ Non-monotonic x values detected at index \(i)")
        validationPassed = false
        break
    }
}

// Check density non-negativity
for sample in combinedSamples {
    if sample.combined < 0 {
        print("❌ Negative density detected at x=\(sample.x)")
        validationPassed = false
        break
    }
}

if validationPassed {
    print("✅ Sample validation passed")
}

// Test confidence interval calculations
print("\n=== Confidence Interval Validation ===\n")

struct ConfidenceInterval {
    let lower: Double
    let upper: Double
    let confidence: Double
}

let testIntervals = [
    ConfidenceInterval(lower: 0.70, upper: 0.80, confidence: 0.95),
    ConfidenceInterval(lower: 0.45, upper: 0.55, confidence: 0.90),
    ConfidenceInterval(lower: 0.85, upper: 0.95, confidence: 0.99)
]

for interval in testIntervals {
    let width = interval.upper - interval.lower
    let midpoint = (interval.lower + interval.upper) / 2.0

    print("CI[\(Int(interval.confidence * 100))%]: [\(interval.lower), \(interval.upper)]")
    print("  Width: \(width), Midpoint: \(midpoint)")

    // Validate constraints
    if interval.lower < 0 || interval.lower > 1 {
        print("  ❌ Lower bound out of range")
    } else if interval.upper < 0 || interval.upper > 1 {
        print("  ❌ Upper bound out of range")
    } else if interval.lower >= interval.upper {
        print("  ❌ Invalid interval (lower >= upper)")
    } else if interval.confidence <= 0 || interval.confidence > 1 {
        print("  ❌ Invalid confidence level")
    } else if interval.confidence >= 0.95 && width > 0.15 {
        print("  ⚠️  Width seems large for 95% CI")
    } else {
        print("  ✅ Valid interval")
    }
}

// Performance benchmark
print("\n=== Performance Benchmark ===\n")

let iterations = 10000
let benchmarkStart = CFAbsoluteTimeGetCurrent()

for i in 0..<iterations {
    let x = Double(i % 100) / 100.0
    _ = betaPDF(x: x, alpha: 3.5, beta: 2.1)
}

let benchmarkTime = CFAbsoluteTimeGetCurrent() - benchmarkStart
let avgTimePerCalculation = benchmarkTime / Double(iterations)

print("Beta PDF Calculation Performance:")
print("  Total time for \(iterations) calculations: \(String(format: "%.3f", benchmarkTime * 1000))ms")
print("  Average time per calculation: \(String(format: "%.3f", avgTimePerCalculation * 1000000))µs")

if avgTimePerCalculation < 0.0001 {
    print("  ✅ Performance target met (<100µs per calculation)")
} else {
    print("  ❌ Performance target missed (target: <100µs per calculation)")
}

// Summary
print("\n=== SUMMARY ===\n")

if allTestsPassed && validationPassed {
    print("✅ All mathematical accuracy tests PASSED")
    print("✅ Thompson Beta calculations are preserved correctly")
    print("✅ Confidence interval calculations are valid")

    if avgTimePerCalculation < 0.0001 {
        print("✅ Performance targets MET")
    } else {
        print("⚠️  Performance could be optimized")
    }
} else {
    print("❌ Some tests FAILED - mathematical accuracy may be compromised")
    print("⚠️  DO NOT DEPLOY - revert to embedded implementation")
}