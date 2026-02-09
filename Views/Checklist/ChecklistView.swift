//
//  ChecklistView.swift
//  SafeSeasons
//
//  Checklist tab: progress circle, checklist items. No photos.
//  ISP/DIP: depends only on ChecklistViewModel.
//

import SwiftUI
import UIKit

struct ChecklistView: View {
    @EnvironmentObject private var viewModel: ChecklistViewModel
    @State private var showNecessitiesInfo = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeaderView(title: "Preparedness Progress")
                    progressCard
                    categoryFilter
                    SectionHeaderView(title: "Checklist")
                    checklistList
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Checklist")
            .onAppear { viewModel.load() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNecessitiesInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(AppColors.ctaGreen)
                    }
                }
            }
            .sheet(isPresented: $showNecessitiesInfo) {
                NecessitiesInfoSheet(onDismiss: { showNecessitiesInfo = false })
            }
        }
    }

    private var progressCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                    .frame(width: 88, height: 88)
                Circle()
                    .trim(from: 0, to: viewModel.completionPercentage)
                    .stroke(
                        viewModel.completionPercentage >= 1 ? AppColors.ctaGreen : Color.orange,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 88, height: 88)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(viewModel.completionPercentage * 100))%")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("\(viewModel.items.filter(\.isCompleted).count) of \(viewModel.items.count) items done")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(viewModel.progressSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(AppColors.softGreen.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.softGreen.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(ChecklistItem.ChecklistCategory.allCases, id: \.self) { category in
                    categoryChip(title: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.mediumPurple : Color(.systemGray5))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var checklistList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.selectedCategory == nil {
                ForEach(viewModel.itemsGroupedByCategory, id: \.0.rawValue) { category, items in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(category.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        VStack(spacing: 12) {
                            ForEach(items) { item in
                                ChecklistRowView(
                                    item: item,
                                    onToggle: { viewModel.toggleCompletion(item.id) }
                                )
                            }
                        }
                    }
                }
            } else {
                ForEach(viewModel.displayedItems) { item in
                    ChecklistRowView(
                        item: item,
                        onToggle: { viewModel.toggleCompletion(item.id) }
                    )
                }
            }
        }
    }
}

struct ChecklistRowView: View {
    let item: ChecklistItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCompleted ? AppColors.ctaGreen : .secondary)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                HStack(spacing: 8) {
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(item.priority.rawValue)
                        .font(.caption2)
                        .foregroundStyle(item.priority.color)
                }
            }
            Spacer()
        }
        .padding()
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

struct NecessitiesInfoSheet: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What's most necessary in an absolute emergency?")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Prioritize these first. In a real crisis, you may only have minutes to grab essentials.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 16) {
                        necessitySection(title: "Critical (grab first)", items: [
                            "Water (1 gal/person/day, 3+ days)",
                            "Non-perishable food (3+ days)",
                            "Flashlight with extra batteries",
                            "First aid kit",
                            "Prescription medications (7-day supply)"
                        ], color: .red)
                        necessitySection(title: "High (next priority)", items: [
                            "Battery-powered or hand-crank radio",
                            "Important documents (IDs, insurance) in waterproof container",
                            "Cash in small denominations",
                            "Whistle to signal for help",
                            "Dust masks (N95)"
                        ], color: .orange)
                        necessitySection(title: "Medium & low", items: [
                            "Manual can opener, wrench for utilities, phone chargers, family contact list, pet supplies, blankets."
                        ], color: .secondary)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Emergency Necessities")
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

    private func necessitySection(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppColors.ctaGreen)
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let c = DependencyContainer()
    return ChecklistView()
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.homeViewModel)
        .environmentObject(c.browseViewModel)
        .environmentObject(c.mapViewModel)
        .environmentObject(c.alertsViewModel)
}
