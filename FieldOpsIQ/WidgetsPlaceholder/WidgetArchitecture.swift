import Foundation

struct WidgetPlaceholderConfiguration: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var systemImage: String
    var dataSource: String
}

enum FieldOpsWidgetArchitecture {
    static let widgets = [
        WidgetPlaceholderConfiguration(title: "Active Jobs", systemImage: "briefcase.fill", dataSource: "SwiftData Job query filtered by active status"),
        WidgetPlaceholderConfiguration(title: "Today's Schedule", systemImage: "calendar", dataSource: "Calendar-aware job timeline placeholder"),
        WidgetPlaceholderConfiguration(title: "Unresolved Faults", systemImage: "exclamationmark.triangle.fill", dataSource: "FaultReport query with unresolved flag placeholder"),
        WidgetPlaceholderConfiguration(title: "Quick Report", systemImage: "square.and.pencil", dataSource: "AppIntent shortcut to voice report capture")
    ]
}
