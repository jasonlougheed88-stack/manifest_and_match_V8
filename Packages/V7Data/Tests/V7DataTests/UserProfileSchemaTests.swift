//
//  UserProfileSchemaTests.swift
//  V7DataTests
//
//  Created: October 30, 2025
//  Purpose: Validate Phase 1.75 schema changes to UserProfile entity
//

import XCTest
import CoreData
@testable import V7Data

@MainActor
final class UserProfileSchemaTests: XCTestCase {

    var context: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory persistent container for testing
        persistentContainer = NSPersistentContainer(name: "V7DataModel")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                XCTFail("Failed to load Core Data stack: \(error)")
            }
        }

        context = persistentContainer.viewContext
    }

    override func tearDown() async throws {
        context = nil
        persistentContainer = nil
        try await super.tearDown()
    }

    // MARK: - Phase 1.75 New Fields Tests

    /// Test that all Phase 1.75 fields exist and have correct types
    func testUserProfileHasAllRequiredFields() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test User"
        profile.email = "test@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()

        // Phase 1.75 optional contact fields
        profile.phone = "555-123-4567"
        profile.location = "San Francisco, CA"
        profile.linkedInURL = "https://linkedin.com/in/testuser"
        profile.githubURL = "https://github.com/testuser"
        profile.professionalSummary = "Experienced iOS developer"

        // Phase 1.75 skills array
        profile.skills = ["Swift", "iOS Development", "Patient Care"]

        // Career fields
        profile.currentDomain = "Technology"
        profile.experienceLevel = "mid"

        // Job preferences
        profile.desiredRoles = ["Software Engineer"]
        profile.locations = ["San Francisco"]
        profile.remotePreference = "hybrid"
        profile.salaryMin = 100_000
        profile.salaryMax = 150_000

        // Dual-profile
        profile.amberTealPosition = 0.5

        // Save and verify
        try context.save()

        let fetchRequest = UserProfile.fetchRequest()
        let profiles = try context.fetch(fetchRequest)

        XCTAssertEqual(profiles.count, 1, "Should have exactly one profile")

        let saved = profiles.first!

        // Verify contact fields
        XCTAssertEqual(saved.name, "Test User")
        XCTAssertEqual(saved.email, "test@example.com")
        XCTAssertEqual(saved.phone, "555-123-4567")
        XCTAssertEqual(saved.location, "San Francisco, CA")
        XCTAssertEqual(saved.linkedInURL, "https://linkedin.com/in/testuser")
        XCTAssertEqual(saved.githubURL, "https://github.com/testuser")
        XCTAssertEqual(saved.professionalSummary, "Experienced iOS developer")

        // Verify skills array
        XCTAssertNotNil(saved.skills, "Skills should not be nil")
        XCTAssertEqual(saved.skills?.count, 3, "Should have 3 skills")
        XCTAssertTrue(saved.skills?.contains("Swift") ?? false)

        // Verify salary fields
        XCTAssertEqual(saved.salaryMin, 100_000)
        XCTAssertEqual(saved.salaryMax, 150_000)
    }

    /// Test that skills attribute accepts and persists array correctly
    func testUserProfileSkillsIsArray() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test"
        profile.email = "test@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "Technology"
        profile.experienceLevel = "mid"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5

        // Test empty array (default)
        profile.skills = []
        try context.save()

        var fetched = try context.fetch(UserProfile.fetchRequest()).first!
        XCTAssertNotNil(fetched.skills, "Skills should not be nil")
        XCTAssertEqual(fetched.skills?.count, 0, "Empty skills array should persist")

        // Test with O*NET-categorized skills
        profile.skills = [
            "Swift",
            "iOS Development",
            "Patient Care",
            "Financial Analysis",
            "Teaching"
        ]
        try context.save()

        // Refresh context
        context.refreshAllObjects()

        fetched = try context.fetch(UserProfile.fetchRequest()).first!
        XCTAssertEqual(fetched.skills?.count, 5, "Should have 5 skills")
        XCTAssertTrue(fetched.skills?.contains("Patient Care") ?? false, "Should contain Healthcare skill")
        XCTAssertTrue(fetched.skills?.contains("Financial Analysis") ?? false, "Should contain Finance skill")
        XCTAssertTrue(fetched.skills?.contains("Teaching") ?? false, "Should contain Education skill")
    }

    /// Test that optional fields can be nil without causing save failures
    func testUserProfileOptionalFieldsCanBeNil() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Minimal User"
        profile.email = "minimal@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "General"
        profile.experienceLevel = "entry"
        profile.remotePreference = "remote"
        profile.amberTealPosition = 0.5

        // Leave optional fields as nil
        profile.phone = nil
        profile.location = nil
        profile.linkedInURL = nil
        profile.githubURL = nil
        profile.professionalSummary = nil
        profile.skills = []  // Empty array, not nil
        profile.salaryMin = nil
        profile.salaryMax = nil

        // Should save successfully with all optional fields nil
        XCTAssertNoThrow(try context.save())

        let fetched = try context.fetch(UserProfile.fetchRequest()).first!
        XCTAssertNil(fetched.phone)
        XCTAssertNil(fetched.location)
        XCTAssertNil(fetched.professionalSummary)
        XCTAssertNotNil(fetched.skills, "Skills should be empty array, not nil")
        XCTAssertEqual(fetched.skills?.count, 0)
    }

    /// Test relationship integrity: WorkExperience requires UserProfile
    func testWorkExperienceRequiresProfileRelationship() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test"
        profile.email = "test@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "Technology"
        profile.experienceLevel = "mid"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5
        profile.skills = []

        let experience = WorkExperience(context: context)
        experience.id = UUID()
        experience.company = "Test Corp"
        experience.title = "Software Engineer"
        experience.isCurrent = true

        // Set required relationship
        experience.profile = profile

        try context.save()

        // Verify inverse relationship
        let fetchedProfile = try context.fetch(UserProfile.fetchRequest()).first!
        let experiences = fetchedProfile.workExperience?.allObjects as? [WorkExperience]

        XCTAssertEqual(experiences?.count, 1, "Should have 1 work experience")
        XCTAssertEqual(experiences?.first?.company, "Test Corp")
    }

    /// Test complete data flow: ParsedResume → UserProfile → ProfileScreen
    func testCompleteDataFlowFromParser() throws {
        // Simulate ParsedResume data
        let parsedName = "John Doe"
        let parsedEmail = "john@example.com"
        let parsedPhone = "555-987-6543"
        let parsedLocation = "New York, NY"
        let parsedSkills = ["JavaScript", "React", "Node.js", "Nursing", "Patient Care"]
        let parsedSummary = "Full-stack developer with healthcare experience"

        // Create UserProfile from parsed data
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = parsedName
        profile.email = parsedEmail
        profile.phone = parsedPhone
        profile.location = parsedLocation
        profile.skills = parsedSkills
        profile.professionalSummary = parsedSummary
        profile.createdDate = Date()
        profile.lastModified = Date()

        // Inferred fields
        profile.currentDomain = "Technology"  // Inferred from job title
        profile.experienceLevel = "mid"  // Inferred from years of experience
        profile.remotePreference = "hybrid"  // Default
        profile.amberTealPosition = 0.5

        try context.save()

        // Simulate ProfileScreen fetch
        let fetchedProfile = UserProfile.fetchCurrent(in: context)

        XCTAssertNotNil(fetchedProfile, "ProfileScreen should fetch profile")
        XCTAssertEqual(fetchedProfile?.name, parsedName)
        XCTAssertEqual(fetchedProfile?.email, parsedEmail)
        XCTAssertEqual(fetchedProfile?.phone, parsedPhone)
        XCTAssertEqual(fetchedProfile?.skills?.count, 5)
        XCTAssertTrue(fetchedProfile?.skills?.contains("Nursing") ?? false, "Should contain Healthcare skill")
        XCTAssertTrue(fetchedProfile?.skills?.contains("React") ?? false, "Should contain Technology skill")
    }

    /// Test UserDefaults import function
    func testImportSkillsFromUserDefaults() throws {
        // Setup UserDefaults with mock skills
        let mockSkills = ["Swift", "iOS", "Core Data"]
        UserDefaults.standard.set(mockSkills, forKey: "selectedSkills")
        UserDefaults.standard.set(false, forKey: "skillsImportedToCoreData")

        // Create profile
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test"
        profile.email = "test@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "Technology"
        profile.experienceLevel = "mid"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5
        profile.skills = []  // Initially empty

        try context.save()

        // Run import
        try UserProfile.importSkillsFromUserDefaults(context: context)

        // Verify skills imported
        let fetched = UserProfile.fetchCurrent(in: context)
        XCTAssertEqual(fetched?.skills?.count, 3, "Should import 3 skills")
        XCTAssertTrue(fetched?.skills?.contains("Swift") ?? false)

        // Verify import flag set
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "skillsImportedToCoreData"))

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "selectedSkills")
        UserDefaults.standard.removeObject(forKey: "skillsImportedToCoreData")
    }

    /// Test cascade delete: Deleting UserProfile deletes all child entities
    func testCascadeDeleteRemovesChildEntities() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test"
        profile.email = "test@example.com"
        profile.createdDate = Date()
        profile.lastModified = Date()
        profile.currentDomain = "Technology"
        profile.experienceLevel = "mid"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5
        profile.skills = []

        // Add work experience
        let experience = WorkExperience(context: context)
        experience.id = UUID()
        experience.company = "Test Corp"
        experience.title = "Engineer"
        experience.isCurrent = true
        experience.profile = profile

        // Add education
        let education = Education(context: context)
        education.id = UUID()
        education.institution = "Test University"
        education.degree = "BS Computer Science"
        education.profile = profile

        try context.save()

        // Verify entities exist
        XCTAssertEqual(try context.fetch(WorkExperience.fetchRequest()).count, 1)
        XCTAssertEqual(try context.fetch(Education.fetchRequest()).count, 1)

        // Delete profile
        context.delete(profile)
        try context.save()

        // Verify cascade delete removed child entities
        XCTAssertEqual(try context.fetch(UserProfile.fetchRequest()).count, 0)
        XCTAssertEqual(try context.fetch(WorkExperience.fetchRequest()).count, 0, "Cascade delete should remove WorkExperience")
        XCTAssertEqual(try context.fetch(Education.fetchRequest()).count, 0, "Cascade delete should remove Education")
    }
}
