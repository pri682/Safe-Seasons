//
//  Theme+Helpers.swift
//  SafeSeasons
//
//  Design system inspired by soft, approachable UIs: pastels, rounded cards, clear CTAs.
//

import SwiftUI
import UIKit

// MARK: - App Palette (inspired by minimalist landscape: dark navy, muted purples, terracotta accents)
enum AppColors {
    // Sky tones (light blue-grey)
    static let skyBlue = Color(hex: 0xB6C2D6) // Light desaturated blue-grey (#B6C2D6)
    static let mistGray = Color(hex: 0xE3E1D4) // Light beige/off-white (#E3E1D4)
    
    // Dark navy and medium blues (mountains/water)
    static let darkNavy = Color(hex: 0x283149) // Dark navy blue (#283149)
    static let mediumBlue = Color(hex: 0x637C9F) // Medium desaturated blue (#637C9F)
    static let oceanBlue = Color(hex: 0x8B95B1) // Medium blue-grey (#8B95B1)
    
    // Purple-grey tones (foreground layers)
    static let purpleGrey = Color(hex: 0x9887A8) // Muted purple-grey (#9887A8)
    static let darkPurpleGrey = Color(hex: 0xA692B4) // Darker purple-grey (#A692B4)
    static let softPurple = Color(hex: 0x9887A8) // Alias for compatibility
    
    // Warm accents (house/terracotta)
    static let terracotta = Color(hex: 0x993D3D) // Muted reddish-brown/terracotta (#993D3D)
    static let paleBeige = Color(hex: 0xE9DDDD) // Pale beige/pink (#E9DDDD)
    static let sandyBeige = Color(hex: 0xE3E1D4) // Light beige/off-white (same as mistGray)
    static let warmBrown = Color(hex: 0x993D3D) // Alias for terracotta
    
    // Accent colors for CTAs and highlights
    static let ctaGreen = Color(hex: 0x637C9F) // Using medium blue for CTAs
    static let softGreen = Color(hex: 0x8B95B1) // Using ocean blue for soft green
    static let softBlue = Color(hex: 0xB6C2D6) // Using sky blue
    
    // Neutrals
    static let cardBg = Color(hex: 0xE3E1D4) // Light beige/off-white
    static let darkGray = Color(hex: 0x283149) // Dark navy for text/UI
    
    // Legacy colors (mapped to new palette)
    static let mint = softGreen
    static let softPink = paleBeige
    static let softCyan = oceanBlue
    static let softYellow = paleBeige
    static let softOrange = terracotta
    static let softCoral = terracotta
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Card & Layout
struct SoftCardStyle: ViewModifier {
    var backgroundColor: Color = AppColors.cardBg
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct PastelCardStyle: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

extension View {
    func softCard(backgroundColor: Color = AppColors.cardBg, cornerRadius: CGFloat = 20) -> some View {
        modifier(SoftCardStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }

    func pastelCard(color: Color, cornerRadius: CGFloat = 20) -> some View {
        modifier(PastelCardStyle(color: color, cornerRadius: cornerRadius))
    }
}

// MARK: - Section Headers ("Explore Moods" style)
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.vertical, 4)
    }
}

// MARK: - CTA Banner (prominent call-to-action)
struct CTABannerView: View {
    let title: String
    let subtitle: String?
    let buttonTitle: String
    let accentColor: Color
    let icon: String
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        buttonTitle: String,
        accentColor: Color = AppColors.ctaGreen,
        icon: String = "phone.fill",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.accentColor = accentColor
        self.icon = icon
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(accentColor.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let s = subtitle {
                        Text(s)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            Button(action: action) {
                Text(buttonTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(accentColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Primary Button (rounded, prominent)
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = AppColors.ctaGreen

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

// MARK: - Risk Level Colors (softer variants)
extension RiskLevel {
    var color: Color {
        switch self {
        case .low: return AppColors.softGreen
        case .moderate: return AppColors.softYellow
        case .high: return AppColors.softOrange
        case .veryHigh: return AppColors.softCoral
        }
    }

    var accentColor: Color {
        switch self {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - Category Color (pastel + accent)
func categoryColor(_ name: String) -> Color {
    switch name.lowercased() {
    case "blue": return AppColors.softBlue
    case "orange": return AppColors.softOrange
    case "cyan": return AppColors.softCyan
    case "brown": return AppColors.softCoral
    default: return AppColors.softBlue
    }
}

func categoryAccentColor(_ name: String) -> Color {
    switch name.lowercased() {
    case "blue": return .blue
    case "orange": return .orange
    case "cyan": return .cyan
    case "brown": return .brown
    default: return .blue
    }
}

// MARK: - Priority Color
extension ChecklistItem.Priority {
    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
}

// MARK: - Resource Type
extension EmergencyResource.ResourceType {
    var icon: String {
        switch self {
        case .hospital: return "cross.case.fill"
        case .shelter: return "house.fill"
        case .fireStation: return "flame.fill"
        case .policeStation: return "shield.fill"
        }
    }
    var color: Color {
        switch self {
        case .hospital: return .red
        case .shelter: return .blue
        case .fireStation: return .orange
        case .policeStation: return .indigo
        }
    }
    var uiColor: UIColor {
        switch self {
        case .hospital: return .systemRed
        case .shelter: return .systemBlue
        case .fireStation: return .systemOrange
        case .policeStation: return .systemIndigo
        }
    }
}

// MARK: - Shared Browse UI
struct CategorySectionHeader: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
                .frame(width: 24, alignment: .center)
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct BrowseDisasterRow: View {
    let disaster: Disaster
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: disaster.icon)
                .font(.body)
                .foregroundStyle(accentColor)
                .frame(width: 28, alignment: .center)
            Text(disaster.name)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 6)
    }
}
