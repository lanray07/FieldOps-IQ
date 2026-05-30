import Observation
import SwiftData
import SwiftUI

struct AppRootView: View {
    @Query(sort: \TechnicianProfile.createdAt, order: .reverse) private var profiles: [TechnicianProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                AppShellView(profile: profile)
            } else {
                OnboardingView()
            }
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case jobs
    case tools
    case knowledge
    case analytics
    case settings

    var id: String { rawValue }

    @ViewBuilder
    func makeContentView(profile: TechnicianProfile) -> some View {
        switch self {
        case .dashboard:
            DashboardView(profile: profile)
        case .jobs:
            JobManagementView()
        case .tools:
            ToolHubView()
        case .knowledge:
            KnowledgeBaseView()
        case .analytics:
            AnalyticsDashboardView()
        case .settings:
            SettingsView(profile: profile)
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .dashboard: Label("Dashboard", systemImage: "gauge.with.dots.needle.bottom.50percent")
        case .jobs: Label("Jobs", systemImage: "briefcase.fill")
        case .tools: Label("Tools", systemImage: "waveform.path.ecg")
        case .knowledge: Label("Guides", systemImage: "books.vertical.fill")
        case .analytics: Label("Analytics", systemImage: "chart.xyaxis.line")
        case .settings: Label("Settings", systemImage: "gearshape.fill")
        }
    }
}

enum Route: Hashable {
    case jobs
    case faultFinder
    case voiceNotes
    case siteSurvey
    case equipmentScanner
    case checklistEngine
    case workPacks
    case reports
    case paywall
    case teamManagement
    case widgets
    case watch
}

enum SheetDestination: Identifiable, Hashable {
    case newJob
    case paywall
    case reportPreview(title: String, body: String, category: String)

    var id: String {
        switch self {
        case .newJob: "newJob"
        case .paywall: "paywall"
        case .reportPreview(let title, _, let category): "report-\(title)-\(category)"
        }
    }
}

@MainActor
@Observable
final class RouterPath {
    var path: [Route] = []
    var presentedSheet: SheetDestination?

    func navigate(to route: Route) {
        path.append(route)
    }
}

@MainActor
@Observable
final class TabRouter {
    private var routers: [AppTab: RouterPath] = [:]

    func router(for tab: AppTab) -> RouterPath {
        if let router = routers[tab] {
            return router
        }
        let router = RouterPath()
        routers[tab] = router
        return router
    }

    func binding(for tab: AppTab) -> Binding<[Route]> {
        let router = router(for: tab)
        return Binding(
            get: { router.path },
            set: { router.path = $0 }
        )
    }
}

struct AppShellView: View {
    var profile: TechnicianProfile

    @State private var selectedTab: AppTab = .dashboard
    @State private var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                let router = tabRouter.router(for: tab)
                NavigationStack(path: tabRouter.binding(for: tab)) {
                    tab.makeContentView(profile: profile)
                        .withAppRouter()
                }
                .environment(router)
                .withSheetDestinations(sheet: Binding(
                    get: { router.presentedSheet },
                    set: { router.presentedSheet = $0 }
                ))
                .tabItem { tab.label }
                .tag(tab)
            }
        }
        .tint(FieldOpsTheme.electricBlue)
    }
}

extension View {
    func withAppRouter() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .jobs:
                JobManagementView()
            case .faultFinder:
                FaultFinderView()
            case .voiceNotes:
                VoiceReportView()
            case .siteSurvey:
                SiteSurveyBuilderView()
            case .equipmentScanner:
                EquipmentScannerView()
            case .checklistEngine:
                ChecklistEngineView()
            case .workPacks:
                WorkPackGeneratorView()
            case .reports:
                ReportsView()
            case .paywall:
                PaywallView()
            case .teamManagement:
                TeamManagementPlaceholderView()
            case .widgets:
                WidgetsPlaceholderView()
            case .watch:
                WatchPlaceholderView()
            }
        }
    }

    func withSheetDestinations(sheet: Binding<SheetDestination?>) -> some View {
        self.sheet(item: sheet) { destination in
            NavigationStack {
                switch destination {
                case .newJob:
                    NewJobView()
                case .paywall:
                    PaywallView()
                case .reportPreview(let title, let body, let category):
                    ReportPreviewView(draft: ReportDraft(title: title, body: body, category: category))
                }
            }
        }
    }
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var role: TechnicianRole = .telecomEngineer
    @State private var experience: ExperienceLevel = .experienced
    @State private var specialization: Specialization = .ftth

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    IndustrialImagePlaceholder(asset: HumanAssetsCatalog.dashboardHero)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("FieldOps IQ")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                        Text("The AI copilot for telecom field engineers.")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 18) {
                            SectionHeader(title: "Technician Profile", subtitle: "Configure your operational dashboard.")

                            Picker("Role", selection: $role) {
                                ForEach(TechnicianRole.allCases) { role in
                                    Text(role.displayName).tag(role)
                                }
                            }

                            Picker("Experience", selection: $experience) {
                                ForEach(ExperienceLevel.allCases) { level in
                                    Text(level.displayName).tag(level)
                                }
                            }

                            Picker("Specialization", selection: $specialization) {
                                ForEach(Specialization.allCases) { specialization in
                                    Text(specialization.displayName).tag(specialization)
                                }
                            }
                        }
                    }

                    DisclaimerBanner()

                    Button {
                        completeOnboarding()
                    } label: {
                        Label("Build Dashboard", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                }
                .padding()
            }
        }
    }

    private func completeOnboarding() {
        modelContext.insert(TechnicianProfile(role: role, experienceLevel: experience, specialization: specialization))
        modelContext.insert(SubscriptionState(plan: .free, isActive: true))
    }
}

struct DashboardView: View {
    var profile: TechnicianProfile

    @Environment(RouterPath.self) private var router
    @Environment(SubscriptionService.self) private var subscription
    @Query(sort: \Job.createdAt, order: .reverse) private var jobs: [Job]
    @Query(sort: \FaultReport.createdAt, order: .reverse) private var faults: [FaultReport]
    @Query(sort: \VoiceTranscript.createdAt, order: .reverse) private var transcripts: [VoiceTranscript]
    @Query(sort: \SiteSurvey.createdAt, order: .reverse) private var surveys: [SiteSurvey]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    UpgradeBanner(status: subscription.statusText) {
                        router.presentedSheet = .paywall
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        MetricTile(title: "Active Jobs", value: "\(activeJobs.count)", systemImage: "briefcase.fill")
                        MetricTile(title: "Unresolved Faults", value: "\(faults.count)", systemImage: "exclamationmark.triangle.fill", tint: FieldOpsTheme.warning)
                        MetricTile(title: "Pending Reports", value: "\(pendingReports)", systemImage: "doc.text.fill", tint: FieldOpsTheme.cyan)
                        MetricTile(title: "Recent Inspections", value: "\(surveys.count)", systemImage: "checklist.checked", tint: FieldOpsTheme.success)
                    }

                    SectionHeader(title: "Quick Actions", subtitle: "Field workflows built for repeat use.")
                    LazyVGrid(columns: columns, spacing: 12) {
                        QuickActionButton(title: "New Job", systemImage: "plus.circle.fill") {
                            router.presentedSheet = .newJob
                        }
                        QuickActionButton(title: "Fault Finder", systemImage: "waveform.path.ecg") {
                            router.navigate(to: .faultFinder)
                        }
                        QuickActionButton(title: "Voice Notes", systemImage: "mic.fill") {
                            router.navigate(to: .voiceNotes)
                        }
                        QuickActionButton(title: "Site Survey", systemImage: "map.fill") {
                            router.navigate(to: .siteSurvey)
                        }
                        QuickActionButton(title: "Equipment Scanner", systemImage: "camera.viewfinder") {
                            router.navigate(to: .equipmentScanner)
                        }
                        QuickActionButton(title: "Generate Report", systemImage: "doc.richtext.fill") {
                            router.navigate(to: .reports)
                        }
                    }

                    SectionHeader(title: "AI Recommendations", subtitle: "Mock AI is enabled by default.")
                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Prioritize unresolved optical faults before new installations.", systemImage: "bolt.horizontal.circle.fill")
                            Label("Capture voice notes during customer handover to reduce paperwork.", systemImage: "mic.badge.plus")
                            Label("Attach equipment photos to every cabinet or ONT visit.", systemImage: "camera.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.84))
                    }

                    SectionHeader(title: "Signal Alerts", subtitle: "Placeholder architecture for future telemetry.")
                    PremiumPanel {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundStyle(FieldOpsTheme.electricBlue)
                            Text("No live signal feed connected. Backend integration can map alerts into this dashboard.")
                                .font(.subheadline)
                                .foregroundStyle(FieldOpsTheme.mutedText)
                        }
                    }

                    if let job = jobs.first {
                        SectionHeader(title: "Latest Job", subtitle: "Continue where you left off.")
                        NavigationLink {
                            JobDetailView(job: job)
                        } label: {
                            JobCard(job: job)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var header: some View {
        PremiumPanel {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "person.crop.rectangle.badge.gearshape")
                    .font(.largeTitle)
                    .foregroundStyle(FieldOpsTheme.electricBlue)
                    .frame(width: 58, height: 58)
                    .background(FieldOpsTheme.electricBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.role.displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(profile.experienceLevel.displayName) - \(profile.specialization.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(FieldOpsTheme.mutedText)
                    Text("Premium field operations dashboard")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(FieldOpsTheme.cyan)
                }
                Spacer()
            }
        }
    }

    private var activeJobs: [Job] {
        jobs.filter { $0.status != .completed }
    }

    private var pendingReports: Int {
        max(0, activeJobs.count + faults.count - transcripts.count)
    }
}

struct ToolHubView: View {
    @Environment(RouterPath.self) private var router
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "Field Tools", subtitle: "Troubleshooting, evidence capture, reporting, and planning.")

                    LazyVGrid(columns: columns, spacing: 12) {
                        QuickActionButton(title: "AI Fault Finder", systemImage: "waveform.path.ecg") { router.navigate(to: .faultFinder) }
                        QuickActionButton(title: "Voice-to-Report", systemImage: "mic.and.signal.meter.fill") { router.navigate(to: .voiceNotes) }
                        QuickActionButton(title: "Equipment Scanner", systemImage: "camera.metering.matrix") { router.navigate(to: .equipmentScanner) }
                        QuickActionButton(title: "Site Survey Builder", systemImage: "map.circle.fill") { router.navigate(to: .siteSurvey) }
                        QuickActionButton(title: "Checklist Engine", systemImage: "checklist.checked") { router.navigate(to: .checklistEngine) }
                        QuickActionButton(title: "Work Pack Generator", systemImage: "shippingbox.and.arrow.backward.fill") { router.navigate(to: .workPacks) }
                        QuickActionButton(title: "PDF Reports", systemImage: "doc.richtext.fill") { router.navigate(to: .reports) }
                        QuickActionButton(title: "Team Placeholder", systemImage: "person.3.fill") { router.navigate(to: .teamManagement) }
                        QuickActionButton(title: "Widgets Placeholder", systemImage: "square.grid.2x2.fill") { router.navigate(to: .widgets) }
                        QuickActionButton(title: "Watch Placeholder", systemImage: "applewatch") { router.navigate(to: .watch) }
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Tools")
        }
    }
}
