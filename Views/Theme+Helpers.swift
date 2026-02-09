//
//  Theme+Helpers.swift
//  SafeSeasons
//
//  Design system inspired by soft, approachable UIs: pastels, rounded cards, clear CTAs.
//

import SwiftUI
import UIKit

// MARK: - App Palette (inspired by travel app: purples, blues, orange/yellow accents)
enum AppColors {
    // Primary Purples (darker indigo to lavender)
    static let deepPurple = Color(hex: 0x3A2E58) // Dark indigo purple (#3A2E58)
    static let mediumPurple = Color(hex: 0x55457A) // Darker medium purple (#55457A)
    static let lightPurple = Color(hex: 0x6B5B95) // Purple (#6B5B95)
    static let softPurple = Color(hex: 0x8A7AB0) // Soft purple (#8A7AB0)
    
    // Primary Blues
    static let deepBlue = Color(hex: 0x2E4A7C) // Deep blue (#2E4A7C)
    static let mediumBlue = Color(hex: 0x5B7FA8) // Medium blue (#5B7FA8)
    static let lightBlue = Color(hex: 0x8BA5C4) // Light blue (#8BA5C4)
    static let skyBlue = Color(hex: 0xB8D0E8) // Sky blue (#B8D0E8)
    
    // Warm Accents (orange and yellow)
    static let vibrantOrange = Color(hex: 0xFF6B35) // Vibrant orange (#FF6B35)
    static let warmOrange = Color(hex: 0xFF8C5A) // Warm orange (#FF8C5A)
    static let softOrange = Color(hex: 0xFFB896) // Soft orange (#FFB896)
    static let vibrantYellow = Color(hex: 0xFFC947) // Vibrant yellow (#FFC947)
    static let warmYellow = Color(hex: 0xFFD966) // Warm yellow (#FFD966)
    
    // Neutrals (white/off-white/cream)
    static let cardBg = Color(hex: 0xF8F7F4) // Off-white/cream (#F8F7F4)
    static let mistGray = Color(hex: 0xF5F4F1) // Light cream (#F5F4F1)
    static let paleBeige = Color(hex: 0xFAF9F6) // Pale beige (#FAF9F6)
    
    // Text Colors
    static let darkNavy = Color(hex: 0x2C2C2C) // Dark gray for text (#2C2C2C)
    static let darkGray = Color(hex: 0x2C2C2C) // Alias for darkNavy
    static let mediumGray = Color(hex: 0x666666) // Medium gray (#666666)
    
    // Legacy/Compatibility (mapped to new palette)
    static let ctaGreen = mediumPurple // Using purple for CTAs (primary)
    static let ctaOrange = vibrantOrange // Orange for secondary CTAs
    static let ctaYellow = vibrantYellow // Yellow for highlights
    static let softGreen = lightBlue // Using light blue
    static let softBlue = skyBlue // Using sky blue
    static let oceanBlue = mediumBlue // Using medium blue
    static let purpleGrey = lightPurple // Using light purple
    static let darkPurpleGrey = mediumPurple // Using medium purple
    static let terracotta = warmOrange // Using warm orange
    static let sandyBeige = cardBg // Using cardBg
    static let warmBrown = warmOrange // Using warm orange
    static let mint = skyBlue // Using sky blue
    static let softPink = softPurple // Using soft purple
    static let softCyan = lightBlue // Using light blue
    static let softYellow = warmYellow // Using warm yellow
    static let softCoral = softOrange // Using soft orange
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
