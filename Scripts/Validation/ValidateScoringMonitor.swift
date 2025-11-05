#!/usr/bin/env swift

import Foundation
import V7Performance

// Run the ScoringMonitor validation
@main
struct ValidateScoringMonitor {
    static func main() async {
        await ScoringMonitorValidation.runValidation()
    }
}