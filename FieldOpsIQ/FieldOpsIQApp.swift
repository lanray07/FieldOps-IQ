import SwiftData
import SwiftUI

@main
struct FieldOpsIQApp: App {
    private let modelContainer: ModelContainer
    @State private var subscriptionService = SubscriptionService()

    init() {
        let schema = Schema([
            TechnicianProfile.self,
            Job.self,
            FaultReport.self,
            VoiceTranscript.self,
            SiteSurvey.self,
            EquipmentScan.self,
            WorkPack.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration("FieldOpsIQ", schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create FieldOps IQ model container: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(modelContainer)
                .environment(\.fieldOpsServices, .mock)
                .environment(subscriptionService)
                .preferredColorScheme(.dark)
                .task {
                    await subscriptionService.loadProducts()
                    await subscriptionService.refreshEntitlements()
                }
        }
    }
}
