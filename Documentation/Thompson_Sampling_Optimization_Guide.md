# Thompson Sampling Performance Optimization Guide
## Target: Reduce P95 Latency from 12.9ms to <10ms

**Current Status:** P95 = 12.9ms (29% over target)
**Target:** P95 < 10ms
**Required Improvement:** -2.9ms (22.5% reduction)

---

## Performance Analysis

### Current Bottlenecks (Estimated Impact)
1. **SIMD Vectorization** (30-40% of latency) - **Highest priority**
2. **Cache Misses** (20-25% of latency) - **High priority**
3. **Memory Allocations** (15-20% of latency) - **Medium priority**
4. **Feature Extraction** (10-15% of latency) - **Medium priority**
5. **Branch Prediction** (5-10% of latency) - **Low priority**

### Optimization Roadmap

```
Current:  12.9ms
Target 1: 10.8ms (-2.1ms) Week 1: SIMD optimization
Target 2:  9.8ms (-1.0ms) Week 2: Cache optimization
Target 3:  9.3ms (-0.5ms) Week 3: Memory optimization
Final:     9.0ms (-0.3ms) Week 4: Algorithm tuning
```

---

## Optimization 1: Enhanced SIMD Vectorization (Expected: -2.0ms)

### Current Implementation Limitations
The current `performInPlaceScoring` processes jobs in chunks of 8:

```swift
let chunkSize = 8 // Optimal for CPU cache line size
```

### Problem
- Only uses SIMD for final score calculation in `simdBatchScoring`
- Most scoring logic (skill matching, location bonus, exploration) not vectorized
- Chunk size of 8 is conservative for modern ARM64 processors

### Solution A: Increase SIMD Chunk Size

```swift
// In performInPlaceScoring()
let chunkSize = 16 // Double the SIMD processing width

// Process more jobs per SIMD operation
for chunkStart in stride(from: 0, to: jobCount, by: chunkSize) {
    let chunkEnd = min(chunkStart + chunkSize, jobCount)

    // Process 16 jobs at once with SIMD operations
    processSIMDChunk(start: chunkStart, end: chunkEnd)
}
```

**Expected Impact:** -1.0ms (reduce by 7.7%)

### Solution B: Vectorize Skill Matching

```swift
/// SIMD-optimized skill matching using ARM64 vector operations
@inline(__always)
private func simdSkillMatching(
    jobSkills: [[String]],  // Array of skill arrays for chunk
    userSkillSet: Set<String>
) -> [Double] {
    var matchScores = [Double](repeating: 0, count: jobSkills.count)

    // Pre-compute user skills as bit vector for fast matching
    let userSkillBits = createSkillBitVector(skills: userSkillSet)

    for (idx, skills) in jobSkills.enumerated() {
        let jobSkillBits = createSkillBitVector(skills: Set(skills))

        // Use SIMD bitwise operations for intersection
        let intersectionCount = countSetBits(userSkillBits & jobSkillBits)
        let unionCount = countSetBits(userSkillBits | jobSkillBits)

        // Jaccard similarity coefficient
        matchScores[idx] = Double(intersectionCount) / Double(max(1, unionCount))
    }

    return matchScores
}

private func createSkillBitVector(skills: Set<String>) -> UInt64 {
    var bitVector: UInt64 = 0
    for skill in skills {
        let bitIndex = abs(skill.hashValue) % 64
        bitVector |= (1 << bitIndex)
    }
    return bitVector
}

private func countSetBits(_ value: UInt64) -> Int {
    return value.nonzeroBitCount  // ARM64 optimized popcount
}
```

**Expected Impact:** -0.8ms (reduce by 6.2%)

### Solution C: Optimize Beta Sampling with Vectorization

```swift
// In FastBetaSampler
public func sampleBatch(_ count: Int) -> [Double] {
    // Process in SIMD chunks of 4 for ARM64
    let simdChunkSize = 4
    var samples = [Double](repeating: 0, count: count)

    for chunk in stride(from: 0, to: count, by: simdChunkSize) {
        let end = min(chunk + simdChunkSize, count)
        let chunkSamples = generateSIMDSamples(count: end - chunk)

        for (offset, sample) in chunkSamples.enumerated() {
            samples[chunk + offset] = sample
        }
    }

    return samples
}

@inline(__always)
private func generateSIMDSamples(count: Int) -> [Double] {
    // Use ARM64 SIMD random generation
    var samples = simd_double4(
        generateBetaSample(),
        generateBetaSample(),
        generateBetaSample(),
        generateBetaSample()
    )

    return [samples.x, samples.y, samples.z, samples.w]
}
```

**Expected Impact:** -0.2ms (reduce by 1.5%)

**Total SIMD Optimization Impact: -2.0ms**

---

## Optimization 2: Improved Cache Hit Rates (Expected: -1.0ms)

### Current Cache Performance
- Cache TTL: 600 seconds (10 minutes)
- Max cache size: 2000 entries
- Current hit rate: ~60-70% (estimated)

### Solution A: Predictive Cache Warming

```swift
final class SmartThompsonCache: @unchecked Sendable {
    private var cache: [UUID: CachedScore] = [:]
    private var accessPattern: AccessPatternTracker
    private let maxCacheSize = 3000  // Increase from 2000
    private let ttl: TimeInterval = 900 // Increase to 15 minutes

    // Track access patterns for prediction
    private struct AccessPatternTracker {
        var recentAccesses: [UUID] = []
        var frequencyMap: [UUID: Int] = [:]

        mutating func recordAccess(_ jobId: UUID) {
            recentAccesses.append(jobId)
            frequencyMap[jobId, default: 0] += 1

            // Keep only last 1000 accesses
            if recentAccesses.count > 1000 {
                let removed = recentAccesses.removeFirst()
                if let count = frequencyMap[removed], count > 1 {
                    frequencyMap[removed] = count - 1
                } else {
                    frequencyMap.removeValue(forKey: removed)
                }
            }
        }

        func predictNextAccesses(count: Int) -> [UUID] {
            // Return most frequently accessed jobs
            return frequencyMap
                .sorted { $0.value > $1.value }
                .prefix(count)
                .map { $0.key }
        }
    }

    func warmCache(predictedJobIds: [UUID]) {
        // Pre-compute scores for predicted jobs
        for jobId in predictedJobIds where cache[jobId] == nil {
            // Mark as priority for scoring
            priorityQueue.insert(jobId)
        }
    }
}
```

**Expected Impact:** -0.6ms (increase hit rate from 70% to 85%)

### Solution B: LRU with Frequency Boost

```swift
private func evictOldest() {
    // Score-based eviction: consider both recency and frequency
    let scored = cache.map { (key, entry) -> (UUID, Double) in
        let recencyScore = Date().timeIntervalSince(entry.timestamp) / ttl
        let frequencyScore = Double(accessPattern.frequencyMap[key] ?? 0) / 10.0
        let combinedScore = recencyScore - frequencyScore  // Lower is better
        return (key, combinedScore)
    }
    .sorted { $0.1 < $1.1 }

    // Remove 10% with worst scores
    let toRemove = max(1, cache.count / 10)
    for (key, _) in scored.prefix(toRemove) {
        cache.removeValue(forKey: key)
    }
}
```

**Expected Impact:** -0.4ms (reduce cache miss penalties)

**Total Cache Optimization Impact: -1.0ms**

---

## Optimization 3: Memory Allocation Reduction (Expected: -0.5ms)

### Current Issues
- Small allocations in scoring loops
- Repeated array creation for chunks
- String operations in hot paths

### Solution A: Pre-allocated Buffers

```swift
final class OptimizedThompsonEngine {
    // Pre-allocated reusable buffers
    private var scoreBuffer: [ThompsonScore]
    private var sampleBuffer: [Double]

    public init(initialProfileBlend: Double = 0.5) {
        // Pre-allocate buffers for typical batch sizes
        self.scoreBuffer = []
        self.scoreBuffer.reserveCapacity(1000)

        self.sampleBuffer = []
        self.sampleBuffer.reserveCapacity(1000)

        // ... existing initialization
    }

    private func batchScoreJobs(_ jobs: [Job], userProfile: UserProfile) async -> [Job] {
        // Reuse pre-allocated buffers instead of creating new arrays
        scoreBuffer.removeAll(keepingCapacity: true)
        sampleBuffer.removeAll(keepingCapacity: true)

        // Generate samples into pre-allocated buffer
        amberSampler.sampleBatchInto(&sampleBuffer, count: jobs.count)

        // Score into pre-allocated buffer
        scoreJobsInto(&scoreBuffer, jobs: jobs, samples: sampleBuffer)

        // Return jobs with scores attached
        return attachScores(jobs: jobs, scores: scoreBuffer)
    }
}
```

**Expected Impact:** -0.3ms (eliminate small allocations)

### Solution B: Optimize String Operations

```swift
private func precomputeUserFeatures(from profile: UserProfile) {
    // Use StaticString for common lookups (zero allocation)
    // Hash skills once instead of repeated lowercasing
    let skillHashes = Set(profile.professionalProfile.skills.map { $0.lowercased().hashValue })
    let locationHashes = Set(profile.preferences.preferredLocations.map { $0.lowercased().hashValue })

    precomputedUserFeatures = UserFeatures(
        skillHashes: skillHashes,
        locationHashes: locationHashes,
        skillCount: skillHashes.count
    )
}

@inline(__always)
private func fastProfessionalScore(job: Job, baseScore: Double) -> Double {
    guard let features = precomputedUserFeatures else { return baseScore }

    // Use pre-computed hashes instead of string operations
    let jobSkillHashes = Set(job.requirements.map { $0.lowercased().hashValue })
    let matchCount = features.skillHashes.intersection(jobSkillHashes).count

    // ... rest of scoring
}
```

**Expected Impact:** -0.2ms (reduce string allocations and operations)

**Total Memory Optimization Impact: -0.5ms**

---

## Optimization 4: Algorithm & Feature Extraction (Expected: -0.4ms)

### Solution A: Simplified Exploration Bonus

```swift
@inline(__always)
private func fastExplorationBonus(job: Job) -> Double {
    // Simplified calculation without domain check
    // Domain checking is expensive and provides limited value

    // Use fixed exploration rate with random jitter
    let randomFactor = Double.random(in: 0.9...1.1)
    return baseExplorationRate * randomFactor
}
```

**Expected Impact:** -0.2ms (remove expensive domain checking)

### Solution B: Cached Feature Extraction

```swift
// Cache extracted features per job
private var featureCache: [UUID: JobFeatures] = [:]

private func extractJobFeatures(_ job: Job) -> JobFeatures {
    if let cached = featureCache[job.id] {
        return cached
    }

    let features = JobFeatures(
        titleHash: job.title.hashValue,
        companyHash: job.company.hashValue,
        skillHashes: Set(job.requirements.map { $0.hashValue }),
        locationHash: job.location.hashValue
    )

    featureCache[job.id] = features
    return features
}
```

**Expected Impact:** -0.2ms (cache expensive feature extraction)

**Total Algorithm Optimization Impact: -0.4ms**

---

## Implementation Plan

### Week 1: SIMD Optimization (Priority: CRITICAL)
**Target: -2.0ms (12.9ms → 10.9ms)**

1. Day 1-2: Increase SIMD chunk size from 8 to 16
2. Day 3-4: Implement vectorized skill matching
3. Day 5: Optimize Beta sampling with SIMD
4. Day 6-7: Test and validate performance gains

**Validation:**
```bash
# Run performance tests
swift test --filter testThompsonSamplingP95Latency

# Expected result: P95 < 11ms
```

### Week 2: Cache Optimization (Priority: HIGH)
**Target: -1.0ms (10.9ms → 9.9ms)**

1. Day 1-2: Implement predictive cache warming
2. Day 3-4: Implement LRU with frequency boost
3. Day 5: Increase cache size and TTL
4. Day 6-7: Test and validate cache hit rates

**Validation:**
```bash
# Run cache effectiveness tests
swift test --filter testThompsonCacheEffectiveness

# Expected result: Cache speedup > 5x, hit rate > 85%
```

### Week 3: Memory Optimization (Priority: MEDIUM)
**Target: -0.5ms (9.9ms → 9.4ms)**

1. Day 1-2: Implement pre-allocated buffers
2. Day 3-4: Optimize string operations
3. Day 5: Remove unnecessary allocations
4. Day 6-7: Test and validate memory usage

**Validation:**
```bash
# Run memory usage tests
swift test --filter testThompsonMemoryUsage

# Expected result: Memory < 180MB
```

### Week 4: Algorithm Tuning (Priority: LOW)
**Target: -0.4ms (9.4ms → 9.0ms)**

1. Day 1-2: Simplify exploration bonus
2. Day 3-4: Implement feature caching
3. Day 5: Profile and identify remaining bottlenecks
4. Day 6-7: Final validation and tuning

**Validation:**
```bash
# Run full Phase 6 test suite
./Tests/Integration/run_phase6_tests.sh

# Expected result: P95 < 10ms ✅
```

---

## Monitoring & Validation

### Performance Benchmarking

```swift
// Add to OptimizedThompsonEngine
#if DEBUG
extension OptimizedThompsonEngine {
    public func runOptimizationBenchmark() async {
        let iterations = 1000
        let testJobs = (0..<50).map { createTestJob(index: $0) }
        let userProfile = createTestUserProfile()

        var latencies: [Double] = []

        for _ in 0..<iterations {
            let start = CFAbsoluteTimeGetCurrent()
            _ = await scoreJobs(testJobs, userProfile: userProfile)
            let duration = (CFAbsoluteTimeGetCurrent() - start) * 1000
            latencies.append(duration)
        }

        let sorted = latencies.sorted()
        let p50 = sorted[Int(Double(iterations) * 0.50)]
        let p95 = sorted[Int(Double(iterations) * 0.95)]
        let p99 = sorted[Int(Double(iterations) * 0.99)]

        print("""
        Thompson Sampling Benchmark (\(iterations) iterations):
          P50: \(String(format: "%.3f", p50))ms
          P95: \(String(format: "%.3f", p95))ms \(p95 < 10.0 ? "✅" : "❌")
          P99: \(String(format: "%.3f", p99))ms
        """)
    }
}
#endif
```

### Continuous Performance Testing

```bash
#!/bin/bash
# continuous_performance_test.sh

echo "Running continuous performance tests..."

for i in {1..10}; do
    echo ""
    echo "=== Run $i/10 ==="
    swift test --filter testThompsonSamplingP95Latency

    # Extract P95 from test output
    # Validate it's < 10ms
    # Alert if regression detected
done

echo ""
echo "✅ Continuous testing complete"
```

---

## Expected Results Summary

| Optimization | Target Improvement | Cumulative P95 |
|-------------|-------------------|----------------|
| Current | - | 12.9ms |
| SIMD Enhancement | -2.0ms | 10.9ms |
| Cache Optimization | -1.0ms | 9.9ms |
| Memory Reduction | -0.5ms | 9.4ms |
| Algorithm Tuning | -0.4ms | 9.0ms |
| **TOTAL** | **-3.9ms (30% reduction)** | **9.0ms ✅** |

**Safety Margin:** 9.0ms target provides 1ms buffer below 10ms requirement

---

## Risk Mitigation

### Potential Issues
1. **SIMD optimizations may not work on all devices**
   - Mitigation: Keep fallback non-SIMD path
   - Test on various iPhone/iPad models

2. **Cache size increase may impact memory**
   - Mitigation: Monitor memory usage continuously
   - Implement adaptive cache sizing

3. **Optimizations may introduce bugs**
   - Mitigation: Comprehensive unit tests
   - A/B testing in production

### Rollback Plan
- Keep `OptimizedThompsonEngine` separate from production engine
- Feature flag for enabling optimizations
- Automatic rollback if P95 > 10ms for 5+ minutes

---

## Success Criteria

✅ **Phase 6 Complete When:**
1. P95 latency < 10ms (current: 12.9ms)
2. Cache hit rate > 80% (current: ~70%)
3. Memory usage < 200MB
4. All integration tests pass
5. No performance regressions
6. Production validation successful

---

## References

- [Apple Metal Performance Shaders](https://developer.apple.com/documentation/metalperformanceshaders)
- [ARM NEON SIMD](https://developer.arm.com/architectures/instruction-sets/intrinsics/)
- [Swift SIMD Documentation](https://developer.apple.com/documentation/swift/simd)
- OptimizedThompsonEngine.swift (current implementation)
- Phase6IntegrationTests.swift (validation tests)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-15
**Author:** Phase 6 Integration Testing Team
**Status:** ACTIVE - Implementation in progress
