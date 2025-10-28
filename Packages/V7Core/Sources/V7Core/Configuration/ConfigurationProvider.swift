import Foundation

/// PHASE 3 TASK #11: Configuration service architecture
/// Provides protocol-based access to externalized configuration data
/// Enables bias elimination by loading diverse skills, roles, companies dynamically
///
/// This protocol defines the contract for accessing all configuration data
/// from external sources (JSON files, remote APIs, etc.). Implementations
/// must handle caching, validation, and error recovery.

// MARK: - Configuration Provider Protocol

/// Main protocol for accessing configuration data from external sources
///
/// This protocol abstracts the configuration loading mechanism, enabling:
/// - Dynamic content updates without code changes
/// - Sector-diverse data loading (Healthcare, Finance, Education, etc.)
/// - Testability through mock implementations
/// - Flexible storage backends (local files, remote APIs, databases)
///
/// All methods use async/await for non-blocking I/O operations.
/// All data types are Sendable for Swift concurrency safety.
@available(macOS 10.15, iOS 13.0, *)
public protocol ConfigurationProvider: Sendable {

    // MARK: - Configuration Loading Methods

    /// Load all skills from configuration
    ///
    /// Skills represent professional competencies across diverse sectors.
    /// Must include minimum 100 skills spanning 5+ sectors for bias elimination.
    ///
    /// - Returns: SkillsConfiguration containing all available skills
    /// - Throws: ConfigurationError if loading or validation fails
    func loadSkills() async throws -> SkillsConfiguration

    /// Load all job roles from configuration
    ///
    /// Roles represent professional positions across diverse sectors.
    /// Must include minimum 50 roles spanning 5+ sectors for bias elimination.
    ///
    /// - Returns: RolesConfiguration containing all available roles
    /// - Throws: ConfigurationError if loading or validation fails
    func loadRoles() async throws -> RolesConfiguration

    /// Load all company information from configuration
    ///
    /// Companies represent diverse employers with optional API integration.
    /// Should span multiple sectors (Healthcare, Finance, Education, etc.).
    ///
    /// - Returns: CompaniesConfiguration containing all available companies
    /// - Throws: ConfigurationError if loading or validation fails
    func loadCompanies() async throws -> CompaniesConfiguration

    /// Load RSS feed sources from configuration
    ///
    /// RSS feeds provide sector-diverse job listings.
    /// Must include minimum 10 feeds spanning 5+ sectors for bias elimination.
    ///
    /// - Returns: RSSFeedsConfiguration containing all available feeds
    /// - Throws: ConfigurationError if loading or validation fails
    func loadRSSFeeds() async throws -> RSSFeedsConfiguration

    /// Load benefits/perks from configuration
    ///
    /// Benefits represent workplace perks and compensation components.
    /// Should include diverse benefit types (health, financial, work-life balance).
    ///
    /// - Returns: BenefitsConfiguration containing all available benefits
    /// - Throws: ConfigurationError if loading or validation fails
    func loadBenefits() async throws -> BenefitsConfiguration

    // MARK: - Cache Management

    /// Reload all configurations (cache invalidation)
    ///
    /// Forces a fresh load of all configuration data, bypassing any caches.
    /// Use when configuration files have been updated or cache is corrupted.
    ///
    /// - Throws: ConfigurationError if any reload operation fails
    func reloadAllConfigurations() async throws
}

// MARK: - Default Implementations

@available(iOS 13.0, *)
public extension ConfigurationProvider {

    /// Reload all configurations by loading each one individually
    ///
    /// Default implementation that calls each load method in sequence.
    /// Implementations can override for optimized batch loading.
    func reloadAllConfigurations() async throws {
        _ = try await loadSkills()
        _ = try await loadRoles()
        _ = try await loadCompanies()
        _ = try await loadRSSFeeds()
        _ = try await loadBenefits()
    }
}
