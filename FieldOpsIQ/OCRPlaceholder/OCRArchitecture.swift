import Foundation
import UIKit

struct OCRResult: Identifiable, Hashable {
    var id = UUID()
    var recognizedText: String
    var confidence: Double
    var sourceDescription: String
}

protocol OCRProcessing {
    func extractText(from image: UIImage, sourceDescription: String) async throws -> OCRResult
}

struct OCRPlaceholderService: OCRProcessing {
    func extractText(from image: UIImage, sourceDescription: String) async throws -> OCRResult {
        OCRResult(
            recognizedText: "OCR placeholder: labels, serial numbers, port IDs, and cabinet references will be extracted here.",
            confidence: 0.0,
            sourceDescription: sourceDescription
        )
    }
}

enum OCRArchitecture {
    static let supportedInputs = [
        "ONT labels",
        "Router model plates",
        "Cabinet references",
        "Patch panel labels",
        "Switch port maps",
        "Fiber equipment serial numbers"
    ]

    static let pipeline = [
        "Capture or import image",
        "Pre-process for contrast and orientation",
        "Run OCR extraction",
        "Map text to equipment metadata",
        "Require technician verification before saving"
    ]
}
