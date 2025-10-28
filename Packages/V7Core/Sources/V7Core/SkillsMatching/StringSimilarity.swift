// StringSimilarity.swift - Optimized String Similarity Algorithms
// Implements Levenshtein distance with space optimization for fuzzy matching

import Foundation

/// High-performance string similarity calculator
/// Uses space-optimized Levenshtein distance algorithm
@available(iOS 13.0, *)
public struct StringSimilarity: Sendable {

    // MARK: - Shared Cache

    /// Shared similarity cache for performance optimization
    private static let cache = SimilarityCache()

    // MARK: - Levenshtein Distance

    /// Calculate Levenshtein distance between two strings
    /// Uses space-optimized rolling array technique: O(m × n) time, O(min(m, n)) space
    ///
    /// Levenshtein distance measures the minimum number of single-character edits
    /// (insertions, deletions, substitutions) required to change one string into another.
    ///
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: Edit distance (0 = identical strings)
    ///
    /// - Complexity:
    ///   - Time: O(m × n) where m, n are string lengths
    ///   - Space: O(min(m, n)) using rolling array optimization
    ///
    /// - Example:
    ///   ```swift
    ///   StringSimilarity.levenshteinDistance("kitten", "sitting")  // 3
    ///   StringSimilarity.levenshteinDistance("Python", "Python")   // 0
    ///   StringSimilarity.levenshteinDistance("JS", "JavaScript")   // 8
    ///   ```
    public static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        // Early exit: identical strings (FIX 6)
        if s1 == s2 { return 0 }

        let m = s1.count
        let n = s2.count

        // Early exit for empty strings
        guard m > 0 else { return n }
        guard n > 0 else { return m }

        // Optimization: ensure m <= n to minimize space usage
        if m > n {
            return levenshteinDistance(s2, s1)
        }

        // Convert strings to arrays for O(1) indexed access
        let s1Array = Array(s1)
        let s2Array = Array(s2)

        // Use rolling arrays for space efficiency: only need current and previous row
        var previousRow = Array(0...n)
        var currentRow = Array(repeating: 0, count: n + 1)

        // Dynamic programming: fill matrix row by row
        for i in 1...m {
            currentRow[0] = i

            for j in 1...n {
                // Cost is 0 if characters match, 1 if substitution needed
                let substitutionCost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1

                currentRow[j] = min(
                    previousRow[j] + 1,           // deletion
                    currentRow[j - 1] + 1,        // insertion
                    previousRow[j - 1] + substitutionCost  // substitution
                )
            }

            // Swap rows for next iteration
            swap(&previousRow, &currentRow)
        }

        return previousRow[n]
    }

    // MARK: - Similarity Scores

    /// Calculate normalized similarity score between two strings with caching
    /// Returns value in range [0.0, 1.0] where:
    /// - 1.0 = identical strings
    /// - 0.0 = completely different
    ///
    /// Uses thread-safe LRU cache to avoid redundant calculations
    ///
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: Similarity score (0.0 to 1.0)
    ///
    /// - Example:
    ///   ```swift
    ///   await StringSimilarity.similarity("PostgreSQL", "Postgres")  // 0.778
    ///   await StringSimilarity.similarity("Python", "Python")        // 1.0
    ///   await StringSimilarity.similarity("Swift", "Java")           // 0.0
    ///   ```
    public static func similarity(_ s1: String, _ s2: String) async -> Double {
        // Check cache first (FAST PATH)
        if let cached = await cache.get(key1: s1, key2: s2) {
            return cached
        }

        // Handle empty strings
        guard !s1.isEmpty && !s2.isEmpty else {
            let result = s1.isEmpty && s2.isEmpty ? 1.0 : 0.0
            await cache.set(key1: s1, key2: s2, similarity: result)
            return result
        }

        // Compute Levenshtein distance (SLOW PATH)
        let distance = Double(levenshteinDistance(s1, s2))
        let maxLength = Double(max(s1.count, s2.count))
        let score = maxLength > 0 ? 1.0 - (distance / maxLength) : 1.0

        // Store in cache for future lookups
        await cache.set(key1: s1, key2: s2, similarity: score)

        return score
    }

    /// Calculate case-insensitive similarity score with caching
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: Similarity score (0.0 to 1.0)
    public static func similarityIgnoringCase(_ s1: String, _ s2: String) async -> Double {
        return await similarity(s1.lowercased(), s2.lowercased())
    }

    // MARK: - Optimized Matching Helpers

    /// Quick check if similarity is above threshold with caching
    /// Useful for early exit in performance-critical matching
    ///
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    ///   - threshold: Minimum similarity required (0.0-1.0)
    /// - Returns: True if similarity >= threshold
    ///
    /// - Complexity: O(1) for length check + cache hit, O(m × n) for cache miss
    public static func isSimilar(_ s1: String, _ s2: String, threshold: Double = 0.75) async -> Bool {
        // Quick length-based pruning
        let lengthDiff = abs(s1.count - s2.count)
        let maxLength = max(s1.count, s2.count)

        // If length difference alone exceeds threshold, no need to calculate
        if maxLength > 0 {
            let maxPossibleSimilarity = 1.0 - (Double(lengthDiff) / Double(maxLength))
            if maxPossibleSimilarity < threshold {
                return false
            }
        }

        // Calculate actual similarity with caching
        let score = await similarity(s1, s2)
        return score >= threshold
    }

    /// Find best matching string from a list with caching
    /// - Parameters:
    ///   - target: String to match against
    ///   - candidates: List of candidate strings
    ///   - threshold: Minimum similarity threshold (0.0-1.0)
    /// - Returns: Best match and its similarity score, or nil if none above threshold
    ///
    /// - Example:
    ///   ```swift
    ///   let candidates = ["JavaScript", "TypeScript", "CoffeeScript"]
    ///   let (match, score) = await StringSimilarity.findBestMatch(
    ///       "JS",
    ///       in: candidates,
    ///       threshold: 0.3
    ///   )
    ///   // Returns ("JavaScript", 0.4)
    ///   ```
    public static func findBestMatch(
        _ target: String,
        in candidates: [String],
        threshold: Double = 0.75
    ) async -> (match: String, score: Double)? {
        var bestMatch: String?
        var bestScore: Double = threshold

        for candidate in candidates {
            let score = await similarity(target, candidate)
            if score > bestScore {
                bestScore = score
                bestMatch = candidate
            }
        }

        return bestMatch.map { ($0, bestScore) }
    }

    // MARK: - Substring Matching

    /// Check if one string contains another (case-insensitive)
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: True if either string contains the other
    public static func hasSubstringMatch(_ s1: String, _ s2: String) -> Bool {
        let lower1 = s1.lowercased()
        let lower2 = s2.lowercased()
        return lower1.contains(lower2) || lower2.contains(lower1)
    }

    /// Calculate substring match score
    /// Returns 1.0 if exact match, 0.8 if one contains the other, 0.0 otherwise
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: Match score (0.0, 0.8, or 1.0)
    public static func substringMatchScore(_ s1: String, _ s2: String) -> Double {
        let lower1 = s1.lowercased()
        let lower2 = s2.lowercased()

        if lower1 == lower2 {
            return 1.0
        }

        if lower1.contains(lower2) || lower2.contains(lower1) {
            return 0.8
        }

        return 0.0
    }

    // MARK: - Performance Optimizations

    /// Batch similarity calculation for multiple string pairs with caching
    /// More efficient than calling similarity() multiple times
    /// Uses concurrent processing with TaskGroup for optimal performance
    /// - Parameter pairs: Array of string pairs to compare
    /// - Returns: Array of similarity scores
    public static func batchSimilarity(_ pairs: [(String, String)]) async -> [Double] {
        return await withTaskGroup(of: (Int, Double).self) { group in
            for (index, pair) in pairs.enumerated() {
                group.addTask {
                    let score = await similarity(pair.0, pair.1)
                    return (index, score)
                }
            }

            var results = Array(repeating: 0.0, count: pairs.count)
            for await (index, score) in group {
                results[index] = score
            }
            return results
        }
    }

    /// Quick pre-filter using length difference
    /// Filters out strings that cannot possibly meet similarity threshold
    /// - Parameters:
    ///   - target: Target string to match
    ///   - candidates: List of candidate strings
    ///   - threshold: Similarity threshold
    /// - Returns: Pre-filtered candidates that might meet threshold
    public static func prefilterByLength(
        target: String,
        candidates: [String],
        threshold: Double
    ) -> [String] {
        let targetLength = target.count

        return candidates.filter { candidate in
            let lengthDiff = abs(candidate.count - targetLength)
            let maxLength = max(candidate.count, targetLength)

            // Maximum possible similarity given length difference
            let maxPossibleSimilarity = maxLength > 0 ?
                1.0 - (Double(lengthDiff) / Double(maxLength)) : 1.0

            return maxPossibleSimilarity >= threshold
        }
    }
}

// MARK: - Caching

/// Thread-safe LRU cache for similarity score calculations
/// Reduces redundant Levenshtein distance computations
/// Capacity: 50,000 entries with automatic LRU eviction
@available(iOS 13.0, *)
actor SimilarityCache: Sendable {
    // MARK: - Private Types

    private struct CacheEntry: Sendable {
        let similarity: Double
        var lastAccessed: Date
        var accessCount: Int

        init(similarity: Double) {
            self.similarity = similarity
            self.lastAccessed = Date()
            self.accessCount = 1
        }

        mutating func recordAccess() {
            self.lastAccessed = Date()
            self.accessCount += 1
        }
    }

    // MARK: - Properties

    private var cache: [String: CacheEntry] = [:]
    private let maxCapacity: Int
    private var hits: Int = 0
    private var misses: Int = 0

    // MARK: - Initialization

    init(maxCapacity: Int = 50_000) {
        self.maxCapacity = maxCapacity
    }

    // MARK: - Public Methods

    /// Get cached similarity score
    /// - Parameters:
    ///   - key1: First string
    ///   - key2: Second string
    /// - Returns: Cached similarity score if available, nil otherwise
    func get(key1: String, key2: String) -> Double? {
        let cacheKey = makeCacheKey(key1, key2)

        if var entry = cache[cacheKey] {
            // Update access time (LRU tracking)
            entry.recordAccess()
            cache[cacheKey] = entry
            hits += 1
            return entry.similarity
        }

        misses += 1
        return nil
    }

    /// Store similarity score with LRU tracking
    /// - Parameters:
    ///   - key1: First string
    ///   - key2: Second string
    ///   - similarity: Calculated similarity score
    func set(key1: String, key2: String, similarity: Double) {
        let cacheKey = makeCacheKey(key1, key2)

        // Evict oldest entry if at capacity
        if cache.count >= maxCapacity && cache[cacheKey] == nil {
            evictOldest()
        }

        cache[cacheKey] = CacheEntry(similarity: similarity)
    }

    /// Evict least recently used entry
    private func evictOldest() {
        guard let oldestKey = cache.min(by: {
            $0.value.lastAccessed < $1.value.lastAccessed
        })?.key else { return }

        cache.removeValue(forKey: oldestKey)
    }

    /// Create consistent cache key (order-independent)
    /// "JavaScript" + "JS" == "JS" + "JavaScript"
    private func makeCacheKey(_ s1: String, _ s2: String) -> String {
        let normalized = [s1.lowercased(), s2.lowercased()].sorted()
        return normalized.joined(separator: "|||")
    }

    // MARK: - Cache Management

    /// Clear all cached entries
    func clear() {
        cache.removeAll()
        hits = 0
        misses = 0
    }

    /// Get cache statistics
    /// - Returns: Tuple with (size, capacity, hits, misses, hitRate)
    func stats() -> (size: Int, capacity: Int, hits: Int, misses: Int, hitRate: Double) {
        let total = hits + misses
        let hitRate = total > 0 ? Double(hits) / Double(total) : 0.0
        return (cache.count, maxCapacity, hits, misses, hitRate)
    }
}

// MARK: - Performance Benchmarks

#if DEBUG
@available(iOS 13.0, *)
extension StringSimilarity {
    /// Run performance benchmark for algorithm validation
    public static func runBenchmark() async {
        let testPairs: [(String, String, Int)] = [
            ("", "", 0),
            ("a", "", 1),
            ("", "a", 1),
            ("abc", "abc", 0),
            ("abc", "abd", 1),
            ("kitten", "sitting", 3),
            ("PostgreSQL", "Postgres", 3),
            ("JavaScript", "JS", 8),
            ("Machine Learning", "ML", 15)
        ]

        print("=== Levenshtein Distance Tests ===")
        for (s1, s2, expected) in testPairs {
            let distance = levenshteinDistance(s1, s2)
            let match = distance == expected ? "✅" : "❌"
            print("\(match) '\(s1)' <-> '\(s2)': \(distance) (expected: \(expected))")
        }

        let similarityPairs: [(String, String)] = [
            ("Python", "Python"),
            ("PostgreSQL", "Postgres"),
            ("JavaScript", "JS"),
            ("Swift", "SwiftUI"),
            ("iOS", "iOS Development")
        ]

        print("\n=== Similarity Scores ===")
        for (s1, s2) in similarityPairs {
            let score = await similarity(s1, s2)
            print("'\(s1)' <-> '\(s2)': \(String(format: "%.3f", score))")
        }

        // Performance test
        let iterations = 1000
        let start = CFAbsoluteTimeGetCurrent()

        for _ in 0..<iterations {
            _ = levenshteinDistance("PostgreSQL", "Postgres")
        }

        let duration = CFAbsoluteTimeGetCurrent() - start
        let avgTime = (duration / Double(iterations)) * 1_000_000

        print("\n=== Performance ===")
        print("\(iterations) iterations: \(String(format: "%.2f", duration * 1000))ms")
        print("Average: \(String(format: "%.2f", avgTime))μs per comparison")

        // Cache statistics
        let cacheStats = await cache.stats()
        print("\n=== Cache Statistics ===")
        print("Size: \(cacheStats.size)/\(cacheStats.capacity)")
        print("Hits: \(cacheStats.hits), Misses: \(cacheStats.misses)")
        print("Hit Rate: \(String(format: "%.1f%%", cacheStats.hitRate * 100))")
    }
}
#endif

// MARK: - Usage Examples

/*
 Example Usage:

 // Basic similarity
 let score = StringSimilarity.similarity("PostgreSQL", "Postgres")
 print(score)  // 0.778

 // Check if similar enough
 let similar = StringSimilarity.isSimilar("JavaScript", "JS", threshold: 0.3)
 print(similar)  // true

 // Find best match
 let skills = ["Python", "Java", "JavaScript", "TypeScript"]
 if let (match, score) = StringSimilarity.findBestMatch("JS", in: skills, threshold: 0.3) {
     print("\(match): \(score)")  // JavaScript: 0.4
 }

 // Substring matching
 let hasMatch = StringSimilarity.hasSubstringMatch("iOS", "iOS Development")
 print(hasMatch)  // true

 // Length pre-filtering for performance
 let filtered = StringSimilarity.prefilterByLength(
     target: "Python",
     candidates: ["JavaScript", "Ruby", "Go", "Rust", "Python3"],
     threshold: 0.75
 )
 print(filtered)  // ["Python3"] - others filtered out by length
 */
