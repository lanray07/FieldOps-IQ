import Charts
import Foundation
import SwiftData
import SwiftUI

private enum FieldOpsLegalLinks {
    static let privacyPolicy = URL(string: "https://github.com/lanray07/FieldOps-IQ/blob/main/PRIVACY_POLICY.md")!
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}

struct AnalyticsDashboardView: View {
    @Query(sort: \Job.createdAt, order: .reverse) private var jobs: [Job]
    @Query(sort: \FaultReport.createdAt, order: .reverse) private var faults: [FaultReport]
    @Query(sort: \VoiceTranscript.createdAt, order: .reverse) private var transcripts: [VoiceTranscript]
    @Query(sort: \EquipmentScan.createdAt, order: .reverse) private var scans: [EquipmentScan]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "Analytics Dashboard", subtitle: "Operational intelligence for field productivity and fault trends.")

                    LazyVGrid(columns: columns, spacing: 12) {
                        MetricTile(title: "Completed Jobs", value: "\(completedJobs)", systemImage: "checkmark.seal.fill", tint: FieldOpsTheme.success)
                        MetricTile(title: "First-time Fix", value: "\(firstTimeFixRate)%", systemImage: "target", tint: FieldOpsTheme.cyan)
                        MetricTile(title: "Report Volume", value: "\(transcripts.count)", systemImage: "doc.text.fill")
                        MetricTile(title: "Equipment Trends", value: "\(scans.count)", systemImage: "camera.metering.matrix", tint: FieldOpsTheme.warning)
                    }

                    AnalyticsChartCard(title: "Job Status", subtitle: "Current work distribution") {
                        Chart(statusPoints) { point in
                            BarMark(
                                x: .value("Status", point.label),
                                y: .value("Jobs", point.value)
                            )
                            .foregroundStyle(FieldOpsTheme.electricBlue)
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel()
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine().foregroundStyle(.white.opacity(0.08))
                                AxisValueLabel().foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                    }

                    AnalyticsChartCard(title: "Common Faults", subtitle: "Equipment categories from saved fault analysis") {
                        Chart(faultPoints) { point in
                            BarMark(
                                x: .value("Count", point.value),
                                y: .value("Equipment", point.label)
                            )
                            .foregroundStyle(FieldOpsTheme.warning)
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisGridLine().foregroundStyle(.white.opacity(0.08))
                                AxisValueLabel().foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisValueLabel().foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Technician Productivity", subtitle: "Placeholder KPIs ready for team backend data.")
                            Label("Average report turnaround placeholder", systemImage: "timer")
                            Label("Repeat visit trend placeholder", systemImage: "arrow.triangle.2.circlepath")
                            Label("Supervisor review queue placeholder", systemImage: "person.badge.shield.checkmark")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }

    private var completedJobs: Int {
        jobs.filter { $0.status == .completed }.count
    }

    private var firstTimeFixRate: Int {
        guard !jobs.isEmpty else { return 0 }
        let followUps = jobs.filter { $0.status == .followUp }.count
        return max(0, Int((Double(jobs.count - followUps) / Double(jobs.count)) * 100))
    }

    private var statusPoints: [AnalyticsDataPoint] {
        JobStatus.allCases.map { status in
            AnalyticsDataPoint(label: status.displayName, value: Double(jobs.filter { $0.status == status }.count))
        }
    }

    private var faultPoints: [AnalyticsDataPoint] {
        let groups = Dictionary(grouping: faults, by: \.equipmentType)
        let points = groups.map { key, values in
            AnalyticsDataPoint(label: key.isEmpty ? "Unspecified" : key, value: Double(values.count))
        }
        return points.isEmpty ? [AnalyticsDataPoint(label: "No data", value: 0)] : points.sorted { $0.value > $1.value }
    }
}

struct ReportsView: View {
    @Query(sort: \Job.createdAt, order: .reverse) private var jobs: [Job]
    @Query(sort: \FaultReport.createdAt, order: .reverse) private var faults: [FaultReport]
    @Query(sort: \SiteSurvey.createdAt, order: .reverse) private var surveys: [SiteSurvey]
    @Query(sort: \WorkPack.createdAt, order: .reverse) private var workPacks: [WorkPack]
    @State private var selectedDraft: ReportDraft?

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "PDF Reports", subtitle: "Generate engineer, customer, survey, completion, and maintenance documents.")

                    reportButton(title: "Engineer Report", icon: "person.text.rectangle.fill") {
                        selectedDraft = ReportDraft(title: "Engineer Report", body: engineerReportBody, category: "Engineer Report")
                    }

                    reportButton(title: "Customer Report", icon: "person.crop.square.filled.and.at.rectangle.fill") {
                        selectedDraft = ReportDraft(title: "Customer Report", body: customerReportBody, category: "Customer Report")
                    }

                    reportButton(title: "Site Survey", icon: "map.fill") {
                        selectedDraft = ReportDraft(title: "Site Survey", body: surveyReportBody, category: "Site Survey")
                    }

                    reportButton(title: "Completion Certificate Placeholder", icon: "rosette") {
                        selectedDraft = ReportDraft(title: "Completion Placeholder", body: completionPlaceholderBody, category: "Completion Placeholder")
                    }

                    reportButton(title: "Maintenance Report", icon: "wrench.and.screwdriver.fill") {
                        selectedDraft = ReportDraft(title: "Maintenance Report", body: maintenanceReportBody, category: "Maintenance Report")
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Reports")
        }
        .sheet(item: $selectedDraft) { draft in
            NavigationStack {
                ReportPreviewView(draft: draft)
            }
        }
    }

    private func reportButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PremiumPanel {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(FieldOpsTheme.electricBlue)
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(FieldOpsTheme.mutedText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var latestJob: Job? { jobs.first }
    private var latestSurvey: SiteSurvey? { surveys.first }
    private var latestFault: FaultReport? { faults.first }

    private var engineerReportBody: String {
        guard let job = latestJob else {
            return "No job data available. Create a job before generating a full engineer report."
        }

        return """
        Job: \(job.serviceType)
        Customer: \(job.customer)
        Location: \(job.location)
        Equipment: \(job.equipment)
        Status: \(job.status.displayName)

        Engineer Notes:
        \(job.notes.isEmpty ? "No notes recorded." : job.notes)

        Latest Fault Context:
        \(latestFault?.aiAnalysis ?? "No fault analysis recorded.")
        """
    }

    private var customerReportBody: String {
        guard let job = latestJob else {
            return "No job data available."
        }

        return """
        Customer: \(job.customer)
        Location: \(job.location)

        Work Summary:
        Field work was recorded for \(job.serviceType). Current job state is \(job.status.displayName).

        Customer Notes:
        \(job.notes.isEmpty ? "Technician notes have not been added yet." : job.notes)

        This report is informational and requires technician verification.
        """
    }

    private var surveyReportBody: String {
        guard let survey = latestSurvey else {
            return "No site survey data available. Use Site Survey Builder to capture readiness and risks."
        }

        return """
        Location: \(survey.location)
        Notes: \(survey.notes)
        Risks: \(survey.risks)

        Generated Report:
        \(survey.generatedReport)
        """
    }

    private var completionPlaceholderBody: String {
        """
        Completion certificate placeholder.

        FieldOps IQ does not certify installations, engineering outcomes, safety compliance, or regulatory approval.
        This document can be adapted into a customer completion summary after technician verification.
        """
    }

    private var maintenanceReportBody: String {
        """
        Latest maintenance context:
        \(workPacks.first?.generatedContent ?? "No maintenance work pack has been generated.")

        Fault observations:
        \(latestFault?.aiAnalysis ?? "No saved fault report.")
        """
    }
}

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscription
    @Environment(\.dismiss) private var dismiss

    private let paidPlans: [SubscriptionPlan] = [.professionalMonthly, .professionalYearly, .contractorProMonthly]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FieldOps IQ Pro")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Upgrade the AI copilot for telecom field engineers.")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Free plan")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                            ForEach(SubscriptionPlan.free.features, id: \.self) { feature in
                                Label(feature, systemImage: "minus.circle")
                                    .font(.footnote)
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                    }

                    ForEach(paidPlans) { plan in
                        planCard(plan)
                    }

                    subscriptionLegalPanel

                    if let errorMessage = subscription.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(FieldOpsTheme.warning)
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Subscription")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(plan.price)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(FieldOpsTheme.cyan)
                        Text(plan.subscriptionLength + " auto-renewable subscription")
                            .font(.caption)
                            .foregroundStyle(FieldOpsTheme.mutedText)
                        Text("Price: \(plan.pricePerPeriod)")
                            .font(.caption)
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }
                    Spacer()
                    if subscription.activePlan == plan {
                        StatusPill(text: "Active", tint: FieldOpsTheme.success)
                    }
                }

                ForEach(plan.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.82))
                }

                Button {
                    Task { await subscription.purchase(plan) }
                } label: {
                    Label(subscription.activePlan == plan ? "Current Plan" : "Upgrade", systemImage: "bolt.fill")
                }
                .buttonStyle(PrimaryTechButtonStyle())
                .disabled(subscription.activePlan == plan || subscription.isLoading)
            }
        }
    }

    private var subscriptionLegalPanel: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Subscription Terms", subtitle: "Required plan, renewal, privacy, and EULA information.")
                Text("Plans are auto-renewable subscriptions. Payment is charged to your Apple ID. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Apple ID subscriptions.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.82))

                VStack(alignment: .leading, spacing: 10) {
                    Link(destination: FieldOpsLegalLinks.termsOfUse) {
                        Label("Terms of Use (EULA)", systemImage: "doc.text.fill")
                    }
                    Link(destination: FieldOpsLegalLinks.privacyPolicy) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(FieldOpsTheme.cyan)
            }
        }
    }
}

struct SettingsView: View {
    var profile: TechnicianProfile

    @Environment(RouterPath.self) private var router
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscription
    @Query private var jobs: [Job]
    @Query private var faults: [FaultReport]
    @Query private var transcripts: [VoiceTranscript]
    @Query private var surveys: [SiteSurvey]
    @Query private var scans: [EquipmentScan]
    @Query private var workPacks: [WorkPack]
    @Query private var subscriptionStates: [SubscriptionState]
    @State private var notificationStatus = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Settings", subtitle: "\(profile.role.displayName) - \(profile.specialization.displayName)")

                    settingsRow(title: "Subscription", detail: subscription.statusText, icon: "creditcard.fill") {
                        router.navigate(to: .paywall)
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Voice Settings", subtitle: "Speech-to-text and audio capture.")
                            Label("Locale: en_GB", systemImage: "globe.europe.africa.fill")
                            Label("Live transcription enabled when permission is granted", systemImage: "mic.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Offline Downloads", subtitle: "Knowledge base is bundled for offline use.")
                            Label("SOPs and troubleshooting guides available offline", systemImage: "wifi.slash")
                            Label("Fiber diagrams placeholder ready for asset bundles", systemImage: "point.3.connected.trianglepath.dotted")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Notifications", subtitle: "Local reminders and job alerts.")
                            Button {
                                Task {
                                    let granted = await services.notificationService.requestAuthorization()
                                    notificationStatus = granted ? "Notifications enabled" : "Notifications not enabled"
                                }
                            } label: {
                                Label("Request Permission", systemImage: "bell.badge.fill")
                            }
                            if !notificationStatus.isEmpty {
                                Text(notificationStatus)
                                    .font(.caption)
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                    }

                    settingsRow(title: "Export Settings", detail: "Native PDF and share sheet", icon: "square.and.arrow.up") {
                        router.navigate(to: .reports)
                    }

                    legalPanel

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(.red.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.red)
                }
                .padding()
            }
            .navigationTitle("Settings")
        }
        .confirmationDialog("Delete all FieldOps IQ data?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete All Data", role: .destructive) { deleteAllData() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func settingsRow(title: String, detail: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PremiumPanel {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(FieldOpsTheme.electricBlue)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(FieldOpsTheme.mutedText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var legalPanel: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Legal", subtitle: "Privacy, terms, and engineering disclaimer.")
                Link(destination: FieldOpsLegalLinks.privacyPolicy) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                Link(destination: FieldOpsLegalLinks.termsOfUse) {
                    Label("Terms of Use (EULA)", systemImage: "doc.text.fill")
                }
                Text("Engineering Disclaimer: FieldOps IQ does not certify installations, guarantee engineering outcomes, replace professional judgment, replace safety procedures, or provide regulatory approval.")
            }
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.82))
        }
    }

    private func deleteAllData() {
        for job in jobs { modelContext.delete(job) }
        for fault in faults { modelContext.delete(fault) }
        for transcript in transcripts { modelContext.delete(transcript) }
        for survey in surveys { modelContext.delete(survey) }
        for scan in scans { modelContext.delete(scan) }
        for workPack in workPacks { modelContext.delete(workPack) }
        for subscriptionState in subscriptionStates { modelContext.delete(subscriptionState) }
        subscription.activePlan = .free
    }
}

private struct PlaceholderFeature: Identifiable {
    var id = UUID()
    var title: String
    var detail: String
    var systemImage: String
}

struct TeamManagementPlaceholderView: View {
    private let features = [
        PlaceholderFeature(title: "Technician Assignments", detail: "Assign jobs to engineers and monitor current state.", systemImage: "person.line.dotted.person.fill"),
        PlaceholderFeature(title: "Supervisor Review", detail: "Review reports and escalations before customer handover.", systemImage: "person.badge.shield.checkmark.fill"),
        PlaceholderFeature(title: "Team Dashboards", detail: "Aggregate jobs, reports, faults, and productivity.", systemImage: "rectangle.3.group.fill"),
        PlaceholderFeature(title: "Workforce Analytics", detail: "Trend first-time fix, repeat visits, and report volume.", systemImage: "chart.line.uptrend.xyaxis")
    ]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Team Management", subtitle: "Architecture placeholder for contractor and supervisor workflows.")
                    ForEach(features) { item in
                        PremiumPanel {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(item.detail)
                                        .font(.footnote)
                                        .foregroundStyle(FieldOpsTheme.mutedText)
                                }
                            } icon: {
                                Image(systemName: item.systemImage)
                                    .foregroundStyle(FieldOpsTheme.electricBlue)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Team")
        }
    }
}

struct WidgetsPlaceholderView: View {
    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Widgets Placeholder", subtitle: "WidgetKit extension plan and data sources.")
                    ForEach(FieldOpsWidgetArchitecture.widgets) { widget in
                        PremiumPanel {
                            HStack(spacing: 12) {
                                Image(systemName: widget.systemImage)
                                    .font(.title2)
                                    .foregroundStyle(FieldOpsTheme.electricBlue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(widget.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(widget.dataSource)
                                        .font(.footnote)
                                        .foregroundStyle(FieldOpsTheme.mutedText)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Widgets")
        }
    }
}

struct WatchPlaceholderView: View {
    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Apple Watch Placeholder", subtitle: "Companion architecture for quick field interactions.")
                    ForEach(FieldOpsWatchArchitecture.capabilities) { capability in
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(capability.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(capability.detail)
                                    .font(.footnote)
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Watch")
        }
    }
}
