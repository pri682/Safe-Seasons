//
//  AlertsView.swift
//  SafeSeasons
//
//  Alerts tab: WEA verification, weather alerts, seasonal reminders, WEA education.
//  ISP/DIP: depends only on AlertsViewModel.
//
//  Weather Alerts Attribution:
//  - Alert templates use NWS-style formatting and terminology
//  - Based on National Weather Service standards (weather.gov)
//  - Safety guidance and preparedness recommendations from:
//    • Federal Emergency Management Agency (FEMA) - ready.gov
//    • National Weather Service (NWS) - weather.gov/safety
//  - These are preloaded seasonal templates, not real-time NWS data
//

import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var viewModel: AlertsViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    weaCTABanner
                    SectionHeaderView(title: "WEA Verification")
                    weaVerificationCard
                    if !viewModel.weatherAlerts.isEmpty {
                        SectionHeaderView(title: "Weather Alerts")
                        weatherAlertsSection
                    }
                    SectionHeaderView(title: "Seasonal Reminders")
                    seasonalRemindersSection
                    SectionHeaderView(title: "WEA Education")
                    weaEducationCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Alerts")
            .onAppear { viewModel.load() }
        }
    }

    private var weaCTABanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(AppColors.ctaGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verify Your WEA Settings")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Ensure you receive emergency alerts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            if viewModel.isWEAVerified {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppColors.ctaGreen)
                    Text("WEA verified")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.ctaGreen)
                }
            }
        }
        .padding()
        .background(AppColors.ctaGreen.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.ctaGreen.opacity(0.25), lineWidth: 1)
        )
    }

    private var weaVerificationCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(viewModel.verificationSteps) { step in
                WEAVerificationRow(
                    step: step,
                    onToggle: { viewModel.toggleStepCompletion(step.id) }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var weatherAlertsSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.weatherAlerts) { alert in
                WeatherAlertCard(alert: alert)
            }
        }
    }

    private var seasonalRemindersSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.seasonalReminders) { r in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "leaf.fill")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.ctaGreen)
                        .frame(width: 32, alignment: .center)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(r.season)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(r.tip)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding()
                .background(AppColors.softYellow.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.softYellow.opacity(0.6), lineWidth: 1)
                )
            }
        }
    }

    private var weaEducationCard: some View {
        Group {
            if let edu = viewModel.education {
                NavigationLink(destination: WEAEducationDetailView(content: edu)) {
                    HStack(spacing: 14) {
                        Image(systemName: "book.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.ctaGreen)
                            .frame(width: 44, height: 44)
                            .background(AppColors.softBlue.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Learn about WEA")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("What is WEA, types of alerts, what to do")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(AppColors.softBlue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.softBlue.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct WEAVerificationRow: View {
    let step: WEAVerificationStep
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: step.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(step.isComplete ? AppColors.ctaGreen : .secondary)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(step.instructions)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct WeatherAlertCard: View {
    let alert: WeatherAlert

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: severityIcon)
                    .font(.title3)
                    .foregroundStyle(severityColor)
                    .frame(width: 32, height: 32)
                    .background(severityColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 6) {
                    Text(alert.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 8) {
                        Text(alert.area)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(alert.source)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            Text(alert.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(nil)
            
            // Attribution badge (similar to Apple Intelligence style)
            HStack(spacing: 4) {
                Image(systemName: "shield.checkered")
                    .font(.caption2)
                Text("Based on")
                    .font(.caption2)
                Link("FEMA", destination: URL(string: "https://ready.gov")!)
                    .font(.caption2)
                Text("&")
                    .font(.caption2)
                Link("NWS", destination: URL(string: "https://weather.gov/safety")!)
                    .font(.caption2)
            }
            .foregroundStyle(AppColors.darkNavy.opacity(0.5))
            .padding(.leading, 4)
            .padding(.top, 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(severityColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(severityColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    private var severityIcon: String {
        switch alert.severity {
        case .extreme: return "exclamationmark.triangle.fill"
        case .severe: return "exclamationmark.circle.fill"
        case .moderate: return "info.circle.fill"
        case .minor, .unknown: return "bell.fill"
        }
    }

    private var severityColor: Color {
        switch alert.severity {
        case .extreme: return .red
        case .severe: return .orange
        case .moderate: return .yellow
        case .minor: return .blue
        case .unknown: return .gray
        }
    }
}

struct WEAEducationDetailView: View {
    let content: WEAEducationContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                educationBlock(content.whatIsWEA.title, content.whatIsWEA.content)
                educationBlock(content.typesOfAlerts.title, content.typesOfAlerts.content)
                educationBlock(content.whatToDo.title, content.whatToDo.content)
                educationBlock(content.limitations.title, content.limitations.content)
                
                // WEA Official Website Link
                VStack(alignment: .leading, spacing: 12) {
                    Text("Official WEA Resources")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("For more information about Wireless Emergency Alerts, visit the official websites:")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                    VStack(alignment: .leading, spacing: 8) {
                        Link(destination: URL(string: "https://www.fcc.gov/wireless-emergency-alerts")!) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.subheadline)
                                Text("FCC: Wireless Emergency Alerts")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                            .foregroundStyle(AppColors.mediumBlue)
                        }
                        Link(destination: URL(string: "https://www.ready.gov/alerts")!) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.subheadline)
                                Text("FEMA: Emergency Alerts")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                            .foregroundStyle(AppColors.mediumBlue)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.skyBlue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.mediumBlue.opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("WEA Education")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func educationBlock(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(text.replacingOccurrences(of: "**", with: ""))
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    let c = DependencyContainer()
    return AlertsView()
        .environmentObject(c.alertsViewModel)
        .environmentObject(c.homeViewModel)
        .environmentObject(c.browseViewModel)
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.mapViewModel)
}
