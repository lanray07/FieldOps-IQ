import Foundation

enum KnowledgeBaseSeed {
    static let articles: [KnowledgeArticle] = [
        KnowledgeArticle(
            title: "No Signal First Response",
            category: "Fault Finding",
            summary: "Structured inspection for ONT no-signal reports.",
            body: "Confirm the reported symptom, check ONT LEDs, inspect fiber connectors, review bend radius, verify patching, and record optical power before escalation.",
            tags: ["ONT", "LOS", "fiber", "no signal"]
        ),
        KnowledgeArticle(
            title: "Low Optical Power Checklist",
            category: "Fiber",
            summary: "Field checks for low receive power.",
            body: "Inspect connector cleanliness, splice history, cabinet patching, customer drop condition, and bends. Compare readings against provider thresholds and capture evidence.",
            tags: ["FTTH", "FTTP", "optical power", "testing"]
        ),
        KnowledgeArticle(
            title: "Packet Loss Triage",
            category: "Network",
            summary: "Operational guidance for intermittent packet loss.",
            body: "Differentiate local Wi-Fi, LAN, CPE, and upstream issues. Capture wired test results, interface errors, router uptime, and recent changes.",
            tags: ["packet loss", "router", "latency", "enterprise"]
        ),
        KnowledgeArticle(
            title: "Cabinet Maintenance SOP",
            category: "Infrastructure",
            summary: "Evidence and verification flow for cabinet visits.",
            body: "Record cabinet condition, access state, labelling, patch integrity, visible damage, environmental issues, and any deviations from work order records.",
            tags: ["cabinet", "patching", "maintenance"]
        ),
        KnowledgeArticle(
            title: "Customer Completion Notes",
            category: "Reports",
            summary: "How to write clear customer-facing job summaries.",
            body: "Use factual language. State work performed, tests observed, equipment changed, customer advice, and any follow-up. Avoid certification or regulatory claims.",
            tags: ["report", "customer", "completion"]
        ),
        KnowledgeArticle(
            title: "Safety and Verification Reminder",
            category: "Compliance",
            summary: "FieldOps IQ guidance boundaries.",
            body: "AI recommendations are informational. Always follow professional judgment, company safety procedures, and applicable engineering processes.",
            tags: ["disclaimer", "safety", "verification"]
        )
    ]
}
