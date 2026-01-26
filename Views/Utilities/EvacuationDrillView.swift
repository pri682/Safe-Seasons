//
//  EvacuationDrillView.swift
//  SafeSeasons
//
//  Interactive 2-minute evacuation drill with checklist.
//

import SwiftUI

struct EvacuationDrillView: View {
    @State private var isRunning = false
    @State private var timeRemaining = 120 // 2 minutes in seconds
    @State private var checkedItems: Set<String> = []
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss

    private let drillItems = [
        ("Keys", "key.fill"),
        ("Wallet", "creditcard.fill"),
        ("Medications", "pills.fill"),
        ("Phone", "phone.fill"),
        ("Documents", "doc.fill"),
        ("Water", "drop.fill")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if !isRunning && timeRemaining == 120 {
                        // Start screen
                        VStack(spacing: 20) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 60))
                                .foregroundStyle(AppColors.ctaGreen)
                            Text("2-Minute Evacuation Drill")
                                .font(.title.weight(.bold))
                            Text("Practice your evacuation routine. Check off items as you gather them.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button {
                                startDrill()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Start Drill")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.ctaGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding()
                    } else if isRunning {
                        // Active drill
                        VStack(spacing: 24) {
                            // Timer
                            VStack(spacing: 8) {
                                Text("Time Remaining")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text(timeString(timeRemaining))
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(timeRemaining < 30 ? .red : AppColors.ctaGreen)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.softGreen.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Checklist
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Gather These Items")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                ForEach(drillItems, id: \.0) { item, icon in
                                    HStack(spacing: 14) {
                                        Button {
                                            if checkedItems.contains(item) {
                                                checkedItems.remove(item)
                                            } else {
                                                checkedItems.insert(item)
                                            }
                                        } label: {
                                            Image(systemName: checkedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                                .font(.title2)
                                                .foregroundStyle(checkedItems.contains(item) ? AppColors.ctaGreen : .secondary)
                                        }
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 32)
                                        Text(item)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding()
                            .background(AppColors.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                            
                            Button {
                                stopDrill()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.title2)
                                    Text("End Drill")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding()
                    } else {
                        // Completed
                        VStack(spacing: 20) {
                            Image(systemName: checkedItems.count == drillItems.count ? "checkmark.circle.fill" : "clock.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(checkedItems.count == drillItems.count ? AppColors.ctaGreen : .orange)
                            Text(checkedItems.count == drillItems.count ? "Drill Complete!" : "Time's Up")
                                .font(.title.weight(.bold))
                            Text("You checked \(checkedItems.count) of \(drillItems.count) items")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if checkedItems.count < drillItems.count {
                                Text("Practice gathering all items faster. In a real emergency, every second counts.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            Button {
                                resetDrill()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2)
                                    Text("Try Again")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.ctaGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Evacuation Drill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        stopDrill()
                        dismiss()
                    }
                }
            }
        }
    }

    private func startDrill() {
        isRunning = true
        timeRemaining = 120
        checkedItems = []
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopDrill()
            }
        }
    }

    private func stopDrill() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetDrill() {
        stopDrill()
        timeRemaining = 120
        checkedItems = []
    }

    private func timeString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
