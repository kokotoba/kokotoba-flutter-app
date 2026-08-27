import Flutter
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
  AVSpeechSynthesizerDelegate
{
  private let synthesizer = AVSpeechSynthesizer()
  private var pendingSpeechWorkItem: DispatchWorkItem?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    synthesizer.delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.kokotoba.app/text_to_speech",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "speak",
            let arguments = call.arguments as? [String: Any],
            let text = arguments["text"] as? String,
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.speakReliably(text)
      result(nil)
    }
  }

  private func speakReliably(_ text: String) {
    pendingSpeechWorkItem?.cancel()

    let needsStop = synthesizer.isSpeaking || synthesizer.isPaused
    if needsStop {
      synthesizer.stopSpeaking(at: .immediate)
    }

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.pendingSpeechWorkItem = nil
      self.activateSpeechAudioSession()

      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
      utterance.rate = AVSpeechUtteranceDefaultSpeechRate
      self.synthesizer.speak(utterance)
    }
    pendingSpeechWorkItem = workItem

    // AVSpeechSynthesizer finishes stopSpeaking asynchronously. Starting the
    // next utterance in the same run loop can cancel that new utterance too.
    let delay = needsStop ? 0.12 : 0
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func activateSpeechAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
      try audioSession.setActive(true)
    } catch {
      NSLog("Failed to activate text-to-speech audio session: \(error)")
    }
  }

  private func deactivateSpeechAudioSessionIfIdle() {
    DispatchQueue.main.async { [weak self] in
      guard let self,
            self.pendingSpeechWorkItem == nil,
            !self.synthesizer.isSpeaking else { return }
      try? AVAudioSession.sharedInstance().setActive(
        false,
        options: .notifyOthersOnDeactivation
      )
    }
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    deactivateSpeechAudioSessionIfIdle()
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didCancel utterance: AVSpeechUtterance
  ) {
    deactivateSpeechAudioSessionIfIdle()
  }
}
