//
//  DigitalBeaconView.swift
//  SafeSeasons
//
//  Offline SOS beacon: flashlight + screen flash in Morse code.
//  SOS pattern (••• --- •••) follows International Morse code, the standard
//  distress signal adopted internationally (e.g. maritime/aviation).
//

import SwiftUI
import AVFoundation

struct DigitalBeaconView: View {
    @State private var isActive = false
    @State private var flashTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss

    /// Source for users to check SOS / International Morse code.
    private static let morseCodeSourceURL = URL(string: "https://en.wikipedia.org/wiki/SOS")!

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: isActive ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(isActive ? .yellow : .gray)
                    .opacity(isActive ? 1.0 : 0.6)
                    .animation(isActive ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isActive)
                
                Text(isActive ? "SOS Beacon Active" : "Digital Beacon")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(isActive ? "Flashing SOS in Morse code" : "Turn your device into a rescue beacon")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    if isActive {
                        stopBeacon()
                    } else {
                        startBeacon()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isActive ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(isActive ? "Stop Beacon" : "Start SOS Beacon")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isActive ? Color.red : AppColors.ctaGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                
                if isActive {
                    VStack(spacing: 6) {
                        Text("Hold device high and visible. SOS pattern: ••• --- •••")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("SOS (••• --- •••) is the international Morse code distress signal.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer(minLength: 16)

                Link(destination: DigitalBeaconView.morseCodeSourceURL) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text("Source: SOS / Morse code (Wikipedia)")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isActive ? Color.black : Color(.systemGroupedBackground))
            .navigationTitle("Digital Beacon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onDisappear {
                stopBeacon()
            }
        }
    }

    private func startBeacon() {
        guard !isActive else { return }
        isActive = true
        
        flashTask = Task {
            while !Task.isCancelled && isActive {
                await flashSOSPattern()
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second pause between patterns
            }
        }
    }

    private func stopBeacon() {
        isActive = false
        flashTask?.cancel()
        flashTask = nil
        setTorch(false)
    }

    private func flashSOSPattern() async {
        // International Morse code: SOS = ••• (S) --- (O) ••• (S)
        // Dot = 0.2s, dash = 0.6s, intra-letter gap = 0.2s, letter gap = 0.6s
        
        // S: •••
        await flash(duration: 0.2)
        await pause(0.2)
        await flash(duration: 0.2)
        await pause(0.2)
        await flash(duration: 0.2)
        await pause(0.6) // Letter gap
        
        // O: ---
        await flash(duration: 0.6)
        await pause(0.2)
        await flash(duration: 0.6)
        await pause(0.2)
        await flash(duration: 0.6)
        await pause(0.6) // Letter gap
        
        // S: •••
        await flash(duration: 0.2)
        await pause(0.2)
        await flash(duration: 0.2)
        await pause(0.2)
        await flash(duration: 0.2)
    }

    private func flash(duration: TimeInterval) async {
        setTorch(true)
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        setTorch(false)
    }

    private func pause(_ duration: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    private func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
}
