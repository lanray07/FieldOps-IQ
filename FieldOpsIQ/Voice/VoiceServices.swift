import AVFoundation
import Foundation
import Observation
import Speech
import SwiftUI

@MainActor
@Observable
final class SpeechRecognitionService {
    var transcript = ""
    var isAuthorized = false
    var isRecording = false
    var errorMessage: String?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.isAuthorized = status == .authorized
                if status != .authorized {
                    self?.errorMessage = "Speech recognition permission is required for live transcription."
                }
            }
        }
    }

    func startTranscribing() throws {
        guard !audioEngine.isRunning else { return }
        guard isAuthorized else {
            errorMessage = "Speech recognition is not authorized."
            return
        }

        transcript = ""
        errorMessage = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self.stopTranscribing()
                }
            }
        }
    }

    func stopTranscribing() {
        guard audioEngine.isRunning || isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}

@MainActor
@Observable
final class VoiceRecordingService {
    var recordingURL: URL?
    var isRecording = false
    var errorMessage: String?

    private var recorder: AVAudioRecorder?

    func startRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("fieldops-voice-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            recordingURL = url
            isRecording = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
    }
}

@MainActor
@Observable
final class WaveformAnimationManager {
    var samples: [CGFloat] = Array(repeating: 0.2, count: 28)
    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.samples = (0..<28).map { index in
                    let phase = CGFloat(index).truncatingRemainder(dividingBy: 6) / 6
                    return CGFloat.random(in: 0.18...0.96) * (0.72 + phase * 0.28)
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        samples = Array(repeating: 0.18, count: 28)
    }
}
