import Observation
import PhotosUI
import SwiftData
import SwiftUI

struct JobManagementView: View {
    @Environment(RouterPath.self) private var router
    @Query(sort: \Job.createdAt, order: .reverse) private var jobs: [Job]

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        SectionHeader(title: "Job Management", subtitle: "Create, track, test, and complete field work.")
                        Button {
                            router.presentedSheet = .newJob
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(FieldOpsTheme.electricBlue)
                        }
                        .accessibilityLabel("New Job")
                    }

                    if jobs.isEmpty {
                        EmptyStatePanel(
                            title: "No jobs yet",
                            message: "Create your first field job from the dashboard or the add button.",
                            systemImage: "briefcase"
                        )
                    } else {
                        ForEach(jobs) { job in
                            NavigationLink {
                                JobDetailView(job: job)
                            } label: {
                                JobCard(job: job)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Jobs")
        }
    }
}

struct NewJobView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = JobEditorViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        TechBackground {
            Form {
                Section("Customer") {
                    TextField("Customer name", text: $viewModel.customer)
                    TextField("Location", text: $viewModel.location)
                }

                Section("Service") {
                    TextField("Service type", text: $viewModel.serviceType)
                    TextField("Equipment", text: $viewModel.equipment)
                    Picker("Status", selection: .constant(JobStatus.assigned)) {
                        Text(JobStatus.assigned.displayName).tag(JobStatus.assigned)
                    }
                    .disabled(true)
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 120)
                }

                Section("Photos") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Attach Photo", systemImage: "camera.fill")
                    }
                    Text("\(viewModel.photoCount) photo placeholder\(viewModel.photoCount == 1 ? "" : "s") attached")
                        .foregroundStyle(FieldOpsTheme.mutedText)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Label("Create Job", systemImage: "checkmark.circle.fill")
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New Job")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let _ = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.photoCount += 1
                    }
                }
            }
        }
    }

    private func save() {
        modelContext.insert(viewModel.makeJob())
        dismiss()
    }
}

struct JobDetailView: View {
    @Environment(RouterPath.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Bindable var job: Job

    var body: some View {
        TechBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    JobCard(job: job)

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Job Details", subtitle: "Update field state as work progresses.")

                            TextField("Customer", text: $job.customer)
                            TextField("Location", text: $job.location)
                            TextField("Service type", text: $job.serviceType)
                            TextField("Equipment", text: $job.equipment)

                            Picker("Status", selection: $job.statusRawValue) {
                                ForEach(JobStatus.allCases) { status in
                                    Text(status.displayName).tag(status.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Field Notes", subtitle: "Engineer observations and customer updates.")
                            TextEditor(text: $job.notes)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 150)
                                .foregroundStyle(.white)
                        }
                    }

                    PremiumPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Photos", subtitle: "Camera/photo upload architecture.")
                            if job.photoReferences.isEmpty {
                                Text("No photo placeholders attached.")
                                    .font(.subheadline)
                                    .foregroundStyle(FieldOpsTheme.mutedText)
                            } else {
                                ForEach(job.photoReferences, id: \.self) { reference in
                                    Label(reference, systemImage: "photo.fill")
                                        .foregroundStyle(.white.opacity(0.84))
                                }
                            }
                        }
                    }

                    Button {
                        router.presentedSheet = .reportPreview(
                            title: "Engineer Report - \(job.customer)",
                            body: reportBody,
                            category: "Engineer Report"
                        )
                    } label: {
                        Label("Preview Engineer Report", systemImage: "doc.richtext.fill")
                    }
                    .buttonStyle(PrimaryTechButtonStyle())

                    DisclaimerBanner()
                }
                .padding()
            }
            .navigationTitle(job.customer)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        modelContext.delete(job)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete Job")
                }
            }
        }
    }

    private var reportBody: String {
        """
        Customer: \(job.customer)
        Location: \(job.location)
        Service Type: \(job.serviceType)
        Equipment: \(job.equipment)
        Status: \(job.status.displayName)

        Notes:
        \(job.notes.isEmpty ? "No notes recorded." : job.notes)

        Photo Attachments:
        \(job.photoReferences.isEmpty ? "No photo placeholders attached." : job.photoReferences.joined(separator: "\n"))

        Technician verification required before customer handover.
        """
    }
}
