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
                VStack(alignment: .leading, spacing: 20) {
                    Text("Browse hazards by category—Weather (hurricanes, tornadoes, floods), Fire & Heat (wildfires, extreme heat), Winter (blizzards, ice storms), and Geological (earthquakes, landslides). Tap any item for preparedness steps and supplies.")
                        .font(.body)
                        .foregroundStyle(.secondary)
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

struct QuickActionSheet: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    Link(destination: URL(string: "tel:911")!) {
                        HStack(spacing: 14) {
                            Image(systemName: "phone.fill")
                                .font(.title3)
                                .foregroundStyle(AppColors.ctaGreen)
                                .frame(width: 40, height: 40)
                                .background(AppColors.ctaGreen.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Call 911")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Emergency services")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Emergency")
                }
            }
            .listStyle(.insetGrouped)
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

struct DisasterDetailView: View {
    let disaster: Disaster

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 14) {
                    Image(systemName: disaster.icon)
                        .font(.title)
                        .foregroundStyle(AppColors.ctaGreen)
                        .frame(width: 48, height: 48)
                        .background(AppColors.softGreen.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Text(disaster.name)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                }
                Text(disaster.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                DisasterDetailSection(title: "Preparedness Steps", items: disaster.preparednessSteps)
                DisasterDetailSection(title: "Supplies", items: disaster.supplies)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.ctaGreen)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
