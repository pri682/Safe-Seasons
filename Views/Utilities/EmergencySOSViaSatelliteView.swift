//
//  EmergencySOSViaSatelliteView.swift
//  SafeSeasons
//
//  In-app guide for Emergency SOS via satellite (iPhone 14+).
//  Content based on Apple Support; full guide link at bottom.
//

import SwiftUI

struct EmergencySOSViaSatelliteView: View {
    @Environment(\.dismiss) private var dismiss

    /// Apple support guide (full instructions, demo link).
    private static let appleSupportURL = URL(string: "https://support.apple.com/en-us/guide/iphone/use-emergency-sos-via-satellite-iph2968440de/ios")!

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    introSection
                    howItWorksSection
                    beforeYouGoSection
                    textEmergencyServicesSection
                    otherWaysSection
                    availabilitySection
                    openFullGuideButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Emergency SOS via satellite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("iPhone 14 or later", systemImage: "antenna.radiowaves.left.and.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.mediumPurple)
            Text("With iPhone 14 or later (all models), you can use Emergency SOS via satellite to text emergency services when you're off the grid — somewhere with no cellular and Wi‑Fi coverage.")
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.softPurple.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var howItWorksSection: some View {
        sectionCard(
            title: "How it works",
            icon: "info.circle.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Emergency SOS via satellite can help you connect with public emergency services when no other means are available.")
                Text("If you try to call or text emergency services but can't connect because you're off the grid, your iPhone can try to connect you via satellite.")
                Text("You need to be outside with a clear view of the sky and horizon. The experience is different than sending a message via cellular.")
                Text("The feature is free for two years after activation of an iPhone 14 or later. Crash Detection and Fall Detection can also use Emergency SOS via satellite if you're outside cellular and Wi‑Fi coverage.")
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }

    private var beforeYouGoSection: some View {
        sectionCard(
            title: "Before you go off the grid",
            icon: "checklist"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Try the Satellite Connection demo")
                    .font(.subheadline.weight(.semibold))
                Text("Use the demo in Settings to learn how Emergency SOS via satellite works and what to expect.")
                    .font(.subheadline)

                Text("Set up Medical ID and emergency contacts")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 8)
                Text("When you use Emergency SOS via satellite, you can share your Medical ID and notify emergency contacts. Set this up in the Health app before you go somewhere with no coverage.")
                    .font(.subheadline)
            }
            .foregroundStyle(.primary)
        }
    }

    private var textEmergencyServicesSection: some View {
        sectionCard(
            title: "Text emergency services via satellite",
            icon: "message.fill"
        ) {
            VStack(alignment: .leading, spacing: 10) {
                step(1, "First try calling the local emergency number (e.g. 911). Even without your normal carrier, the call might connect.")
                step(2, "If the call won't connect, tap **Emergency Text via Satellite** (or in Messages, text the emergency number and tap Emergency Services).")
                step(3, "Tap **Report Emergency**.")
                step(4, "Answer the emergency questions to describe your situation.")
                step(5, "Choose whether to notify your emergency contacts with your location and the nature of your emergency.")
                step(6, "Follow the on-screen instructions to connect to a satellite and stay connected while you send your message.")
                Text("Your iPhone shares critical information with responders: Medical ID, emergency contacts (if set up), your answers, location (including elevation), and remaining battery. You may get follow-up messages. Supported languages include English, Canadian French, Dutch, French, German, Italian, Japanese, Portuguese, and Spanish.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(AppColors.mediumPurple)
                .clipShape(Circle())
            Text(LocalizedStringKey(text))
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    private var otherWaysSection: some View {
        sectionCard(
            title: "Other ways to access",
            icon: "gearshape.fill"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("• **Control Center:** Swipe down from the top-right → tap Cellular → Satellite → Emergency SOS via satellite.")
                Text("• **Settings:** Open Settings → Satellite → Emergency SOS via satellite.")
                Text("If you have cellular or Wi‑Fi coverage, the Satellite option in Settings may not appear; Control Center may open the Satellite Connection Demo instead.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }

    private var availabilitySection: some View {
        sectionCard(
            title: "Availability",
            icon: "globe"
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("**What you need:** iPhone 14 or later and the required iOS version for your region (e.g. iOS 16.1+ in US/Canada).")
                Text("**Where it's available:** U.S., Canada, Mexico, Australia, Austria, Belgium, France, Germany, Ireland, Italy, Japan, Luxembourg, the Netherlands, New Zealand, Portugal, Spain, Switzerland, and the U.K. You must be in an area with no cellular and Wi‑Fi coverage.")
                Text("**Emergency numbers:** 911 (U.S., Canada, Mexico), 000 (Australia), 112/999 (UK/Ireland), and other local numbers depending on country. Check Apple Support for the full list.")
            }
            .font(.subheadline)
            .foregroundStyle(.primary)
        }
    }

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(AppColors.mediumPurple)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.mediumPurple.opacity(0.2), lineWidth: 1)
        )
    }

    private var openFullGuideButton: some View {
        Button {
            UIApplication.shared.open(EmergencySOSViaSatelliteView.appleSupportURL)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "safari")
                Text("Open full instructions on Apple Support")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(AppColors.mediumPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.softPurple.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }
}

#Preview {
    EmergencySOSViaSatelliteView()
}
