import Foundation

/// PHASE 3 TASK #11: Configuration error handling
/// Comprehensive error types for configuration loading failures
/// Provides localized error descriptions and recovery suggestions

// MARK: - Configuration Error

/// Errors that can occur during configuration loading and validation
///
/// All errors provide localized descriptions and recovery suggestions
/// to help developers and users understand and resolve issues.
public enum ConfigurationError: Error, LocalizedError, Sendable {

    /// Configuration file was not found at the expected location
    case fileNotFound(String)

    /// Configuration file contains malformed JSON
    case invalidJSON(String)

    /// Configuration file could not be decoded into expected structure
    case decodingFailed(String, Error)

    /// Configuration data failed validation rules
    case validationFailed(String)

    /// Network error occurred while fetching remote configuration
    case networkError(Error)

    /// Configuration cache is corrupted and cannot be used
    case cacheCorrupted

    /// Unknown or unexpected error occurred
    case unknownError(Error)

    // MARK: - LocalizedError Conformance

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Configuration file not found: \(filename)"

        case .invalidJSON(let filename):
            return "Invalid JSON format in configuration file: \(filename)"

        case .decodingFailed(let filename, let error):
            return "Failed to decode configuration file \(filename): \(error.localizedDescription)"

        case .validationFailed(let message):
            return "Configuration validation failed: \(message)"

        case .networkError(let error):
            return "Network error loading configuration: \(error.localizedDescription)"

        case .cacheCorrupted:
            return "Configuration cache is corrupted and needs to be refreshed"

        case .unknownError(let error):
            return "Unknown configuration error: \(error.localizedDescription)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Ensure the configuration files are included in the app bundle. Check that the file exists at the expected path and is properly referenced in the project."

        case .invalidJSON, .decodingFailed:
            return "Check the JSON file format and structure. Ensure all required fields are present and have correct types. Validate JSON syntax using a JSON validator."

        case .validationFailed:
            return "Review the configuration data for correctness. Ensure minimum entry counts and sector diversity requirements are met."

        case .networkError:
            return "Check your internet connection and retry. If the problem persists, the configuration server may be temporarily unavailable."

        case .cacheCorrupted:
            return "Clear the app cache or reinstall the application. You may need to delete derived data and rebuild."

        case .unknownError:
            return "Contact support if the problem persists. Include error details and steps to reproduce."
        }
    }

    public var failureReason: String? {
        switch self {
        case .fileNotFound:
            return "The configuration file does not exist at the expected location"

        case .invalidJSON:
            return "The JSON structure is malformed or contains syntax errors"

        case .decodingFailed:
            return "The JSON structure does not match the expected Codable type"

        case .validationFailed:
            return "The configuration data does not meet validation requirements"

        case .networkError:
            return "Unable to fetch configuration from remote source"

        case .cacheCorrupted:
            return "Cached configuration data is invalid or incomplete"

        case .unknownError:
            return "An unexpected error occurred during configuration loading"
        }
    }
}

// MARK: - Validation Helpers

/// Validation extension for ConfigurationProvider
///
/// Provides comprehensive validation methods to ensure configuration data
/// meets quality and diversity requirements for bias elimination.
@available(iOS 13.0, *)
public extension ConfigurationProvider {

    // MARK: - Skills Validation

    /// Validate that skills configuration has minimum required entries and sector diversity
    ///
    /// Requirements:
    /// - Minimum 100 skills for adequate coverage
    /// - Minimum 5 sectors for bias elimination
    /// - All skills must have valid IDs and names
    /// - Categories must not be empty
    ///
    /// - Parameter config: The skills configuration to validate
    /// - Throws: ConfigurationError.validationFailed if validation fails
    func validateSkillsConfiguration(_ config: SkillsConfiguration) throws {
        // Check minimum skill count
        guard config.skills.count >= 100 else {
            throw ConfigurationError.validationFailed(
                "Skills configuration must have at least 100 skills for adequate coverage, found \(config.skills.count)"
            )
        }

        // Check sector diversity (at least 5 sectors)
        let sectors = Set(config.skills.map { $0.category })
        guard sectors.count >= 5 else {
            throw ConfigurationError.validationFailed(
                "Skills must span at least 5 sectors for bias elimination, found \(sectors.count): \(sectors.sorted().joined(separator: ", "))"
            )
        }

        // Validate individual skills
        for skill in config.skills {
            guard !skill.id.isEmpty else {
                throw ConfigurationError.validationFailed("Skill has empty ID")
            }
            guard !skill.name.isEmpty else {
                throw ConfigurationError.validationFailed("Skill '\(skill.id)' has empty name")
            }
            guard !skill.category.isEmpty else {
                throw ConfigurationError.validationFailed("Skill '\(skill.id)' has empty category")
            }
        }

        // Check for duplicate IDs
        let ids = config.skills.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ConfigurationError.validationFailed("Skills configuration contains duplicate IDs")
        }

        print("✅ Skills configuration validated: \(config.skills.count) skills across \(sectors.count) sectors")
        print("   Sectors: \(sectors.sorted().joined(separator: ", "))")
    }

    // MARK: - Roles Validation

    /// Validate that roles configuration has sector diversity
    ///
    /// Requirements:
    /// - Minimum 50 roles for adequate coverage
    /// - Minimum 5 sectors for bias elimination
    /// - All roles must have valid IDs and titles
    /// - Sectors must not be empty
    ///
    /// - Parameter config: The roles configuration to validate
    /// - Throws: ConfigurationError.validationFailed if validation fails
    func validateRolesConfiguration(_ config: RolesConfiguration) throws {
        // Check minimum role count
        guard config.roles.count >= 50 else {
            throw ConfigurationError.validationFailed(
                "Roles configuration must have at least 50 roles for adequate coverage, found \(config.roles.count)"
            )
        }

        // Check sector diversity
        let sectors = Set(config.roles.map { $0.sector })
        guard sectors.count >= 5 else {
            throw ConfigurationError.validationFailed(
                "Roles must span at least 5 sectors for bias elimination, found \(sectors.count): \(sectors.sorted().joined(separator: ", "))"
            )
        }

        // Validate individual roles
        for role in config.roles {
            guard !role.id.isEmpty else {
                throw ConfigurationError.validationFailed("Role has empty ID")
            }
            guard !role.title.isEmpty else {
                throw ConfigurationError.validationFailed("Role '\(role.id)' has empty title")
            }
            guard !role.sector.isEmpty else {
                throw ConfigurationError.validationFailed("Role '\(role.id)' has empty sector")
            }
        }

        // Check for duplicate IDs
        let ids = config.roles.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ConfigurationError.validationFailed("Roles configuration contains duplicate IDs")
        }

        print("✅ Roles configuration validated: \(config.roles.count) roles across \(sectors.count) sectors")
        print("   Sectors: \(sectors.sorted().joined(separator: ", "))")
    }

    // MARK: - Companies Validation

    /// Validate that companies configuration has sector diversity
    ///
    /// Requirements:
    /// - Minimum 20 companies for adequate coverage
    /// - Minimum 5 sectors for bias elimination
    /// - All companies must have valid IDs and names
    /// - API endpoints must be valid URLs if provided
    ///
    /// - Parameter config: The companies configuration to validate
    /// - Throws: ConfigurationError.validationFailed if validation fails
    func validateCompaniesConfiguration(_ config: CompaniesConfiguration) throws {
        // Check minimum company count
        guard config.companies.count >= 20 else {
            throw ConfigurationError.validationFailed(
                "Companies configuration must have at least 20 companies for adequate coverage, found \(config.companies.count)"
            )
        }

        // Check sector diversity
        let sectors = Set(config.companies.map { $0.sector })
        guard sectors.count >= 5 else {
            throw ConfigurationError.validationFailed(
                "Companies must span at least 5 sectors for bias elimination, found \(sectors.count): \(sectors.sorted().joined(separator: ", "))"
            )
        }

        // Validate individual companies
        for company in config.companies {
            guard !company.id.isEmpty else {
                throw ConfigurationError.validationFailed("Company has empty ID")
            }
            guard !company.name.isEmpty else {
                throw ConfigurationError.validationFailed("Company '\(company.id)' has empty name")
            }
            guard !company.sector.isEmpty else {
                throw ConfigurationError.validationFailed("Company '\(company.id)' has empty sector")
            }

            // Validate API endpoint if provided
            if let endpoint = company.apiEndpoint {
                guard URL(string: endpoint) != nil else {
                    throw ConfigurationError.validationFailed("Company '\(company.name)' has invalid API endpoint: \(endpoint)")
                }
            }
        }

        // Check for duplicate IDs
        let ids = config.companies.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ConfigurationError.validationFailed("Companies configuration contains duplicate IDs")
        }

        let apiEnabledCount = config.companies.filter { $0.apiType != nil }.count
        print("✅ Companies configuration validated: \(config.companies.count) companies across \(sectors.count) sectors")
        print("   Sectors: \(sectors.sorted().joined(separator: ", "))")
        print("   API-enabled companies: \(apiEnabledCount)")
    }

    // MARK: - RSS Feeds Validation

    /// Validate RSS feeds configuration has sector diversity
    ///
    /// Requirements:
    /// - Minimum 10 feeds for adequate coverage
    /// - Minimum 5 sectors for bias elimination
    /// - All feeds must have valid URLs
    /// - Update frequencies must be valid values
    ///
    /// - Parameter config: The RSS feeds configuration to validate
    /// - Throws: ConfigurationError.validationFailed if validation fails
    func validateRSSFeedsConfiguration(_ config: RSSFeedsConfiguration) throws {
        // Check minimum feed count
        guard config.feeds.count >= 10 else {
            throw ConfigurationError.validationFailed(
                "RSS feeds configuration must have at least 10 feeds for adequate coverage, found \(config.feeds.count)"
            )
        }

        // Check sector diversity
        let sectors = Set(config.feeds.map { $0.sector })
        guard sectors.count >= 5 else {
            throw ConfigurationError.validationFailed(
                "RSS feeds must span at least 5 sectors for bias elimination, found \(sectors.count): \(sectors.sorted().joined(separator: ", "))"
            )
        }

        // Validate individual feeds
        for feed in config.feeds {
            guard !feed.id.isEmpty else {
                throw ConfigurationError.validationFailed("RSS feed has empty ID")
            }
            guard !feed.name.isEmpty else {
                throw ConfigurationError.validationFailed("RSS feed '\(feed.id)' has empty name")
            }
            guard !feed.sector.isEmpty else {
                throw ConfigurationError.validationFailed("RSS feed '\(feed.id)' has empty sector")
            }

            // Validate URL
            guard URL(string: feed.url) != nil else {
                throw ConfigurationError.validationFailed("RSS feed '\(feed.name)' has invalid URL: \(feed.url)")
            }

            // Validate update frequency
            let validFrequencies = ["hourly", "daily", "weekly", "monthly"]
            guard validFrequencies.contains(feed.updateFrequency.lowercased()) else {
                throw ConfigurationError.validationFailed(
                    "RSS feed '\(feed.name)' has invalid update frequency: \(feed.updateFrequency). Must be one of: \(validFrequencies.joined(separator: ", "))"
                )
            }
        }

        // Check for duplicate IDs
        let ids = config.feeds.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ConfigurationError.validationFailed("RSS feeds configuration contains duplicate IDs")
        }

        print("✅ RSS feeds configuration validated: \(config.feeds.count) feeds across \(sectors.count) sectors")
        print("   Sectors: \(sectors.sorted().joined(separator: ", "))")
    }

    // MARK: - Benefits Validation

    /// Validate benefits configuration
    ///
    /// Requirements:
    /// - Minimum 20 benefits for adequate coverage
    /// - Minimum 3 categories for diversity
    /// - All benefits must have valid IDs and names
    ///
    /// - Parameter config: The benefits configuration to validate
    /// - Throws: ConfigurationError.validationFailed if validation fails
    func validateBenefitsConfiguration(_ config: BenefitsConfiguration) throws {
        // Check minimum benefit count
        guard config.benefits.count >= 20 else {
            throw ConfigurationError.validationFailed(
                "Benefits configuration must have at least 20 benefits for adequate coverage, found \(config.benefits.count)"
            )
        }

        // Check category diversity
        let categories = Set(config.benefits.map { $0.category })
        guard categories.count >= 3 else {
            throw ConfigurationError.validationFailed(
                "Benefits must span at least 3 categories, found \(categories.count): \(categories.sorted().joined(separator: ", "))"
            )
        }

        // Validate individual benefits
        for benefit in config.benefits {
            guard !benefit.id.isEmpty else {
                throw ConfigurationError.validationFailed("Benefit has empty ID")
            }
            guard !benefit.name.isEmpty else {
                throw ConfigurationError.validationFailed("Benefit '\(benefit.id)' has empty name")
            }
            guard !benefit.category.isEmpty else {
                throw ConfigurationError.validationFailed("Benefit '\(benefit.id)' has empty category")
            }
        }

        // Check for duplicate IDs
        let ids = config.benefits.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ConfigurationError.validationFailed("Benefits configuration contains duplicate IDs")
        }

        print("✅ Benefits configuration validated: \(config.benefits.count) benefits across \(categories.count) categories")
        print("   Categories: \(categories.sorted().joined(separator: ", "))")
    }

    // MARK: - Full Validation

    /// Validate all configurations
    ///
    /// Convenience method to validate all configuration types at once.
    /// Useful for initial app startup validation.
    ///
    /// - Throws: ConfigurationError if any validation fails
    func validateAllConfigurations() async throws {
        print("\n🔍 Validating all configurations...")

        let skills = try await loadSkills()
        try validateSkillsConfiguration(skills)

        let roles = try await loadRoles()
        try validateRolesConfiguration(roles)

        let companies = try await loadCompanies()
        try validateCompaniesConfiguration(companies)

        let rssFeeds = try await loadRSSFeeds()
        try validateRSSFeedsConfiguration(rssFeeds)

        let benefits = try await loadBenefits()
        try validateBenefitsConfiguration(benefits)

        print("\n✅ All configurations validated successfully\n")
    }
}
