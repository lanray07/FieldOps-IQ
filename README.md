# FieldOps IQ

FieldOps IQ is a premium SwiftUI iOS app scaffold for telecom field technicians, fiber installers, broadband engineers, network engineers, contractors, and supervisors.

Positioning: **The AI copilot for telecom field engineers.**

## Build

Open `FieldOps IQ.xcodeproj` in Xcode on macOS and run the shared `FieldOps IQ` scheme on an iOS 17+ simulator or device.

This Windows workspace includes a Swift toolchain, but not Xcode or iOS SDKs, so simulator compilation must be performed in Xcode.

## Architecture

- SwiftUI `NavigationStack` app shell with tab-local routing.
- MVVM view models for jobs, fault finding, voice reports, equipment scans, site surveys, and work packs.
- SwiftData persistence for technician profiles, jobs, fault reports, voice transcripts, surveys, scans, work packs, and subscription state.
- StoreKit 2 subscription scaffolding with mock activation fallback.
- Speech-to-text and audio recording services.
- OCR placeholder service and pipeline notes.
- Offline knowledge base and checklist generation.
- Native PDF generation and share sheet.
- Swift Charts analytics dashboard.
- WidgetKit and Apple Watch placeholder architecture.

## AI Safety Boundary

All AI output is presented as informational guidance only. FieldOps IQ does not certify installations, guarantee engineering outcomes, replace professional judgment, replace safety procedures, or provide regulatory approval.
