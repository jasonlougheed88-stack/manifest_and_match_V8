import SwiftUI
import ManifestAndMatchV7Feature
import V7Core
import V7Career    // Phase 2B: Deep link routing
import V7AI        // Phase 3A: Core Data transformers
import V7Data      // Phase 3A.2: Core Data persistence
import V7Thompson  // Phase 4: O*NET Thompson Sampling cache pre-warming
import V7Services  // Week 10: Device capability detection

@main
struct ManifestAndMatchV7App: App {
    @State private var appState = AppState()
    @State private var tabCoordinator = TabCoordinator()  // Phase 2B: Tab coordination for deep links

    init() {
        // CRITICAL: Explicitly register Core Data transformers FIRST
        // This prevents "_PFFastEntityClass" crashes when creating UserTruths entities
        TransformerRegistration.registerAll()

        // Force PersistenceController initialization (also triggers static registration as backup)
        _ = PersistenceController.shared

        // Validate transformers are registered
        let missingTransformers = TransformerRegistration.validateRegistration()
        if !missingTransformers.isEmpty {
            fatalError("❌ [ManifestAndMatchV7App] Missing transformers: \(missingTransformers)")
        }

        // Week 10: Detect device capability for iOS 26 Foundation Models
        // Determines PRIMARY (swipe-based learning) vs FALLBACK (question-based) system
        let detector = FoundationModelsDetector.shared
        if detector.shouldEnableSwipeBasedLearning {
            print("✅ PRIMARY: Swipe-based behavioral learning enabled (\(detector.deviceTier.rawValue) device)")
            print("   \(detector.capabilityDescription)")
        } else {
            print("⚠️ FALLBACK: Question-based system enabled (\(detector.deviceTier.rawValue) device)")
            print("   \(detector.capabilityDescription)")
        }

        // Phase 4: Pre-warm Thompson Sampling cache (eliminates 50-80ms first-call latency)
        // Loads EnhancedSkillsMatcher from bundle and FastLookupTable
        // asynchronously during app launch to eliminate cold-start penalty
        Task.detached(priority: .high) {
            // Pre-warm EnhancedSkillsMatcher (40-50ms saved)
            _ = try? await ThompsonSamplingEngine().getEnhancedSkillsMatcher()

            // Pre-warm FastLookupTable lookup table (20-30ms saved)
            // This initializes the 490x490 precomputed sample table
            _ = FastLookupTable.shared

            await MainActor.run {
                print("✅ [ManifestAndMatchV7App] Thompson Sampling cache pre-warmed")
            }
        }

        print("✅ [ManifestAndMatchV7App] All systems initialized, transformers validated")
    }

    var body: some Scene {
        WindowGroup {
            // Use MainTabView as the root navigation structure
            // This implements the sacred 4-tab architecture
            MainTabView()
                .environment(appState)
                .tabCoordinator(tabCoordinator)  // Phase 2B: Inject coordinator
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)  // Phase 3A.2: Core Data access
                .onOpenURL { url in
                    // Phase 2B: Handle deep links (manifestandmatch://*)
                    DeepLinkRouter.shared.routeAndNavigate(
                        url.absoluteString,
                        coordinator: tabCoordinator
                    )
                }
        }
    }
}
