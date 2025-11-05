//
//  UserProfile+Location.swift
//  V7Data
//
//  Created: November 5, 2025
//  Purpose: Location preferences and search radius management
//  Phase: V8 - Job Source Location Implementation
//

import Foundation
import CoreData
import OSLog

extension UserProfile {
    /// Returns the effective location to use for job searches
    ///
    /// Priority order:
    /// 1. primaryLocation (user-selected main location)
    /// 2. First location from locations array
    /// 3. "Remote" as fallback
    ///
    /// - Returns: Location string to use for job search queries
    @MainActor
    public var effectiveLocation: String {
        // Priority 1: Primary location
        if let primary = primaryLocation, !primary.isEmpty {
            return primary
        }

        // Priority 2: First location from array
        if let locations = locations as? [String],
           let first = locations.first, !first.isEmpty {
            return first
        }

        // Priority 3: Fallback to Remote
        return "Remote"
    }

    /// Returns the effective search radius in miles
    ///
    /// Defaults to 50 miles if not set
    ///
    /// - Returns: Search radius in miles
    @MainActor
    public var effectiveSearchRadius: Int {
        return Int(searchRadius)
    }

    /// Sets the primary location and updates lastModified
    ///
    /// - Parameter location: The new primary location
    @MainActor
    public func setPrimaryLocation(_ location: String) {
        self.primaryLocation = location.isEmpty ? nil : location
        self.lastModified = Date()
    }

    /// Sets the search radius and updates lastModified
    ///
    /// - Parameter radius: The new search radius in miles (clamped to 10-100 range)
    @MainActor
    public func setSearchRadius(_ radius: Double) {
        // Clamp radius to reasonable range
        self.searchRadius = min(max(radius, 10.0), 100.0)
        self.lastModified = Date()
    }

    /// Adds a location to the locations array if not already present
    ///
    /// - Parameter location: The location to add
    @MainActor
    public func addLocation(_ location: String) {
        guard !location.isEmpty else { return }

        var currentLocations = (locations as? [String]) ?? []

        // Don't add duplicates
        guard !currentLocations.contains(location) else { return }

        currentLocations.append(location)
        self.locations = currentLocations as NSObject
        self.lastModified = Date()
    }

    /// Removes a location from the locations array
    ///
    /// - Parameter location: The location to remove
    @MainActor
    public func removeLocation(_ location: String) {
        var currentLocations = (locations as? [String]) ?? []
        currentLocations.removeAll { $0 == location }
        self.locations = currentLocations as NSObject
        self.lastModified = Date()
    }

    /// Normalizes a location string for matching
    ///
    /// Examples:
    /// - "San Francisco, CA" -> "san francisco"
    /// - "New York City" -> "new york city"
    /// - "  Chicago  " -> "chicago"
    ///
    /// - Parameter location: Raw location string
    /// - Returns: Normalized location for comparison
    public static func normalizeLocation(_ location: String) -> String {
        return location
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ", ca", with: "")
            .replacingOccurrences(of: ", ny", with: "")
            .replacingOccurrences(of: ", tx", with: "")
            .replacingOccurrences(of: ", fl", with: "")
            .replacingOccurrences(of: ", il", with: "")
            .replacingOccurrences(of: " city", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Checks if a job location matches user's preferred locations
    ///
    /// - Parameter jobLocation: The job's location string
    /// - Returns: True if location matches any preferred location
    @MainActor
    public func matchesLocation(_ jobLocation: String) -> Bool {
        // Remote jobs always match
        if jobLocation.lowercased().contains("remote") {
            return true
        }

        let normalizedJobLocation = Self.normalizeLocation(jobLocation)

        // Check primary location
        if let primary = primaryLocation {
            let normalizedPrimary = Self.normalizeLocation(primary)
            if normalizedJobLocation.contains(normalizedPrimary) ||
               normalizedPrimary.contains(normalizedJobLocation) {
                return true
            }
        }

        // Check all locations
        if let allLocations = locations as? [String] {
            for userLocation in allLocations {
                let normalized = Self.normalizeLocation(userLocation)
                if normalizedJobLocation.contains(normalized) ||
                   normalized.contains(normalizedJobLocation) {
                    return true
                }
            }
        }

        return false
    }
}
