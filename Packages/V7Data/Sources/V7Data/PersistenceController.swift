//
//  PersistenceController.swift
//  V7Data
//
//  Created: November 5, 2025
//  Purpose: Core Data stack management and preview support
//

import CoreData
import OSLog

/// Manages the Core Data persistence stack
public struct PersistenceController {
    /// Shared persistence controller for production use
    public static let shared = PersistenceController()

    /// Preview persistence controller for SwiftUI previews
    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample data for previews
        do {
            let profile = UserProfile(context: viewContext)
            profile.id = UUID()
            profile.name = "Preview User"
            profile.email = "preview@example.com"
            profile.createdDate = Date()
            profile.lastModified = Date()
            profile.currentDomain = "technology"
            profile.experienceLevel = "mid"
            profile.primaryLocation = "San Francisco, CA"
            profile.searchRadius = 50.0
            profile.locations = ["San Francisco, CA", "Remote"] as NSObject
            profile.skills = ["Swift", "SwiftUI", "iOS Development"] as NSObject
            profile.amberTealPosition = 0.5
            profile.explorationRate = 0.3
            profile.confidenceThreshold = 0.7
            profile.remotePreference = "hybrid"

            try viewContext.save()
        } catch {
            let logger = Logger(subsystem: "com.manifestandmatch.v7data", category: "PersistenceController")
            logger.error("Failed to create preview data: \(error.localizedDescription)")
        }

        return result
    }()

    /// The Core Data persistent container
    public let container: NSPersistentContainer

    /// Initialize a new persistence controller
    ///
    /// - Parameter inMemory: If true, uses an in-memory store for testing/previews
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "V7DataModel")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                let logger = Logger(subsystem: "com.manifestandmatch.v7data", category: "PersistenceController")
                logger.critical("Failed to load Core Data store: \(error.localizedDescription)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// MARK: - UserProfile Extensions

extension UserProfile {
    /// Fetch the current user's profile
    ///
    /// - Parameter context: The managed object context to fetch from
    /// - Returns: The user's profile, or nil if it doesn't exist
    @MainActor
    public static func fetchCurrent(in context: NSManagedObjectContext) -> UserProfile? {
        let request = UserProfile.fetchRequest()
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            let logger = Logger(subsystem: "com.manifestandmatch.v7data", category: "UserProfile")
            logger.error("Failed to fetch current user profile: \(error.localizedDescription)")
            return nil
        }
    }

    /// Create or fetch the current user's profile
    ///
    /// - Parameter context: The managed object context
    /// - Returns: The user's profile (existing or newly created)
    @MainActor
    public static func createOrFetch(in context: NSManagedObjectContext) -> UserProfile {
        if let existing = fetchCurrent(in: context) {
            return existing
        }

        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "technology"
        profile.experienceLevel = "mid"
        profile.searchRadius = 50.0
        profile.amberTealPosition = 0.5
        profile.explorationRate = 0.3
        profile.confidenceThreshold = 0.7
        profile.remotePreference = "hybrid"

        return profile
    }
}
