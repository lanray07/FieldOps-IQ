import SwiftUI
import UIKit

enum FieldOpsTheme {
    static let background = Color(red: 0.015, green: 0.018, blue: 0.024)
    static let panel = Color(red: 0.055, green: 0.065, blue: 0.082)
    static let elevated = Color(red: 0.08, green: 0.095, blue: 0.12)
    static let electricBlue = Color(red: 0.0, green: 0.58, blue: 1.0)
    static let cyan = Color(red: 0.0, green: 0.82, blue: 0.88)
    static let warning = Color(red: 1.0, green: 0.68, blue: 0.18)
    static let success = Color(red: 0.14, green: 0.82, blue: 0.42)
    static let mutedText = Color.white.opacity(0.64)
    static let border = Color.white.opacity(0.11)
}

struct TechBackground<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            FieldOpsTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    FieldOpsTheme.electricBlue.opacity(0.18),
                    .clear,
                    FieldOpsTheme.cyan.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
    }
}

struct PremiumPanel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(FieldOpsTheme.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(FieldOpsTheme.border, lineWidth: 1)
            )
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(FieldOpsTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricTile: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color = FieldOpsTheme.electricBlue

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(tint)
                    Spacer()
                }
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(FieldOpsTheme.mutedText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 98)
        }
    }
}

struct QuickActionButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(FieldOpsTheme.electricBlue)
                    .frame(width: 36, height: 36)
                    .background(FieldOpsTheme.electricBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(FieldOpsTheme.elevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(FieldOpsTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct StatusPill: View {
    var text: String
    var tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(tint)
            .background(tint.opacity(0.14), in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.28), lineWidth: 1))
    }
}

struct JobCard: View {
    var job: Job

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.customer)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(job.location)
                            .font(.subheadline)
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }
                    Spacer()
                    StatusPill(text: job.status.displayName, tint: color(for: job.status))
                }

                HStack(spacing: 12) {
                    Label(job.serviceType, systemImage: "network")
                    Label(job.equipment, systemImage: "wrench.and.screwdriver")
                }
                .font(.caption)
                .foregroundStyle(FieldOpsTheme.mutedText)
                .lineLimit(1)

                if !job.notes.isEmpty {
                    Text(job.notes)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                }
            }
        }
    }

    private func color(for status: JobStatus) -> Color {
        switch status {
        case .assigned: FieldOpsTheme.electricBlue
        case .inProgress: FieldOpsTheme.cyan
        case .testing: FieldOpsTheme.warning
        case .completed: FieldOpsTheme.success
        case .followUp: .orange
        }
    }
}

struct FaultCard: View {
    var report: FaultReport

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label(report.equipmentType, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FieldOpsTheme.warning)
                    Spacer()
                    Text(report.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(FieldOpsTheme.mutedText)
                }
                Text(report.symptoms)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(report.aiAnalysis)
                    .font(.footnote)
                    .foregroundStyle(FieldOpsTheme.mutedText)
                    .lineLimit(3)
            }
        }
    }
}

struct EquipmentCard: View {
    var scan: EquipmentScan

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 10) {
                Label(scan.equipmentType, systemImage: "camera.metering.matrix")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(scan.observations)
                    .font(.footnote)
                    .foregroundStyle(FieldOpsTheme.mutedText)
                    .lineLimit(3)
                Text(scan.maintenanceRecommendation)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FieldOpsTheme.cyan)
            }
        }
    }
}

struct SurveyCard: View {
    var survey: SiteSurvey

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 10) {
                Label(survey.location, systemImage: "mappin.and.ellipse")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(survey.notes)
                    .font(.footnote)
                    .foregroundStyle(FieldOpsTheme.mutedText)
                    .lineLimit(2)
                if !survey.risks.isEmpty {
                    Label(survey.risks, systemImage: "shield.lefthalf.filled")
                        .font(.caption)
                        .foregroundStyle(FieldOpsTheme.warning)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct VoiceWaveformView: View {
    var samples: [CGFloat]
    var isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 4) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, sample in
                    Capsule()
                        .fill(isActive ? FieldOpsTheme.electricBlue : FieldOpsTheme.mutedText.opacity(0.4))
                        .frame(width: 5, height: max(8, proxy.size.height * min(sample, 1)))
                        .animation(.smooth(duration: 0.18), value: sample)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 86)
        .padding(.horizontal, 10)
        .background(FieldOpsTheme.elevated, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FieldOpsTheme.border, lineWidth: 1))
    }
}

struct IndustrialImagePlaceholder: View {
    var asset: HumanAssetPlaceholder

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    FieldOpsTheme.elevated,
                    Color(red: 0.02, green: 0.09, blue: 0.13),
                    FieldOpsTheme.electricBlue.opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 10) {
                ForEach(0..<7, id: \.self) { index in
                    Rectangle()
                        .fill(.white.opacity(index.isMultiple(of: 2) ? 0.055 : 0.025))
                        .frame(height: 1)
                }
            }
            .padding(.horizontal, 18)

            Image(systemName: asset.systemImage)
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(.white.opacity(0.28))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(asset.description)
                    .font(.caption)
                    .foregroundStyle(FieldOpsTheme.mutedText)
                    .lineLimit(2)
            }
            .padding(16)
        }
        .frame(minHeight: 170)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FieldOpsTheme.border, lineWidth: 1))
    }
}

struct DisclaimerBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(FieldOpsTheme.warning)
            Text("Informational guidance only. Technician verification required. Not engineering certification, regulatory approval, or safety certification.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.78))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FieldOpsTheme.warning.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FieldOpsTheme.warning.opacity(0.25), lineWidth: 1))
    }
}

struct UpgradeBanner: View {
    var status: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "bolt.badge.clock.fill")
                    .font(.title2)
                    .foregroundStyle(FieldOpsTheme.electricBlue)
                VStack(alignment: .leading, spacing: 3) {
                    Text(status)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Unlock unlimited jobs, voice reports, AI fault finding, and PDF exports.")
                        .font(.caption)
                        .foregroundStyle(FieldOpsTheme.mutedText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FieldOpsTheme.mutedText)
            }
            .padding(14)
            .background(FieldOpsTheme.elevated, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(FieldOpsTheme.electricBlue.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStatePanel: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        PremiumPanel {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(FieldOpsTheme.electricBlue)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FieldOpsTheme.mutedText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
}

struct AnalyticsChartCard<Content: View>: View {
    var title: String
    var subtitle: String
    var content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: title, subtitle: subtitle)
                content
                    .frame(height: 220)
            }
        }
    }
}

struct PrimaryTechButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        FieldOpsTheme.electricBlue.opacity(configuration.isPressed ? 0.72 : 1.0),
                        FieldOpsTheme.cyan.opacity(configuration.isPressed ? 0.58 : 0.86)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 8)
            )
    }
}

struct ReportPreviewView: View {
    var draft: ReportDraft

    @Environment(\.fieldOpsServices) private var services
    @State private var shareItem: ShareItem?
    @State private var errorMessage: String?
    @State private var isExporting = false

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: draft.title, subtitle: draft.category)

                    PremiumPanel {
                        Text(draft.body)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.86))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DisclaimerBanner()

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await exportPDF() }
                    } label: {
                        Label(isExporting ? "Preparing PDF" : "Export PDF", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(isExporting)
                }
                .padding()
            }
            .navigationTitle("Report Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
    }

    @MainActor
    private func exportPDF() async {
        isExporting = true
        errorMessage = nil
        defer { isExporting = false }

        do {
            let url = try services.pdfReportService.makePDF(title: draft.title, body: draft.body)
            shareItem = ShareItem(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ShareItem: Identifiable {
    var id = UUID()
    var url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
