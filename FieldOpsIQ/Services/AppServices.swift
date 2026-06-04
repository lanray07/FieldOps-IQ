import Foundation
import Observation
import StoreKit
import SwiftUI
import UIKit
import UserNotifications

protocol AIService: Sendable {
    func perform(_ request: FieldOpsAIRequest) async throws -> AIResponse
}

struct MockAIService: AIService {
    private let disclaimer = "Informational guidance only. Technician verification required. Not engineering certification, regulatory approval, or safety certification."

    func perform(_ request: FieldOpsAIRequest) async throws -> AIResponse {
        try await Task.sleep(for: .milliseconds(450))

        switch request.module {
        case "fault":
            return AIResponse(
                analysis: "Possible cause: \(request.faultDescription.isEmpty ? "service degradation or equipment state mismatch" : request.faultDescription). Likely issue areas include optical power, connector condition, CPE state, cabinet patching, or upstream network instability. \(disclaimer)",
                recommendations: [
                    "Confirm the customer-facing symptom and record exact error indicators.",
                    "Inspect connectors, bend radius, cabinet patching, ONT status LEDs, and router WAN state.",
                    "Run optical power or packet-loss testing before replacing equipment.",
                    "Escalate if readings are outside provider thresholds or if upstream alarms are present."
                ],
                report: "Fault guidance generated for \(request.equipmentType.isEmpty ? "field equipment" : request.equipmentType). Technician must verify every finding on site before action.",
                summary: "Likely access-side or equipment issue requiring structured inspection."
            )
        case "voice":
            return AIResponse(
                analysis: "Voice notes indicate field activity that can be converted into a structured engineer report. \(disclaimer)",
                recommendations: [
                    "Keep customer-facing language factual and avoid certification claims.",
                    "Separate diagnostics, actions taken, and follow-up requirements.",
                    "Attach test results or photos where available."
                ],
                report: "Engineer summary:\n\(request.voiceTranscript)\n\nRecommended report structure: site context, diagnostics performed, observed condition, actions taken, customer update, and technician verification.",
                summary: request.voiceTranscript.isEmpty ? "No transcript captured yet." : "Field notes converted into a concise operational summary."
            )
        case "equipment":
            return AIResponse(
                analysis: "Possible equipment identification: \(request.equipmentType.isEmpty ? "telecom CPE or network field asset" : request.equipmentType). Observations should be verified against labels, serials, port state, and provider inventory. \(disclaimer)",
                recommendations: [
                    "Check model label, power status, link indicators, and visible cabling strain.",
                    "Photograph serial numbers and patching before changes.",
                    "Flag damaged housings, loose terminations, missing labels, or obstructed ventilation."
                ],
                report: "Equipment observation placeholder generated for technician review.",
                summary: "Equipment scan ready for verification."
            )
        case "survey":
            return AIResponse(
                analysis: "Installation readiness depends on route access, risk controls, equipment inventory, power availability, and verified measurements. \(disclaimer)",
                recommendations: [
                    "Capture ingress route, cabinet/ONT position, hazards, and access constraints.",
                    "Confirm materials before scheduling installation.",
                    "Mark any safety observations for local procedure review."
                ],
                report: "Site survey report:\nLocation: \(request.jobType)\nNotes: \(request.faultDescription)\n\nReadiness: conditional on technician verification and local procedure checks.",
                summary: "Survey pack generated with readiness and risk observations."
            )
        case "workPack":
            return AIResponse(
                analysis: "Work pack generated from the selected job type and field context. \(disclaimer)",
                recommendations: [
                    "Review the work sequence before starting.",
                    "Confirm required test equipment and access permissions.",
                    "Document deviations and escalation points."
                ],
                report: "Work pack for \(request.jobType):\n1. Site context\n2. Required equipment\n3. Inspection sequence\n4. Testing sequence\n5. Customer update\n6. Evidence checklist\n7. Escalation notes",
                summary: "Operational work pack ready."
            )
        default:
            return AIResponse(
                analysis: "FieldOps IQ mock AI is enabled. \(disclaimer)",
                recommendations: ["Verify recommendations on site.", "Follow company procedures and safety requirements."],
                report: "Mock AI response.",
                summary: "Mock AI response generated."
            )
        }
    }
}

struct RemoteAIService: AIService {
    var endpoint: URL?

    init(endpoint: URL? = URL(string: "https://YOUR_BACKEND_URL.com/fieldops-iq")) {
        self.endpoint = endpoint
    }

    func perform(_ request: FieldOpsAIRequest) async throws -> AIResponse {
        guard let endpoint else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let backendResponse = try JSONDecoder().decode(FieldOpsAIBackendResponse.self, from: data)
        return AIResponse(
            analysis: backendResponse.analysis,
            recommendations: backendResponse.recommendations,
            report: backendResponse.report,
            summary: backendResponse.summary
        )
    }
}

final class FaultAnalysisService {
    private let aiService: any AIService

    init(aiService: any AIService) {
        self.aiService = aiService
    }

    func analyze(symptoms: String, equipmentType: String, indicators: String) async throws -> AIResponse {
        try await aiService.perform(FieldOpsAIRequest(
            module: "fault",
            jobType: equipmentType,
            faultDescription: [symptoms, indicators].filter { !$0.isEmpty }.joined(separator: "\n"),
            voiceTranscript: "",
            equipmentType: equipmentType
        ))
    }
}

final class VoiceReportService {
    private let aiService: any AIService

    init(aiService: any AIService) {
        self.aiService = aiService
    }

    func summarize(transcript: String, category: String) async throws -> AIResponse {
        try await aiService.perform(FieldOpsAIRequest(
            module: "voice",
            jobType: category,
            faultDescription: "",
            voiceTranscript: transcript,
            equipmentType: ""
        ))
    }
}

final class EquipmentRecognitionService {
    private let aiService: any AIService

    init(aiService: any AIService) {
        self.aiService = aiService
    }

    func identify(imageData: Data?, declaredType: String, notes: String) async throws -> AIResponse {
        try await aiService.perform(FieldOpsAIRequest(
            module: "equipment",
            jobType: declaredType,
            faultDescription: notes,
            voiceTranscript: "",
            equipmentType: declaredType
        ))
    }
}

final class SiteSurveyService {
    private let aiService: any AIService

    init(aiService: any AIService) {
        self.aiService = aiService
    }

    func generate(location: String, notes: String, risks: String, inventory: String) async throws -> AIResponse {
        try await aiService.perform(FieldOpsAIRequest(
            module: "survey",
            jobType: location,
            faultDescription: [notes, risks, inventory].filter { !$0.isEmpty }.joined(separator: "\n\n"),
            voiceTranscript: "",
            equipmentType: ""
        ))
    }
}

final class WorkPackGeneratorService {
    private let aiService: any AIService

    init(aiService: any AIService) {
        self.aiService = aiService
    }

    func generate(type: WorkPackType, jobType: String, context: String) async throws -> AIResponse {
        try await aiService.perform(FieldOpsAIRequest(
            module: "workPack",
            jobType: "\(type.displayName) - \(jobType)",
            faultDescription: context,
            voiceTranscript: "",
            equipmentType: ""
        ))
    }
}

final class KnowledgeBaseService {
    func articles(matching query: String = "") -> [KnowledgeArticle] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return KnowledgeBaseSeed.articles
        }

        let normalized = query.lowercased()
        return KnowledgeBaseSeed.articles.filter { article in
            article.title.lowercased().contains(normalized)
            || article.category.lowercased().contains(normalized)
            || article.tags.contains { $0.lowercased().contains(normalized) }
            || article.body.lowercased().contains(normalized)
        }
    }

    func checklist(for template: ChecklistTemplate, jobType: String) -> [ChecklistItem] {
        let shared = [
            ChecklistItem(title: "Confirm work order", detail: "Verify customer, location, access notes, and service scope."),
            ChecklistItem(title: "Capture site evidence", detail: "Take photos before changes and record any visible installation risks."),
            ChecklistItem(title: "Run baseline test", detail: "Record current signal, link, or connectivity state before intervention."),
            ChecklistItem(title: "Technician verification", detail: "Confirm all findings against provider procedure and local safety requirements.")
        ]

        let templateItems: [ChecklistItem]
        switch template {
        case .ftthInstallation:
            templateItems = [
                ChecklistItem(title: "Inspect fiber route", detail: "Check bend radius, entry point, and route protection."),
                ChecklistItem(title: "Validate ONT placement", detail: "Confirm power access, ventilation, and customer access.")
            ]
        case .fttpInstallation:
            templateItems = [
                ChecklistItem(title: "Confirm premises termination", detail: "Verify drop cable path and termination point."),
                ChecklistItem(title: "Document optical readings", detail: "Record optical power against provider thresholds.")
            ]
        case .broadbandInstall:
            templateItems = [
                ChecklistItem(title: "Configure router", detail: "Validate WAN, Wi-Fi, LAN, and customer handover state."),
                ChecklistItem(title: "Run service test", detail: "Record speed, latency, and packet-loss observations where available.")
            ]
        case .routerReplacement:
            templateItems = [
                ChecklistItem(title: "Backup customer settings", detail: "Record SSID, port mappings, or provider-required configuration."),
                ChecklistItem(title: "Confirm device activation", detail: "Check WAN registration and customer devices.")
            ]
        case .cabinetMaintenance:
            templateItems = [
                ChecklistItem(title: "Inspect cabinet condition", detail: "Check labels, patching, environmental condition, and access security."),
                ChecklistItem(title: "Confirm patch records", detail: "Compare physical patching with the assigned work order.")
            ]
        case .wirelessDeployment:
            templateItems = [
                ChecklistItem(title: "Assess line of sight", detail: "Record mounting, obstruction, and signal observations."),
                ChecklistItem(title: "Validate link stability", detail: "Run connectivity and throughput checks before handover.")
            ]
        }

        let jobSpecific = ChecklistItem(title: "Job-specific review", detail: "Apply \(jobType.isEmpty ? template.displayName : jobType) requirements before completion.")
        return templateItems + shared + [jobSpecific]
    }
}

final class PDFReportService {
    @MainActor
    func makePDF(title: String, body: String) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(title.replacingOccurrences(of: " ", with: "-"))-\(UUID().uuidString.prefix(6)).pdf")

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: UIColor.gray
            ]

            NSString(string: title).draw(in: CGRect(x: 36, y: 36, width: 540, height: 42), withAttributes: titleAttributes)
            NSString(string: "FieldOps IQ - AI copilot for telecom field engineers").draw(in: CGRect(x: 36, y: 82, width: 540, height: 22), withAttributes: footerAttributes)
            NSString(string: body).draw(in: CGRect(x: 36, y: 124, width: 540, height: 560), withAttributes: bodyAttributes)
            NSString(string: "Informational guidance only. Technician verification required. Not engineering certification, regulatory approval, or safety certification.")
                .draw(in: CGRect(x: 36, y: 720, width: 540, height: 34), withAttributes: footerAttributes)
        }

        return url
    }
}

final class NotificationService {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleFaultReminder(title: String, body: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 30, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}

@MainActor
@Observable
final class SubscriptionService {
    private let productIdentifiers: [SubscriptionPlan: String] = [
        .professionalMonthly: "fieldops_iq_professional_monthly",
        .professionalYearly: "fieldops_iq_professional_yearly",
        .contractorProMonthly: "fieldops_iq_contractor_pro_monthly"
    ]

    var products: [Product] = []
    var activePlan: SubscriptionPlan = .free
    var renewsAt: Date?
    var isLoading = false
    var errorMessage: String?
    var restoreMessage: String?

    var statusText: String {
        activePlan == .free ? "Free plan" : "\(activePlan.title) active"
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Array(productIdentifiers.values))
        } catch {
            errorMessage = "StoreKit products unavailable in mock mode."
        }
    }

    func purchase(_ plan: SubscriptionPlan) async {
        guard plan != .free else {
            activePlan = .free
            return
        }

        errorMessage = nil
        restoreMessage = nil

        guard let productID = productIdentifiers[plan],
              let product = products.first(where: { $0.id == productID }) else {
            activePlan = plan
            renewsAt = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            return
        }

        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                activePlan = plan
                renewsAt = transaction.expirationDate
                await transaction.finish()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        restoreMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            let restored = await refreshEntitlements()
            restoreMessage = restored ? "\(activePlan.title) restored." : "No previous purchases were found for this Apple ID."
        } catch {
            errorMessage = "Restore purchases failed: \(error.localizedDescription)"
        }
    }

    @discardableResult
    func refreshEntitlements() async -> Bool {
        var restoredPlan: SubscriptionPlan?
        var restoredRenewal: Date?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  let plan = plan(for: transaction.productID) else {
                continue
            }
            restoredPlan = plan
            restoredRenewal = transaction.expirationDate
            break
        }

        if let restoredPlan {
            activePlan = restoredPlan
            renewsAt = restoredRenewal
            return true
        }

        activePlan = .free
        renewsAt = nil
        return false
    }

    private func plan(for productID: String) -> SubscriptionPlan? {
        productIdentifiers.first(where: { $0.value == productID })?.key
    }
}

struct FieldOpsServices {
    var faultAnalysisService: FaultAnalysisService
    var voiceReportService: VoiceReportService
    var equipmentRecognitionService: EquipmentRecognitionService
    var siteSurveyService: SiteSurveyService
    var workPackGeneratorService: WorkPackGeneratorService
    var knowledgeBaseService: KnowledgeBaseService
    var pdfReportService: PDFReportService
    var notificationService: NotificationService

    static let mock: FieldOpsServices = {
        let ai = MockAIService()
        return FieldOpsServices(
            faultAnalysisService: FaultAnalysisService(aiService: ai),
            voiceReportService: VoiceReportService(aiService: ai),
            equipmentRecognitionService: EquipmentRecognitionService(aiService: ai),
            siteSurveyService: SiteSurveyService(aiService: ai),
            workPackGeneratorService: WorkPackGeneratorService(aiService: ai),
            knowledgeBaseService: KnowledgeBaseService(),
            pdfReportService: PDFReportService(),
            notificationService: NotificationService()
        )
    }()
}

private struct FieldOpsServicesKey: EnvironmentKey {
    static let defaultValue = FieldOpsServices.mock
}

extension EnvironmentValues {
    var fieldOpsServices: FieldOpsServices {
        get { self[FieldOpsServicesKey.self] }
        set { self[FieldOpsServicesKey.self] = newValue }
    }
}
