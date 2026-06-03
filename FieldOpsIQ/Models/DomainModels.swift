import Foundation
import SwiftData

enum TechnicianRole: String, CaseIterable, Identifiable, Codable {
    case telecomEngineer
    case fiberTechnician
    case networkEngineer
    case broadbandInstaller
    case contractor
    case supervisor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .telecomEngineer: "Telecom Engineer"
        case .fiberTechnician: "Fiber Technician"
        case .networkEngineer: "Network Engineer"
        case .broadbandInstaller: "Broadband Installer"
        case .contractor: "Contractor"
        case .supervisor: "Supervisor"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Identifiable, Codable {
    case trainee
    case junior
    case experienced
    case senior

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .trainee: "Trainee"
        case .junior: "Junior"
        case .experienced: "Experienced"
        case .senior: "Senior"
        }
    }
}

enum Specialization: String, CaseIterable, Identifiable, Codable {
    case ftth
    case fttp
    case broadband
    case wireless
    case enterpriseNetworking
    case infrastructure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ftth: "FTTH"
        case .fttp: "FTTP"
        case .broadband: "Broadband"
        case .wireless: "Wireless"
        case .enterpriseNetworking: "Enterprise Networking"
        case .infrastructure: "Infrastructure"
        }
    }
}

enum JobStatus: String, CaseIterable, Identifiable, Codable {
    case assigned
    case inProgress
    case testing
    case completed
    case followUp

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .assigned: "Assigned"
        case .inProgress: "In Progress"
        case .testing: "Testing"
        case .completed: "Completed"
        case .followUp: "Follow-up"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case professionalMonthly
    case professionalYearly
    case contractorProMonthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .professionalMonthly: "Professional Monthly"
        case .professionalYearly: "Professional Yearly"
        case .contractorProMonthly: "Contractor Pro Monthly"
        }
    }

    var price: String {
        switch self {
        case .free: "Included"
        case .professionalMonthly: "GBP 14.99/mo"
        case .professionalYearly: "GBP 119.99/yr"
        case .contractorProMonthly: "GBP 49.99/mo"
        }
    }

    var subscriptionLength: String {
        switch self {
        case .free: "No subscription"
        case .professionalMonthly, .contractorProMonthly: "1 month"
        case .professionalYearly: "1 year"
        }
    }

    var pricePerPeriod: String {
        switch self {
        case .free: "Included"
        case .professionalMonthly: "GBP 14.99 per month"
        case .professionalYearly: "GBP 119.99 per year"
        case .contractorProMonthly: "GBP 49.99 per month"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            ["Limited jobs", "Limited reports", "Limited fault analysis"]
        case .professionalMonthly, .professionalYearly:
            ["Unlimited jobs", "AI fault finder", "Voice reporting", "PDF exports", "Offline knowledge base"]
        case .contractorProMonthly:
            ["Advanced analytics", "Team management placeholder", "Premium work packs", "Supervisor dashboards placeholder"]
        }
    }
}

enum WorkPackType: String, CaseIterable, Identifiable, Codable {
    case engineerJob
    case installation
    case maintenance
    case survey
    case customerCompletion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .engineerJob: "Engineer Job Pack"
        case .installation: "Installation Pack"
        case .maintenance: "Maintenance Pack"
        case .survey: "Survey Pack"
        case .customerCompletion: "Customer Completion Pack"
        }
    }
}

enum ChecklistTemplate: String, CaseIterable, Identifiable, Codable {
    case ftthInstallation
    case fttpInstallation
    case broadbandInstall
    case routerReplacement
    case cabinetMaintenance
    case wirelessDeployment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ftthInstallation: "FTTH Installation"
        case .fttpInstallation: "FTTP Installation"
        case .broadbandInstall: "Broadband Install"
        case .routerReplacement: "Router Replacement"
        case .cabinetMaintenance: "Cabinet Maintenance"
        case .wirelessDeployment: "Wireless Deployment"
        }
    }
}

struct ChecklistItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var isRequired: Bool

    init(id: UUID = UUID(), title: String, detail: String, isRequired: Bool = true) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isRequired = isRequired
    }
}

struct AIResponse: Codable, Hashable {
    var analysis: String
    var recommendations: [String]
    var report: String
    var summary: String
}

struct FieldOpsAIRequest: Codable {
    var module: String
    var jobType: String
    var faultDescription: String
    var voiceTranscript: String
    var equipmentType: String
}

struct FieldOpsAIBackendResponse: Codable {
    var analysis: String
    var recommendations: [String]
    var report: String
    var summary: String
}

struct KnowledgeArticle: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var category: String
    var summary: String
    var body: String
    var tags: [String]
}

struct ReportDraft: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var body: String
    var category: String
    var createdAt = Date()
}

struct AnalyticsDataPoint: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var value: Double
}

@Model
final class TechnicianProfile {
    @Attribute(.unique) var id: UUID
    var roleRawValue: String
    var experienceLevelRawValue: String
    var specializationRawValue: String
    var createdAt: Date

    var role: TechnicianRole {
        get { TechnicianRole(rawValue: roleRawValue) ?? .telecomEngineer }
        set { roleRawValue = newValue.rawValue }
    }

    var experienceLevel: ExperienceLevel {
        get { ExperienceLevel(rawValue: experienceLevelRawValue) ?? .experienced }
        set { experienceLevelRawValue = newValue.rawValue }
    }

    var specialization: Specialization {
        get { Specialization(rawValue: specializationRawValue) ?? .ftth }
        set { specializationRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        role: TechnicianRole,
        experienceLevel: ExperienceLevel,
        specialization: Specialization,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.roleRawValue = role.rawValue
        self.experienceLevelRawValue = experienceLevel.rawValue
        self.specializationRawValue = specialization.rawValue
        self.createdAt = createdAt
    }
}

@Model
final class Job {
    @Attribute(.unique) var id: UUID
    var customer: String
    var location: String
    var serviceType: String
    var equipment: String
    var statusRawValue: String
    var notes: String
    var photoReferenceList: String
    var createdAt: Date
    var updatedAt: Date

    var status: JobStatus {
        get { JobStatus(rawValue: statusRawValue) ?? .assigned }
        set {
            statusRawValue = newValue.rawValue
            updatedAt = Date()
        }
    }

    var photoReferences: [String] {
        get {
            photoReferenceList
                .split(separator: "\n")
                .map(String.init)
                .filter { !$0.isEmpty }
        }
        set {
            photoReferenceList = newValue.joined(separator: "\n")
            updatedAt = Date()
        }
    }

    init(
        id: UUID = UUID(),
        customer: String,
        location: String,
        serviceType: String,
        equipment: String,
        status: JobStatus = .assigned,
        notes: String = "",
        photoReferences: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.customer = customer
        self.location = location
        self.serviceType = serviceType
        self.equipment = equipment
        self.statusRawValue = status.rawValue
        self.notes = notes
        self.photoReferenceList = photoReferences.joined(separator: "\n")
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}

@Model
final class FaultReport {
    @Attribute(.unique) var id: UUID
    var symptoms: String
    var equipmentType: String
    var aiAnalysis: String
    var recommendationsText: String
    var createdAt: Date

    var recommendations: [String] {
        recommendationsText
            .split(separator: "\n")
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    init(
        id: UUID = UUID(),
        symptoms: String,
        equipmentType: String,
        aiAnalysis: String,
        recommendations: [String],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.symptoms = symptoms
        self.equipmentType = equipmentType
        self.aiAnalysis = aiAnalysis
        self.recommendationsText = recommendations.joined(separator: "\n")
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript {
    @Attribute(.unique) var id: UUID
    var transcript: String
    var summary: String
    var category: String
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, summary: String, category: String = "Engineer Report", createdAt: Date = Date()) {
        self.id = id
        self.transcript = transcript
        self.summary = summary
        self.category = category
        self.createdAt = createdAt
    }
}

@Model
final class SiteSurvey {
    @Attribute(.unique) var id: UUID
    var location: String
    var notes: String
    var risks: String
    var generatedReport: String
    var createdAt: Date

    init(id: UUID = UUID(), location: String, notes: String, risks: String, generatedReport: String, createdAt: Date = Date()) {
        self.id = id
        self.location = location
        self.notes = notes
        self.risks = risks
        self.generatedReport = generatedReport
        self.createdAt = createdAt
    }
}

@Model
final class EquipmentScan {
    @Attribute(.unique) var id: UUID
    var equipmentType: String
    var observations: String
    var maintenanceRecommendation: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        equipmentType: String,
        observations: String,
        maintenanceRecommendation: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.equipmentType = equipmentType
        self.observations = observations
        self.maintenanceRecommendation = maintenanceRecommendation
        self.createdAt = createdAt
    }
}

@Model
final class WorkPack {
    @Attribute(.unique) var id: UUID
    var typeRawValue: String
    var generatedContent: String
    var createdAt: Date

    var type: WorkPackType {
        get { WorkPackType(rawValue: typeRawValue) ?? .engineerJob }
        set { typeRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), type: WorkPackType, generatedContent: String, createdAt: Date = Date()) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.generatedContent = generatedContent
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var planRawValue: String
    var isActive: Bool
    var renewsAt: Date?

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRawValue) ?? .free }
        set { planRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = true, renewsAt: Date? = nil) {
        self.id = id
        self.planRawValue = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}
