import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct FaultFinderView: View {
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FaultFinderViewModel()

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "AI Fault Finder", subtitle: "Structured telecom troubleshooting with cautious guidance.")

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            TextField("Equipment type", text: $viewModel.equipmentType)
                            TextField("Fault symptoms", text: $viewModel.symptoms, axis: .vertical)
                                .lineLimit(3...6)
                            TextField("Error indicators", text: $viewModel.errorIndicators, axis: .vertical)
                                .lineLimit(2...5)
                        }
                    }

                    Button {
                        Task { await analyze() }
                    } label: {
                        Label(viewModel.isLoading ? "Analyzing" : "Generate Fault Guidance", systemImage: "sparkles")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(!viewModel.canAnalyze || viewModel.isLoading)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    if let response = viewModel.response {
                        resultView(response)
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Fault Finder")
        }
    }

    private func analyze() async {
        await viewModel.analyze(with: services.faultAnalysisService)
        guard let response = viewModel.response else { return }
        modelContext.insert(FaultReport(
            symptoms: viewModel.symptoms,
            equipmentType: viewModel.equipmentType,
            aiAnalysis: response.analysis,
            recommendations: response.recommendations
        ))
    }

    private func resultView(_ response: AIResponse) -> some View {
        PremiumPanel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Possible Causes", subtitle: response.summary)
                Text(response.analysis)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(response.recommendations, id: \.self) { recommendation in
                        Label(recommendation, systemImage: "checkmark.circle")
                            .font(.footnote)
                            .foregroundStyle(FieldOpsTheme.mutedText)
                    }
                }
            }
        }
    }
}

struct VoiceReportView: View {
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @State private var speech = SpeechRecognitionService()
    @State private var recorder = VoiceRecordingService()
    @State private var waveform = WaveformAnimationManager()
    @State private var viewModel = VoiceReportViewModel()

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Voice-to-Report", subtitle: "Dictate field notes and turn them into structured reports.")

                    VoiceWaveformView(samples: waveform.samples, isActive: speech.isRecording || recorder.isRecording)

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Report type", selection: $viewModel.category) {
                                Text("Engineer Report").tag("Engineer Report")
                                Text("Customer Notes").tag("Customer Notes")
                                Text("Maintenance Record").tag("Maintenance Record")
                                Text("Completion Notes").tag("Completion Notes")
                            }
                            .pickerStyle(.segmented)

                            TextEditor(text: $viewModel.transcript)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 180)
                                .foregroundStyle(.white)
                                .overlay(alignment: .topLeading) {
                                    if viewModel.transcript.isEmpty {
                                        Text("Live transcript and editable notes appear here.")
                                            .font(.callout)
                                            .foregroundStyle(FieldOpsTheme.mutedText)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                }
                        }
                    }

                    HStack(spacing: 12) {
                        Button {
                            toggleSpeech()
                        } label: {
                            Label(speech.isRecording ? "Stop" : "Dictate", systemImage: speech.isRecording ? "stop.fill" : "mic.fill")
                        }
                        .buttonStyle(PrimaryTechButtonStyle())

                        Button {
                            toggleAudioRecording()
                        } label: {
                            Image(systemName: recorder.isRecording ? "record.circle.fill" : "record.circle")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(FieldOpsTheme.elevated, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(recorder.isRecording ? .red : FieldOpsTheme.electricBlue)
                        .accessibilityLabel(recorder.isRecording ? "Stop audio recording" : "Start audio recording")
                    }

                    Button {
                        Task { await summarize() }
                    } label: {
                        Label(viewModel.isSummarizing ? "Summarizing" : "AI Summarize", systemImage: "text.badge.checkmark")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(!viewModel.canSummarize || viewModel.isSummarizing)

                    if let response = viewModel.response {
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "AI Summary", subtitle: response.summary)
                                Text(response.report)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                        }
                    }

                    if let message = speech.errorMessage ?? recorder.errorMessage ?? viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Voice")
        }
        .task {
            speech.requestAuthorization()
        }
        .onChange(of: speech.transcript) { _, newTranscript in
            if speech.isRecording {
                viewModel.transcript = newTranscript
            }
        }
    }

    private func toggleSpeech() {
        if speech.isRecording {
            speech.stopTranscribing()
            waveform.stop()
        } else {
            do {
                try speech.startTranscribing()
                waveform.start()
            } catch {
                speech.errorMessage = error.localizedDescription
                waveform.stop()
            }
        }
    }

    private func toggleAudioRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
            waveform.stop()
        } else {
            recorder.startRecording()
            waveform.start()
        }
    }

    private func summarize() async {
        await viewModel.summarize(with: services.voiceReportService)
        guard let response = viewModel.response else { return }
        modelContext.insert(VoiceTranscript(
            transcript: viewModel.transcript,
            summary: response.summary,
            category: viewModel.category
        ))
    }
}

struct EquipmentScannerView: View {
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EquipmentScanViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Equipment Scanner", subtitle: "Photo-assisted equipment observations with verification warnings.")

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Equipment", selection: $viewModel.declaredType) {
                                ForEach(["ONT", "Router", "Cabinet", "Patch Panel", "Switch", "Fiber Equipment"], id: \.self) { value in
                                    Text(value).tag(value)
                                }
                            }

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Label("Upload Equipment Photo", systemImage: "camera.fill")
                            }

                            if let data = viewModel.imageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                IndustrialImagePlaceholder(asset: HumanAssetsCatalog.equipment.first ?? HumanAssetsCatalog.dashboardHero)
                            }

                            TextField("Photo notes", text: $viewModel.notes, axis: .vertical)
                                .lineLimit(2...5)
                        }
                    }

                    Button {
                        Task { await analyze() }
                    } label: {
                        Label(viewModel.isAnalyzing ? "Scanning" : "Analyze Equipment", systemImage: "viewfinder.circle.fill")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(viewModel.isAnalyzing)

                    if let response = viewModel.response {
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Equipment Identification", subtitle: response.summary)
                                Text(response.analysis)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.84))
                                ForEach(response.recommendations, id: \.self) { recommendation in
                                    Label(recommendation, systemImage: "wrench.adjustable")
                                        .font(.footnote)
                                        .foregroundStyle(FieldOpsTheme.mutedText)
                                }
                            }
                        }
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Scanner")
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.imageData = data
                    }
                }
            }
        }
    }

    private func analyze() async {
        await viewModel.analyze(with: services.equipmentRecognitionService)
        guard let response = viewModel.response else { return }
        modelContext.insert(EquipmentScan(
            equipmentType: viewModel.declaredType,
            observations: response.analysis,
            maintenanceRecommendation: response.recommendations.first ?? "Technician verification required."
        ))
    }
}

struct SiteSurveyBuilderView: View {
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SiteSurveyViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Site Survey Builder", subtitle: "Capture readiness, risks, materials, notes, and photos.")

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            TextField("Location", text: $viewModel.location)
                            TextField("Survey notes", text: $viewModel.notes, axis: .vertical)
                                .lineLimit(3...7)
                            TextField("Risks", text: $viewModel.risks, axis: .vertical)
                                .lineLimit(2...5)
                            TextField("Equipment inventory", text: $viewModel.inventory, axis: .vertical)
                                .lineLimit(2...5)

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Label("Add Survey Photo", systemImage: "photo.badge.plus")
                            }
                            Text("\(viewModel.photoCount) survey photo placeholder\(viewModel.photoCount == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(FieldOpsTheme.mutedText)
                        }
                    }

                    Button {
                        Task { await generate() }
                    } label: {
                        Label(viewModel.isGenerating ? "Generating" : "Generate Survey Report", systemImage: "map.fill")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(!viewModel.canGenerate || viewModel.isGenerating)

                    if let response = viewModel.response {
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Generated Survey", subtitle: response.summary)
                                Text(response.report)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                        }
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Site Survey")
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let _ = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { viewModel.photoCount += 1 }
                }
            }
        }
    }

    private func generate() async {
        await viewModel.generate(with: services.siteSurveyService)
        guard let response = viewModel.response else { return }
        modelContext.insert(SiteSurvey(
            location: viewModel.location,
            notes: viewModel.notes,
            risks: viewModel.risks,
            generatedReport: response.report
        ))
    }
}

struct KnowledgeBaseView: View {
    @Environment(\.fieldOpsServices) private var services
    @State private var searchText = ""

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Offline Knowledge Base", subtitle: "SOPs, troubleshooting guides, procedures, manuals, and diagram placeholders.")

                    TextField("Search guides", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    ForEach(services.knowledgeBaseService.articles(matching: searchText)) { article in
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(article.category)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(FieldOpsTheme.cyan)
                                    Spacer()
                                    Image(systemName: "wifi.slash")
                                        .foregroundStyle(FieldOpsTheme.success)
                                }
                                Text(article.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(article.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                                Text(article.body)
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.78))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Guides")
        }
    }
}

struct ChecklistEngineView: View {
    @Environment(\.fieldOpsServices) private var services
    @State private var template: ChecklistTemplate = .ftthInstallation
    @State private var jobType = "FTTH new install"
    @State private var completed: Set<UUID> = []

    private var items: [ChecklistItem] {
        services.knowledgeBaseService.checklist(for: template, jobType: jobType)
    }

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Checklist Engine", subtitle: "Generate job-specific installation and maintenance checklists.")

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Template", selection: $template) {
                                ForEach(ChecklistTemplate.allCases) { template in
                                    Text(template.displayName).tag(template)
                                }
                            }
                            TextField("Job type", text: $jobType)
                        }
                    }

                    ForEach(items) { item in
                        Button {
                            if completed.contains(item.id) {
                                completed.remove(item.id)
                            } else {
                                completed.insert(item.id)
                            }
                        } label: {
                            PremiumPanel {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: completed.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(completed.contains(item.id) ? FieldOpsTheme.success : FieldOpsTheme.mutedText)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.white)
                                        Text(item.detail)
                                            .font(.footnote)
                                            .foregroundStyle(FieldOpsTheme.mutedText)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Checklists")
        }
    }
}

struct WorkPackGeneratorView: View {
    @Environment(\.fieldOpsServices) private var services
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WorkPackViewModel()

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "AI Work Pack Generator", subtitle: "Engineer, installation, maintenance, survey, and completion packs.")

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Picker("Pack type", selection: $viewModel.type) {
                                ForEach(WorkPackType.allCases) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            TextField("Job type", text: $viewModel.jobType)
                            TextField("Context", text: $viewModel.context, axis: .vertical)
                                .lineLimit(4...8)
                        }
                    }

                    Button {
                        Task { await generate() }
                    } label: {
                        Label(viewModel.isGenerating ? "Generating" : "Generate Work Pack", systemImage: "shippingbox.fill")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())
                    .disabled(viewModel.isGenerating)

                    if let response = viewModel.response {
                        PremiumPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: response.summary, subtitle: viewModel.type.displayName)
                                Text(response.report)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                        }
                    }

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle("Work Packs")
        }
    }

    private func generate() async {
        await viewModel.generate(with: services.workPackGeneratorService)
        guard let response = viewModel.response else { return }
        modelContext.insert(WorkPack(type: viewModel.type, generatedContent: response.report))
    }
}
