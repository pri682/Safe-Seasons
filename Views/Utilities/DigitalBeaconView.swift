//
//  DigitalBeaconView.swift
//  SafeSeasons
//
//  Offline SOS beacon: flashlight + screen flash in Morse code.
//

import SwiftUI
import AVFoundation

struct DigitalBeaconView: View {
    @State private var isActive = false
    @State private var flashTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
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
                    Text("Hold device high and visible. SOS pattern: ••• --- •••")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
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
        // SOS in Morse: ••• (S) --- (O) ••• (S)
        // Dot = 0.2s, Dash = 0.6s, gap = 0.2s
        
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
