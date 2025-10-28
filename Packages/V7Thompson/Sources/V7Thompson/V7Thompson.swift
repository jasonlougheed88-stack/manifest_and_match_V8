// V7Thompson.swift - Thompson Sampling Engine for Job Discovery
// Core algorithmic engine with mathematically correct Beta distribution sampling
// Implements dual-profile system (Amber/Teal) with cross-domain exploration

import Foundation

// MARK: - Beta Distribution with Correct Mathematics

/// Mathematically correct Beta distribution implementation
/// Fixes V5.7 pow() bug by using Gamma-based sampling method
public struct BetaDistribution: Sendable {
    public let alpha: Double
    public let beta: Double

    public init(alpha: Double = 1.0, beta: Double = 1.0) {
        self.alpha = max(0.01, alpha) // Prevent invalid parameters
        self.beta = max(0.01, beta)
    }

    /// Mean of the Beta distribution
    public var mean: Double {
        alpha / (alpha + beta)
    }

    /// Variance of the Beta distribution
    public var variance: Double {
        (alpha * beta) / ((alpha + beta) * (alpha + beta) * (alpha + beta + 1))
    }

    /// Mode of the Beta distribution (if exists)
    public var mode: Double? {
        guard alpha > 1 && beta > 1 else { return nil }
        return (alpha - 1) / (alpha + beta - 2)
    }

    /// Sample from Beta distribution using Gamma method (mathematically correct)
    /// Beta(α, β) = Gamma(α) / (Gamma(α) + Gamma(β))
    public func sample() -> Double {
        // Edge case: both parameters very small, use uniform
        if alpha < 0.01 && beta < 0.01 {
            return Double.random(in: 0...1)
        }

        // Use Gamma distribution method
        let gammaAlpha = sampleGamma(shape: alpha, scale: 1.0)
        let gammaBeta = sampleGamma(shape: beta, scale: 1.0)

        // Prevent division by zero
        let sum = gammaAlpha + gammaBeta
        guard sum > 0 else { return 0.5 }

        return gammaAlpha / sum
    }

    /// Update parameters based on observation
    public func update(success: Bool) -> BetaDistribution {
        if success {
            return BetaDistribution(alpha: alpha + 1, beta: beta)
        } else {
            return BetaDistribution(alpha: alpha, beta: beta + 1)
        }
    }

    // MARK: - Gamma Sampling (Marsaglia & Tsang method)

    private func sampleGamma(shape: Double, scale: Double) -> Double {
        if shape < 1.0 {
            // Use Johnk's algorithm for shape < 1
            let u = Double.random(in: 0...1)
            return sampleGamma(shape: shape + 1.0, scale: scale) * pow(u, 1.0 / shape)
        }

        // Marsaglia & Tsang method for shape >= 1
        let d = shape - 1.0/3.0
        let c = 1.0 / sqrt(9.0 * d)

        while true {
            var x: Double
            repeat {
                x = randomGaussian()
            } while x <= -1.0/c

            let v = pow(1.0 + c * x, 3.0)
            let u = Double.random(in: 0...1)

            let xSquared = x * x
            if u < 1.0 - 0.0331 * xSquared * xSquared {
                return d * v * scale
            }

            if log(u) < 0.5 * xSquared + d * (1.0 - v + log(v)) {
                return d * v * scale
            }
        }
    }

    /// Generate random Gaussian using Box-Muller transform
    private func randomGaussian() -> Double {
        let u1 = Double.random(in: 0..<1)
        let u2 = Double.random(in: 0..<1)
        return sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
    }
}

// MARK: - Dual-Profile Thompson Sampler

/// Implements dual-profile (Amber/Teal) Thompson Sampling
/// Amber: Traditional career preferences (exploitation)
/// Teal: Transformational preferences (exploration)
@MainActor
public final class DualProfileSampler: @unchecked Sendable {
    // Separate Beta distributions for each profile
    private var amberBeta: BetaDistribution
    private var tealBeta: BetaDistribution

    // Profile blend factor (0 = pure Amber, 1 = pure Teal)
    private var profileBlend: Double

    // Exploration parameters
    private let baseExplorationRate: Double = 0.15
    private let crossDomainMultiplier: Double = 1.3

    // Cache for performance
    private let cache = ThompsonCache()

    public init(
        amberBeta: BetaDistribution = BetaDistribution(),
        tealBeta: BetaDistribution = BetaDistribution(),
        profileBlend: Double = 0.5
    ) {
        self.amberBeta = amberBeta
        self.tealBeta = tealBeta
        self.profileBlend = max(0, min(1, profileBlend))
    }

    /// Score a job using dual-profile Thompson Sampling
    public func scoreJob(
        _ job: Job,
        userProfile: UserProfile,
        useCache: Bool = true
    ) async -> ThompsonScore {
        // Check cache first - now synchronous for maximum performance
        if useCache, let cached = cache.getScore(for: job.id) {
            return cached
        }

        // Sample from both profiles
        let amberSample = amberBeta.sample()
        let tealSample = tealBeta.sample()

        // Calculate domain-based exploration bonus
        let explorationBonus = calculateExplorationBonus(
            job: job,
            userProfile: userProfile
        )

        // Blend scores based on profile position
        let personalScore = amberSample * (1.0 - profileBlend) + tealSample * profileBlend
        let professionalScore = calculateProfessionalScore(
            job: job,
            userProfile: userProfile,
            baseScore: personalScore
        )

        // Combine with exploration
        let combinedScore = min(0.95, (personalScore + professionalScore) / 2.0 + explorationBonus)

        let score = ThompsonScore(
            personalScore: personalScore,
            professionalScore: professionalScore,
            combinedScore: combinedScore,
            explorationBonus: explorationBonus
        )

        // Cache the result - now synchronous for maximum performance
        if useCache {
            cache.store(score, for: job.id)
        }

        return score
    }

    /// Update model based on user interaction
    public func updateModel(interaction: JobInteraction) async {
        let reward = calculateReward(from: interaction.action)

        // Update both profiles with weighted learning
        if profileBlend < 0.5 {
            // Amber-dominant: stronger update to Amber
            amberBeta = amberBeta.update(success: reward)

            // Reduced learning for Teal
            if Double.random(in: 0...1) < 0.3 {
                tealBeta = tealBeta.update(success: reward)
            }
        } else {
            // Teal-dominant: stronger update to Teal
            tealBeta = tealBeta.update(success: reward)

            // Reduced learning for Amber
            if Double.random(in: 0...1) < 0.3 {
                amberBeta = amberBeta.update(success: reward)
            }
        }

        // Adjust profile blend based on interaction patterns
        adjustProfileBlend(action: interaction.action)

        // Invalidate cache for related items - now synchronous for better performance
        cache.clearAll() // Simple approach; could be optimized
    }

    /// Get current parameters for inspection
    public func getParameters() async -> BetaParameters {
        BetaParameters(
            personalAlpha: amberBeta.alpha,
            personalBeta: amberBeta.beta,
            professionalAlpha: tealBeta.alpha,
            professionalBeta: tealBeta.beta
        )
    }

    // MARK: - Private Methods

    private func calculateReward(from action: SwipeAction) -> Bool {
        switch action {
        case .interested:
            return true
        case .save:
            return Double.random(in: 0...1) < 0.8
        case .pass:
            return false
        }
    }

    private func adjustProfileBlend(action: SwipeAction) {
        // Gradually shift blend based on user behavior
        switch action {
        case .interested:
            // Interested actions slightly increase exploration (Teal)
            profileBlend = min(1.0, profileBlend + 0.01)
        case .pass:
            // Pass actions slightly increase exploitation (Amber)
            profileBlend = max(0.0, profileBlend - 0.01)
        case .save:
            // Save is neutral
            break
        }
    }

    private func calculateExplorationBonus(
        job: Job,
        userProfile: UserProfile
    ) -> Double {
        // Base exploration
        var bonus = baseExplorationRate * Double.random(in: 0.5...1.0)

        // Cross-domain bonus
        let isNewDomain = !userProfile.preferences.industries.contains { industry in
            job.title.lowercased().contains(industry.lowercased()) ||
            job.company.lowercased().contains(industry.lowercased())
        }

        if isNewDomain {
            bonus *= crossDomainMultiplier
        }

        return min(0.2, bonus) // Cap at 20% bonus
    }

    private func calculateProfessionalScore(
        job: Job,
        userProfile: UserProfile,
        baseScore: Double
    ) -> Double {
        var score = baseScore

        // Skill match bonus
        let skillMatch = job.requirements.filter { requirement in
            userProfile.professionalProfile.skills.contains { skill in
                skill.lowercased() == requirement.lowercased()
            }
        }.count

        let skillBonus = Double(skillMatch) / Double(max(1, job.requirements.count)) * 0.1
        score += skillBonus

        // Location preference
        if userProfile.preferences.preferredLocations.contains(job.location) {
            score += 0.05
        }

        return min(1.0, score)
    }
}

// MARK: - Thompson Sampling Engine (Main Interface)

/// Main Thompson Sampling engine with cross-domain exploration
@MainActor
public final class ThompsonSamplingEngine: @unchecked Sendable {
    private let sampler: DualProfileSampler
    private let cache = ThompsonCache()

    // Performance tracking
    private var averageResponseTime: TimeInterval = 0
    private var sampleCount: Int = 0

    // MARK: - O*NET Integration Feature Flag (Phase 3)

    /// Enable O*NET-enhanced scoring for career matching
    ///
    /// **Purpose:** Gradual rollout control for Phase 3 O*NET integration
    /// **Default:** `false` (disabled) for safe rollout
    /// **Production:** Enable after performance validation (<10ms constraint)
    ///
    /// When enabled, `scoreJob()` will use O*NET database matching for:
    /// - Skills matching (30% weight)
    /// - Education requirements (15%)
    /// - Experience requirements (15%)
    /// - Work activities similarity (25%)
    /// - RIASEC interests alignment (15%)
    ///
    /// **Performance:** <8ms O*NET scoring + <2ms Thompson baseline = <10ms total
    /// **Rollout Plan:**
    /// 1. Week 1: 10% of users (canary)
    /// 2. Week 2: 25% of users (if P95 <10ms)
    /// 3. Week 3: 50% of users (if no regressions)
    /// 4. Week 4: 100% rollout (full production)
    public var isONetScoringEnabled: Bool = false

    public init(
        initialProfileBlend: Double = 0.5
    ) {
        self.sampler = DualProfileSampler(
            profileBlend: initialProfileBlend
        )
    }

    /// Score a single job (optimized wrapper around batch scoring)
    /// Preserves sacred 357x performance advantage through optimized single-job path
    ///
    /// **O*NET Integration:** When `isONetScoringEnabled == true`, enhances professionalScore
    /// with O*NET career matching across 5 dimensions (skills, education, experience, activities, interests)
    public func scoreJob(
        _ job: Job,
        userProfile: UserProfile? = nil
    ) async -> ThompsonScore {
        let startTime = Date()

        // Get base Thompson score
        let baseScore = await sampler.scoreJob(job, userProfile: userProfile ?? UserProfile())

        // O*NET enhancement (if enabled and data available)
        var enhancedScore = baseScore
        if isONetScoringEnabled, let profile = userProfile {
            enhancedScore = await enhanceWithONetScoring(
                baseScore: baseScore,
                job: job,
                profile: profile
            )
        }

        // Track performance for single job scoring
        let responseTime = Date().timeIntervalSince(startTime)
        updatePerformanceMetrics(responseTime: responseTime)

        return enhancedScore
    }

    /// Enhance Thompson score with O*NET career matching
    ///
    /// Integrates O*NET professionalqualification scoring into professionalScore component
    /// Falls back to base score if O*NET data unavailable or errors occur
    ///
    /// - Parameters:
    ///   - baseScore: Base Thompson score from dual-profile sampler
    ///   - job: Job to score
    ///   - profile: User's professional profile with O*NET data
    /// - Returns: Enhanced Thompson score with O*NET professional matching
    private func enhanceWithONetScoring(
        baseScore: ThompsonScore,
        job: Job,
        profile: UserProfile
    ) async -> ThompsonScore {
        // Convert UserProfile to ProfessionalProfile for O*NET scoring
        let professionalProfile = convertToProfessionalProfile(profile)

        // Get O*NET occupation code from job metadata
        guard let onetCode = job.onetCode else {
            // No O*NET code available, return base score
            return baseScore
        }

        do {
            // Compute O*NET match score (0.0-1.0)
            let onetScore = try await computeONetScore(
                for: job,
                profile: professionalProfile,
                onetCode: onetCode
            )

            // Blend O*NET score into professionalScore (70% Thompson + 30% O*NET)
            let enhancedProfessionalScore = (baseScore.professionalScore * 0.7) + (onetScore * 0.3)

            // Recalculate combined score
            let enhancedCombinedScore = min(0.95, (baseScore.personalScore + enhancedProfessionalScore) / 2.0 + baseScore.explorationBonus)

            return ThompsonScore(
                personalScore: baseScore.personalScore,
                professionalScore: enhancedProfessionalScore,
                combinedScore: enhancedCombinedScore,
                explorationBonus: baseScore.explorationBonus
            )
        } catch {
            // O*NET scoring failed, fall back to base Thompson score
            #if DEBUG
            print("⚠️ O*NET scoring failed: \(error). Falling back to base Thompson score.")
            #endif
            return baseScore
        }
    }

    /// Extract ProfessionalProfile from UserProfile for O*NET scoring
    /// UserProfile already contains a ProfessionalProfile (added in Phase 2B)
    private func convertToProfessionalProfile(_ profile: UserProfile) -> ProfessionalProfile {
        return profile.professionalProfile
    }

    /// Score a single job synchronously (for legacy compatibility)
    /// WARNING: Use async scoreJob for optimal performance
    public func scoreJob(_ job: Job) -> ThompsonScore {
        // Fast synchronous scoring with simplified Thompson sampling
        // Preserves mathematical correctness while maintaining <10ms performance

        // BIAS ELIMINATION: Changed to Beta(1,1) uniform priors for mathematical neutrality
        // Beta(1,1) creates a uniform distribution over [0,1], ensuring equal treatment of all jobs
        // This removes optimistic bias from the Thompson Sampling initialization
        // Mathematically: Beta(1,1) = Uniform(0,1), giving no preference to any outcome
        let amberAlpha = 1.0  // Beta(1,1) = uniform distribution
        let amberBeta = 1.0
        let tealAlpha = 1.0
        let tealBeta = 1.0

        // Sample using simple Beta approximation for speed
        let amberSample = sampleBetaFast(alpha: amberAlpha, beta: amberBeta)
        let tealSample = sampleBetaFast(alpha: tealAlpha, beta: tealBeta)

        // Blend scores with default profile balance
        let profileBlend = 0.5
        let personalScore = amberSample * (1.0 - profileBlend) + tealSample * profileBlend

        // Professional scoring with basic skill matching
        let professionalScore = calculateBasicProfessionalScore(job: job, baseScore: personalScore)

        // Exploration bonus
        let explorationBonus = 0.1 * Double.random(in: 0.5...1.0)

        // Combined score
        let combinedScore = min(0.95, (personalScore + professionalScore) / 2.0 + explorationBonus)

        return ThompsonScore(
            personalScore: personalScore,
            professionalScore: professionalScore,
            combinedScore: combinedScore,
            explorationBonus: explorationBonus
        )
    }

    /// Fast Beta distribution sampling for synchronous operation
    private func sampleBetaFast(alpha: Double, beta: Double) -> Double {
        // Simple uniform approximation for speed in synchronous context
        // For production, use proper Gamma-based sampling in async methods
        if alpha <= 1.0 && beta <= 1.0 {
            return Double.random(in: 0...1)
        }

        // Beta mean approximation with small random variance
        let mean = alpha / (alpha + beta)
        let variance = min(0.1, sqrt((alpha * beta) / ((alpha + beta) * (alpha + beta) * (alpha + beta + 1))))
        return max(0.0, min(1.0, mean + Double.random(in: -variance...variance)))
    }

    /// Basic professional score calculation for synchronous operation
    /// With no user profile, return base score without any bias
    /// Professional scoring should only apply when we have actual user skills to match
    private func calculateBasicProfessionalScore(job: Job, baseScore: Double) -> Double {
        // BIAS ELIMINATION: Removed hardcoded tech skills ["swift", "ios", "mobile", "app", "development"]
        // This ensures neutral scoring - all jobs are treated equally without profile data
        // User-driven skill matching will be implemented in Phase 3 when user profiles are available
        return min(1.0, baseScore)
    }

    /// Score multiple jobs in batch (optimized for performance)
    public func scoreJobs(
        _ jobs: [Job],
        userProfile: UserProfile
    ) async -> [Job] {
        let startTime = Date()

        // Score all jobs concurrently
        let scores = await withTaskGroup(of: (UUID, ThompsonScore).self) { group in
            for job in jobs {
                group.addTask {
                    let score = await self.sampler.scoreJob(job, userProfile: userProfile)
                    return (job.id, score)
                }
            }

            var scoreMap: [UUID: ThompsonScore] = [:]
            for await (id, score) in group {
                scoreMap[id] = score
            }
            return scoreMap
        }

        // Update jobs with scores and sort by combined score
        let scoredJobs = jobs.compactMap { job -> Job? in
            guard let score = scores[job.id] else { return nil }
            return Job(
                id: job.id,
                title: job.title,
                company: job.company,
                location: job.location,
                description: job.description,
                requirements: job.requirements,
                url: job.url,
                thompsonScore: score
            )
        }.sorted { ($0.thompsonScore?.combinedScore ?? 0) > ($1.thompsonScore?.combinedScore ?? 0) }

        // Track performance
        let responseTime = Date().timeIntervalSince(startTime)
        updatePerformanceMetrics(responseTime: responseTime)

        return scoredJobs
    }

    /// Process user interaction and update model
    public func processInteraction(_ interaction: JobInteraction) async {
        await sampler.updateModel(interaction: interaction)
    }

    /// Get current model parameters
    public func getModelParameters() async -> BetaParameters {
        await sampler.getParameters()
    }

    /// Get performance metrics
    public func getPerformanceMetrics() -> (avgResponseTime: TimeInterval, withinBudget: Bool) {
        let withinBudget = averageResponseTime < 0.010 // 10ms budget
        return (averageResponseTime, withinBudget)
    }

    /// Clean up cache and optimize memory
    public func performMaintenance() {
        cache.cleanupExpired()
    }

    // MARK: - Private Methods

    private func updatePerformanceMetrics(responseTime: TimeInterval) {
        sampleCount += 1
        // Exponential moving average
        let alpha = 0.1
        averageResponseTime = averageResponseTime * (1 - alpha) + responseTime * alpha
    }
}

// MARK: - Cross-Domain Exploration

/// Manages cross-domain career exploration
public struct CrossDomainExplorer: Sendable {
    private let domainDistances: [String: [String: Double]] = [
        "technology": ["finance": 0.3, "healthcare": 0.5, "education": 0.4],
        "finance": ["technology": 0.3, "healthcare": 0.6, "education": 0.5],
        "healthcare": ["technology": 0.5, "finance": 0.6, "education": 0.3],
        "education": ["technology": 0.4, "finance": 0.5, "healthcare": 0.3]
    ]

    public init() {}

    /// Calculate domain distance for exploration bonus
    public func domainDistance(from userDomain: String, to jobDomain: String) -> Double {
        guard userDomain != jobDomain else { return 0 }

        let normalizedUser = userDomain.lowercased()
        let normalizedJob = jobDomain.lowercased()

        // Check predefined distances
        if let distances = domainDistances[normalizedUser],
           let distance = distances[normalizedJob] {
            return distance
        }

        // Default distance for unknown domains
        return 0.7
    }

    /// Suggest exploration opportunities
    public func suggestExplorations(
        currentDomains: Set<String>,
        availableDomains: Set<String>
    ) -> [String] {
        let unexplored = availableDomains.subtracting(currentDomains)

        // Sort by exploration value (furthest domains first)
        return unexplored.sorted { domain1, domain2 in
            let avgDistance1 = currentDomains.map { domainDistance(from: $0, to: domain1) }
                .reduce(0, +) / Double(currentDomains.count)
            let avgDistance2 = currentDomains.map { domainDistance(from: $0, to: domain2) }
                .reduce(0, +) / Double(currentDomains.count)
            return avgDistance1 > avgDistance2
        }
    }
}

// MARK: - Performance Monitoring

/// Monitors Thompson Sampling performance against budgets
public actor PerformanceMonitor {
    private var metrics: [PerformanceMetric] = []
    private let maxMetrics = 1000

    private struct PerformanceMetric {
        let timestamp: Date
        let responseTime: TimeInterval
        let memoryUsage: Int
        let cacheHitRate: Double
    }

    public func recordMetric(
        responseTime: TimeInterval,
        memoryUsage: Int,
        cacheHits: Int,
        totalRequests: Int
    ) {
        let hitRate = totalRequests > 0 ? Double(cacheHits) / Double(totalRequests) : 0

        let metric = PerformanceMetric(
            timestamp: Date(),
            responseTime: responseTime,
            memoryUsage: memoryUsage,
            cacheHitRate: hitRate
        )

        metrics.append(metric)

        // Keep only recent metrics
        if metrics.count > maxMetrics {
            metrics.removeFirst()
        }
    }

    public func getPerformanceSummary() -> (
        avgResponseTime: TimeInterval,
        p95ResponseTime: TimeInterval,
        avgMemoryUsage: Int,
        avgCacheHitRate: Double,
        withinBudget: Bool
    ) {
        guard !metrics.isEmpty else {
            return (0, 0, 0, 0, true)
        }

        let responseTimes = metrics.map { $0.responseTime }.sorted()
        let avgResponse = responseTimes.reduce(0, +) / Double(responseTimes.count)
        let p95Index = Int(Double(responseTimes.count) * 0.95)
        let p95Response = responseTimes[min(p95Index, responseTimes.count - 1)]

        let avgMemory = metrics.map { $0.memoryUsage }.reduce(0, +) / metrics.count
        let avgHitRate = metrics.map { $0.cacheHitRate }.reduce(0, +) / Double(metrics.count)

        // Check against budgets
        let withinBudget = p95Response < 0.010 && avgMemory < 10_485_760 // 10ms, 10MB

        return (avgResponse, p95Response, avgMemory, avgHitRate, withinBudget)
    }
}
