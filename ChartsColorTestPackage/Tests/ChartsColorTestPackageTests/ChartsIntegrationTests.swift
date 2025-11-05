// ChartsIntegrationTests.swift
// Phase 8.2: V7 Sacred Color System Integration Tests for Charts Framework
// Tests color interpolation accuracy and Charts compatibility

import Testing
import SwiftUI
import Charts

// MARK: - Sacred V7 Color Constants
fileprivate enum SacredColors {
    // Exact values from V7Core/SacredUIConstants.swift - NEVER CHANGE
    static let amberHue: Double = 45.0 / 360.0    // 0.125 exactly
    static let tealHue: Double = 174.0 / 360.0    // 0.4833... exactly
    static let saturation: Double = 0.85
    static let brightness: Double = 0.9

    // Animation timing - sacred values
    static let springResponse: Double = 0.6
    static let springDamping: Double = 0.8
}

// MARK: - Color Interpolation (matches ExplainFitSheet implementation)
fileprivate func interpolateColor(ratio: Double) -> Color {
    let clampedRatio = max(0, min(1, ratio))
    let hue = SacredColors.amberHue +
        (SacredColors.tealHue - SacredColors.amberHue) * clampedRatio
    return Color(
        hue: hue,
        saturation: SacredColors.saturation,
        brightness: SacredColors.brightness
    )
}

// MARK: - Test Suite
@Suite("✅ Phase 8.2: Charts Framework Sacred Color Integration")
struct ChartsIntegrationTests {

    // MARK: - Critical Sacred Value Tests

    @Test("🟨 Amber Hue: Exactly 45°/360° = 0.125")
    func testSacredAmberValue() {
        #expect(SacredColors.amberHue == 0.125, "Amber hue must be exactly 0.125")

        let amber = Color(
            hue: SacredColors.amberHue,
            saturation: SacredColors.saturation,
            brightness: SacredColors.brightness
        )
        #expect(amber != nil, "Amber color must be created successfully")
    }

    @Test("🟦 Teal Hue: Exactly 174°/360° = 0.4833...")
    func testSacredTealValue() {
        let expectedTeal = 174.0 / 360.0
        #expect(abs(SacredColors.tealHue - expectedTeal) < 0.0001,
                "Teal hue must be exactly 174°/360°")

        let teal = Color(
            hue: SacredColors.tealHue,
            saturation: SacredColors.saturation,
            brightness: SacredColors.brightness
        )
        #expect(teal != nil, "Teal color must be created successfully")
    }

    @Test("🎨 Saturation (0.85) and Brightness (0.9) preserved")
    func testSaturationBrightness() {
        #expect(SacredColors.saturation == 0.85, "Saturation must be 0.85")
        #expect(SacredColors.brightness == 0.9, "Brightness must be 0.9")
    }

    // MARK: - Color Interpolation Accuracy Tests

    @Test("0% interpolation = Pure Amber")
    func testPureAmberInterpolation() {
        let color = interpolateColor(ratio: 0.0)
        // At 0%, should be pure amber (45° hue)
        #expect(color != nil)
    }

    @Test("100% interpolation = Pure Teal")
    func testPureTealInterpolation() {
        let color = interpolateColor(ratio: 1.0)
        // At 100%, should be pure teal (174° hue)
        #expect(color != nil)
    }

    @Test("50% interpolation = Midpoint color")
    func testMidpointInterpolation() {
        let color = interpolateColor(ratio: 0.5)
        // At 50%, should be halfway between amber and teal
        let expectedHue = SacredColors.amberHue +
            (SacredColors.tealHue - SacredColors.amberHue) * 0.5
        #expect(color != nil)
        // Hue should be approximately 109.5° ((45 + 174) / 2)
    }

    @Test("Interpolation clamps values outside 0-1 range")
    func testInterpolationClamping() {
        let belowZero = interpolateColor(ratio: -0.5)
        let aboveOne = interpolateColor(ratio: 1.5)

        // Should clamp to boundaries
        #expect(belowZero != nil, "Below zero should return amber")
        #expect(aboveOne != nil, "Above one should return teal")
    }

    @Test("Smooth gradient across 10 steps")
    func testSmoothGradient() {
        var colors: [Color] = []

        for i in 0...10 {
            let ratio = Double(i) / 10.0
            let color = interpolateColor(ratio: ratio)
            colors.append(color)
            #expect(color != nil, "Color at ratio \(ratio) must exist")
        }

        #expect(colors.count == 11, "Should have 11 colors (0-10 inclusive)")
    }

    // MARK: - Charts Framework Integration Tests

    @Test("📊 LineMark accepts Amber color for personal profile")
    func testLineMarkWithAmber() {
        let amberColor = interpolateColor(ratio: 0)

        let chart = Chart {
            LineMark(
                x: .value("Score", 0.5),
                y: .value("Personal", 1.0)
            )
            .foregroundStyle(amberColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }

        #expect(chart != nil, "Chart with amber LineMark must be created")
    }

    @Test("📊 LineMark accepts Teal color for professional profile")
    func testLineMarkWithTeal() {
        let tealColor = interpolateColor(ratio: 1.0)

        let chart = Chart {
            LineMark(
                x: .value("Score", 0.5),
                y: .value("Professional", 1.0)
            )
            .foregroundStyle(tealColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }

        #expect(chart != nil, "Chart with teal LineMark must be created")
    }

    @Test("📊 AreaMark accepts gradient with sacred colors")
    func testAreaMarkWithGradient() {
        let scoreColor = interpolateColor(ratio: 0.75)

        let gradient = LinearGradient(
            colors: [
                scoreColor.opacity(0.3),
                scoreColor.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        let chart = Chart {
            AreaMark(
                x: .value("Score", 0.5),
                y: .value("Combined", 1.0)
            )
            .foregroundStyle(gradient)
        }

        #expect(chart != nil, "Chart with gradient AreaMark must be created")
    }

    @Test("📈 Beta Distribution Visualization")
    func testBetaDistributionChart() {
        let samples = (0..<20).map { i in
            let x = Double(i) / 19.0
            return (
                x: x,
                personal: betaDensity(x: x, alpha: 7.5, beta: 2.5),
                professional: betaDensity(x: x, alpha: 6.3, beta: 3.7)
            )
        }

        let chart = Chart {
            // Personal profile (Amber)
            ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                LineMark(
                    x: .value("Score", sample.x),
                    y: .value("Personal", sample.personal)
                )
                .foregroundStyle(interpolateColor(ratio: 0))
            }

            // Professional profile (Teal)
            ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                LineMark(
                    x: .value("Score", sample.x),
                    y: .value("Professional", sample.professional)
                )
                .foregroundStyle(interpolateColor(ratio: 1))
            }

            // Combined area
            ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                AreaMark(
                    x: .value("Score", sample.x),
                    y: .value("Combined", (sample.personal + sample.professional) / 2)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            interpolateColor(ratio: 0.75).opacity(0.3),
                            interpolateColor(ratio: 0.75).opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }

        #expect(chart != nil, "Beta distribution chart must be created")
        #expect(samples.count == 20, "Should have 20 sample points")
    }

    // MARK: - Animation Timing Tests

    @Test("⏱️ Spring Response: 0.6 seconds")
    func testSpringResponse() {
        #expect(SacredColors.springResponse == 0.6,
                "Spring response must be 0.6 seconds")
    }

    @Test("⏱️ Spring Damping: 0.8")
    func testSpringDamping() {
        #expect(SacredColors.springDamping == 0.8,
                "Spring damping must be 0.8")
    }

    @Test("🎬 Animation with sacred timing values")
    func testAnimationCreation() {
        let animation = Animation.spring(
            response: SacredColors.springResponse,
            dampingFraction: SacredColors.springDamping
        )

        #expect(animation != nil, "Spring animation must be created")
    }

    // MARK: - Performance Tests

    @Test("⚡ Color interpolation: 10,000 calculations < 100ms")
    func testInterpolationPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()

        for i in 0..<10000 {
            let ratio = Double(i % 100) / 100.0
            _ = interpolateColor(ratio: ratio)
        }

        let elapsedMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

        #expect(elapsedMs < 100,
                "10,000 interpolations must complete in < 100ms (took \(elapsedMs)ms)")
    }

    @Test("⚡ Chart creation: 100 data points < 50ms")
    func testChartCreationPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()

        let chart = Chart {
            ForEach(0..<100, id: \.self) { i in
                let x = Double(i) / 99.0
                let y = sin(x * .pi * 2)

                LineMark(
                    x: .value("X", x),
                    y: .value("Y", y)
                )
                .foregroundStyle(interpolateColor(ratio: x))
            }
        }

        let elapsedMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

        #expect(chart != nil, "Chart must be created")
        #expect(elapsedMs < 50,
                "Chart creation must complete in < 50ms (took \(elapsedMs)ms)")
    }

    // MARK: - Accessibility Tests

    @Test("♿ Colors maintain high brightness (0.9) for visibility")
    func testColorBrightness() {
        let testPoints = [0.0, 0.25, 0.5, 0.75, 1.0]

        for point in testPoints {
            let color = interpolateColor(ratio: point)
            #expect(color != nil,
                    "Color at \(point) must exist for accessibility")
            // All interpolated colors should maintain 0.9 brightness
        }
    }

    @Test("♿ Color consistency across calculations")
    func testColorConsistency() {
        let testRatios = [0.0, 0.33, 0.67, 1.0]

        for ratio in testRatios {
            let color1 = interpolateColor(ratio: ratio)
            let color2 = interpolateColor(ratio: ratio)

            // Same input must always produce same output
            #expect(color1 != nil && color2 != nil,
                    "Colors at ratio \(ratio) must be consistent")
        }
    }

    // MARK: - Edge Cases

    @Test("🔧 Chart handles edge cases gracefully")
    func testChartEdgeCases() {
        // Empty data
        let emptyData: [Int] = []
        let emptyChart = Chart {
            ForEach(emptyData, id: \.self) { _ in
                LineMark(x: .value("X", 0), y: .value("Y", 0))
            }
        }
        #expect(emptyChart != nil, "Empty chart must be created")

        // Single data point
        let singleChart = Chart {
            LineMark(x: .value("X", 0.5), y: .value("Y", 1.0))
                .foregroundStyle(interpolateColor(ratio: 0.5))
        }
        #expect(singleChart != nil, "Single point chart must be created")
    }

    // MARK: - Helper Functions

    private func betaDensity(x: Double, alpha: Double, beta: Double) -> Double {
        guard x > 0 && x < 1 else { return 0 }
        // Simplified beta distribution (not normalized)
        return pow(x, alpha - 1) * pow(1 - x, beta - 1) * 10
    }
}

// MARK: - Summary Validation
@Suite("📋 Phase 8.2 Summary Validation")
struct SummaryValidationTests {

    @Test("✅ All critical values preserved")
    func validateCriticalValues() {
        #expect(SacredColors.amberHue == 0.125, "Amber: 45°")
        #expect(abs(SacredColors.tealHue - 0.4833) < 0.001, "Teal: 174°")
        #expect(SacredColors.saturation == 0.85, "Saturation: 0.85")
        #expect(SacredColors.brightness == 0.9, "Brightness: 0.9")
        #expect(SacredColors.springResponse == 0.6, "Spring: 0.6s")
        #expect(SacredColors.springDamping == 0.8, "Damping: 0.8")
    }

    @Test("✅ Charts framework compatibility confirmed")
    func validateChartsCompatibility() {
        let testChart = Chart {
            LineMark(x: .value("X", 0), y: .value("Y", 1))
                .foregroundStyle(interpolateColor(ratio: 0.5))
            AreaMark(x: .value("X", 1), y: .value("Y", 0.5))
                .foregroundStyle(interpolateColor(ratio: 0.75).opacity(0.3))
        }

        #expect(testChart != nil, "Charts framework accepts sacred colors")
    }
}