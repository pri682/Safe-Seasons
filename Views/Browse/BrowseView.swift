//
//  BrowseView.swift
//  SafeSeasons
//
//  Browse tab: disaster categories, search, FAB.
//  ISP/DIP: depends only on BrowseViewModel.
//

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var viewModel: BrowseViewModel
    @State private var showBrowseInfo = false
    @State private var showQuickActionSheet = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.filteredCategories) { category in
                        Section {
                            ForEach(category.disasters) { disaster in
                                NavigationLink(destination: DisasterDetailView(disaster: disaster)) {
                                    BrowseDisasterRow(
                                        disaster: disaster,
                                        accentColor: categoryAccentColor(category.color)
                                    )
                                }
                                .listRowBackground(categoryColor(category.color).opacity(0.2))
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        } header: {
                            CategorySectionHeader(
                                icon: category.icon,
                                color: categoryAccentColor(category.color),
                                title: category.name
                            )
                        }
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .searchable(text: $viewModel.searchText, prompt: "Search hazards…")
                .navigationTitle("Browse")
                .navigationBarTitleDisplayMode(.large)
                .onAppear { viewModel.load() }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showBrowseInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(AppColors.ctaGreen)
                        }
                    }
                }
                .sheet(isPresented: $showBrowseInfo) {
                    BrowseInfoSheet(onDismiss: { showBrowseInfo = false })
                }
                .sheet(isPresented: $showQuickActionSheet) {
                    QuickActionSheet(onDismiss: { showQuickActionSheet = false })
                }

                Button {
                    showQuickActionSheet = true
                } label: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(AppColors.ctaGreen)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(24)
            }
        }
    }
}

struct BrowseInfoSheet: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Introduction
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Use Browse")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        Text("Explore disaster hazards organized by category. Each hazard includes detailed information, preparedness steps, essential supplies, and trusted sources.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 8)
                    
                    // Categories
                    VStack(spacing: 16) {
                        CategoryInfoCard(
                            icon: "cloud.bolt.rain.fill",
                            title: "Weather",
                            description: "Severe weather events that can cause widespread damage and disruption.",
                            hazards: ["Hurricanes", "Tornadoes", "Flooding", "Severe Thunderstorms"],
                            color: .blue
                        )
                        
                        CategoryInfoCard(
                            icon: "flame.fill",
                            title: "Fire & Heat",
                            description: "Wildfires and extreme heat conditions that pose serious risks to life and property.",
                            hazards: ["Wildfires", "Extreme Heat"],
                            color: .orange
                        )
                        
                        CategoryInfoCard(
                            icon: "snowflake",
                            title: "Winter",
                            description: "Cold weather hazards that can create dangerous conditions and power outages.",
                            hazards: ["Blizzards", "Ice Storms"],
                            color: .cyan
                        )
                        
                        CategoryInfoCard(
                            icon: "mountain.2.fill",
                            title: "Geological",
                            description: "Earth movements and ground instability that can occur with little or no warning.",
                            hazards: ["Earthquakes", "Landslides"],
                            color: .brown
                        )
                    }
                    
                    // How to use
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.mediumPurple)
                            Text("Getting Started")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 10) {
                                Text("1.")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppColors.mediumPurple)
                                Text("Tap any hazard name to view detailed information")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            
                            HStack(alignment: .top, spacing: 10) {
                                Text("2.")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppColors.mediumPurple)
                                Text("Review preparedness steps and required supplies")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            
                            HStack(alignment: .top, spacing: 10) {
                                Text("3.")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppColors.mediumPurple)
                                Text("Check trusted sources for the latest official guidance")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(16)
                        .background(AppColors.softPurple.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About Browse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryInfoCard: View {
    let icon: String
    let title: String
    let description: String
    let hazards: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(hazards, id: \.self) { hazard in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(color)
                        Text(hazard)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.leading, 52)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionSheet: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Emergency Services
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                                .font(.headline)
                                .foregroundStyle(.red)
                            Text("Emergency Services")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        EmergencyCallButton(
                            title: "Call 911",
                            subtitle: "Police, Fire, Medical Emergency",
                            phoneNumber: "911",
                            icon: "phone.fill",
                            color: .red
                        )
                    }
                    .padding()
                    .background(AppColors.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Disaster Resources
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.ctaGreen)
                            Text("Disaster Resources")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        EmergencyCallButton(
                            title: "FEMA Disaster Assistance",
                            subtitle: "1-800-621-3362",
                            phoneNumber: "18006213362",
                            icon: "building.2.fill",
                            color: AppColors.ctaGreen
                        )
                        
                        EmergencyCallButton(
                            title: "American Red Cross",
                            subtitle: "1-800-733-2767",
                            phoneNumber: "18007332767",
                            icon: "cross.case.fill",
                            color: .red
                        )
                        
                        EmergencyCallButton(
                            title: "Poison Control",
                            subtitle: "1-800-222-1222 • Chemical hazards, contaminated water",
                            phoneNumber: "18002221222",
                            icon: "exclamationmark.triangle.fill",
                            color: AppColors.vibrantOrange
                        )
                    }
                    .padding()
                    .background(AppColors.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Additional Support
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.mediumBlue)
                            Text("Additional Support")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        EmergencyCallButton(
                            title: "988 Suicide & Crisis Lifeline",
                            subtitle: "Free, confidential 24/7 mental health support",
                            phoneNumber: "988",
                            icon: "heart.circle.fill",
                            color: AppColors.lightPurple
                        )
                    }
                    .padding()
                    .background(AppColors.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Sources & Credits
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.mediumBlue)
                            Text("Sources & Credits")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FEMA Disaster Assistance")
                                .font(.caption.weight(.medium))
                            Text("Source: Federal Emergency Management Agency (FEMA)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("American Red Cross")
                                .font(.caption.weight(.medium))
                            Text("Source: American Red Cross")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("Poison Control")
                                .font(.caption.weight(.medium))
                            Text("Source: American Association of Poison Control Centers")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("988 Suicide & Crisis Lifeline")
                                .font(.caption.weight(.medium))
                            Text("Source: Substance Abuse and Mental Health Services Administration (SAMHSA)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.paleBeige.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                    .background(AppColors.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Quick Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EmergencyCallButton: View {
    let title: String
    let subtitle: String
    let phoneNumber: String
    let icon: String
    let color: Color
    
    var body: some View {
        Link(destination: URL(string: "tel:\(phoneNumber)")!) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
    }
}

struct DisasterDetailView: View {
    let disaster: Disaster

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: disaster.icon)
                        .font(.title)
                        .foregroundStyle(AppColors.mediumPurple)
                        .frame(width: 56, height: 56)
                        .background(AppColors.softPurple.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(disaster.name)
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.caption)
                                .foregroundStyle(AppColors.vibrantOrange)
                            Text("Severity: \(disaster.severity.rawValue)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.bottom, 8)
                
                Text(disaster.description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .padding(.vertical, 4)
                
                if !disaster.additionalInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.mediumPurple)
                            Text("Additional Information")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        Text(disaster.additionalInfo)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                
                DisasterDetailSection(title: "Preparedness Steps", items: disaster.preparednessSteps, icon: "list.bullet.clipboard.fill")
                
                if !disaster.warningSigns.isEmpty {
                    DisasterDetailSection(title: "Warning Signs to Watch For", items: disaster.warningSigns, icon: "exclamationmark.triangle.fill")
                }
                
                DisasterDetailSection(title: "Supplies", items: disaster.supplies, icon: "bag.fill")
                
                if !disaster.duringEvent.isEmpty {
                    DisasterDetailSection(title: "What to Do During the Event", items: disaster.duringEvent, icon: "shield.fill")
                }
                
                if !disaster.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.headline)
                                .foregroundStyle(AppColors.mediumBlue)
                            Text("Sources & Credits")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(disaster.sources) { source in
                                Link(destination: URL(string: source.url)!) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "link.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(AppColors.mediumPurple)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(source.name)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.primary)
                                            Text("Official source")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.mediumPurple.opacity(0.6))
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(disaster.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DisasterDetailSection: View {
    let title: String
    let items: [String]
    let icon: String

    init(title: String, items: [String], icon: String = "checkmark.circle.fill") {
        self.title = title
        self.items = items
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(AppColors.mediumPurple)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mediumPurple)
                            .padding(.top, 2)
                        Text(item)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    let c = DependencyContainer()
    return BrowseView()
        .environmentObject(c.browseViewModel)
        .environmentObject(c.homeViewModel)
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.mapViewModel)
        .environmentObject(c.alertsViewModel)
}
