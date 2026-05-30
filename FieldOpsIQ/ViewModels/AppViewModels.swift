import Foundation
import Observation

@MainActor
@Observable
final class JobEditorViewModel {
    var customer = ""
    var location = ""
    var serviceType = "FTTH installation"
    var equipment = "ONT, router, patch lead"
    var notes = ""
    var photoCount = 0

    var canSave: Bool {
        !customer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeJob() -> Job {
        Job(
            customer: customer,
            location: location,
            serviceType: serviceType,
            equipment: equipment,
            notes: notes,
            photoReferences: (0..<photoCount).map { "Photo attachment \($0 + 1)" }
        )
    }
}

@MainActor
@Observable
final class FaultFinderViewModel {
    var symptoms = "No signal at ONT"
    var equipmentType = "ONT / router"
    var errorIndicators = "LOS light active, no WAN IP"
    var isLoading = false
    var response: AIResponse?
    var errorMessage: String?

    var canAnalyze: Bool {
        !symptoms.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func analyze(with service: FaultAnalysisService) async {
        guard canAnalyze else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            response = try await service.analyze(symptoms: symptoms, equipmentType: equipmentType, indicators: errorIndicators)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
@Observable
final class VoiceReportViewModel {
    var transcript = ""
    var category = "Engineer Report"
    var isSummarizing = false
    var response: AIResponse?
    var errorMessage: String?

    var canSummarize: Bool {
        transcript.trimmingCharacters(in: .whitespacesAndNewlines).count > 12
    }

    func summarize(with service: VoiceReportService) async {
        guard canSummarize else { return }
        isSummarizing = true
        errorMessage = nil
        defer { isSummarizing = false }

        do {
            response = try await service.summarize(transcript: transcript, category: category)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
@Observable
final class EquipmentScanViewModel {
    var declaredType = "ONT"
    var notes = "Photo uploaded for visual inspection."
    var imageData: Data?
    var isAnalyzing = false
    var response: AIResponse?
    var errorMessage: String?

    func analyze(with service: EquipmentRecognitionService) async {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            response = try await service.identify(imageData: imageData, declaredType: declaredType, notes: notes)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
@Observable
final class SiteSurveyViewModel {
    var location = ""
    var notes = "Access route, cabinet position, and customer equipment location captured."
    var risks = "Working at height, confined access, customer premises access"
    var inventory = "ONT, router, patch leads, drop cable, labels"
    var photoCount = 0
    var isGenerating = false
    var response: AIResponse?
    var errorMessage: String?

    var canGenerate: Bool {
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func generate(with service: SiteSurveyService) async {
        guard canGenerate else { return }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            response = try await service.generate(location: location, notes: notes, risks: risks, inventory: inventory)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
@Observable
final class WorkPackViewModel {
    var type: WorkPackType = .engineerJob
    var jobType = "FTTP installation"
    var context = "Customer premises install with ONT activation, router setup, service testing, and handover notes."
    var isGenerating = false
    var response: AIResponse?
    var errorMessage: String?

    func generate(with service: WorkPackGeneratorService) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            response = try await service.generate(type: type, jobType: jobType, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
