import Foundation

struct WatchCompanionCapability: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
}

enum FieldOpsWatchArchitecture {
    static let capabilities = [
        WatchCompanionCapability(title: "Job Alerts", detail: "Mirror high-priority assignments and follow-up reminders."),
        WatchCompanionCapability(title: "Navigation", detail: "Expose job location handoff and travel state placeholders."),
        WatchCompanionCapability(title: "Quick Notes", detail: "Dictate short field notes and sync into VoiceTranscript."),
        WatchCompanionCapability(title: "Fault Reminders", detail: "Surface escalation and retest reminders during active jobs.")
    ]
}
