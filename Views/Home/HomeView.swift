//
//  HomeView.swift
//  SafeSeasons
//
//  Home tab: state selection, risk overview, quick actions.
//  ISP/DIP: depends only on HomeViewModel.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var tabSelection: TabSelectionHolder
    @State private var showStatePicker = false
    @State private var showAskSafeSeasons = false
    @State private var showDigitalBeacon = false
    @State private var showEvacuationDrill = false
    @State private var showCompassCoordinates = false
    @State private var showUtilityInfo: UtilityType? = nil
    @State private var pendingUtility: UtilityType? = nil
    @State private var showRiskOverviewInfo = false
    
    enum UtilityType: Identifiable {
        case digitalBeacon
        case evacuationDrill
        case compassCoordinates
        
        var id: String {
            switch self {
            case .digitalBeacon: return "digitalBeacon"
            case .evacuationDrill: return "evacuationDrill"
            case .compassCoordinates: return "compassCoordinates"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Row 1: Emergency CTA (full width)
                    emergencyCTACard
                    
                    // Row 1.5: Ask SafeSeasons Conversational UI (full width)
                    askSafeSeasonsConversationalCard
                    
                    // Row 2: State Selection + Risk Overview
                    HStack(spacing: 16) {
                        stateSelectionCard
                        riskOverviewCard
                    }
                    
                    // Row 3: Contextual Tips (full width if present)
                    if let state = viewModel.selectedState, !viewModel.contextualTips.isEmpty {
                        contextualTipsCard
                    }
                    
                    // Row 4: Utility Tools - Digital Beacon + Evacuation Drill
                    HStack(spacing: 16) {
                        digitalBeaconCard
                        evacuationDrillCard
                    }
                    
                    // Row 5: Compass & Coordinates + Checklist
                    HStack(spacing: 16) {
                        compassCoordinatesCard
                        checklistCard
                    }
                    
                    // Row 6: Map + Ask SafeSeasons
                    HStack(spacing: 16) {
                        mapCard
                        askSafeSeasonsCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SafeSeasons")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { viewModel.load() }
            .sheet(isPresented: $showStatePicker) {
                StatePickerSheet(selectedState: viewModel.selectedState, states: viewModel.states) { state in
                    viewModel.setCurrentState(state)
                    showStatePicker = false
                }
            }
            .sheet(isPresented: $showAskSafeSeasons) {
                AskSafeSeasonsSheet(
                    viewModel: viewModel,
                    onDismiss: {
                        viewModel.clearAskState()
                        showAskSafeSeasons = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showDigitalBeacon) {
                DigitalBeaconView()
            }
            .fullScreenCover(isPresented: $showEvacuationDrill) {
                EvacuationDrillView()
            }
            .fullScreenCover(isPresented: $showCompassCoordinates) {
                CompassCoordinatesView()
            }
            .sheet(item: $showUtilityInfo) { utilityType in
                UtilityInfoSheet(utilityType: utilityType) {
                    pendingUtility = utilityType
                    showUtilityInfo = nil
                }
            }
            .onChange(of: showUtilityInfo) { newValue in
                // When info sheet dismisses, open the utility if pending
                if newValue == nil, let pending = pendingUtility {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switch pending {
                        case .digitalBeacon:
                            showDigitalBeacon = true
                        case .evacuationDrill:
                            showEvacuationDrill = true
                        case .compassCoordinates:
                            showCompassCoordinates = true
                        }
                        pendingUtility = nil
                    }
                }
            }
            .sheet(isPresented: $showRiskOverviewInfo) {
                RiskOverviewInfoSheet(state: viewModel.selectedState)
            }
        }
    }

    // MARK: - Bento Grid Cards
    
    private var emergencyCTACard: some View {
        Button {
            if let url = URL(string: "tel:911") {
                UIApplication.shared.open(url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                Text("Emergency?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Call 911 immediately")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .red.opacity(0.3), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var stateSelectionCard: some View {
        Button {
            showStatePicker = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(AppColors.mediumBlue)
                Text("Your State")
                    .font(.caption)
                    .foregroundStyle(AppColors.darkNavy.opacity(0.6))
                Text(viewModel.selectedState?.name ?? "Select")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColors.darkNavy)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [AppColors.skyBlue.opacity(0.4), AppColors.oceanBlue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppColors.mediumBlue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: AppColors.darkNavy.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var riskOverviewCard: some View {
        Button {
            showRiskOverviewInfo = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if let state = viewModel.selectedState {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(state.riskLevel.accentColor)
                            .frame(width: 12, height: 12)
                        Text(state.riskLevel.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                    }
                    Text("\(state.topHazards.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.darkNavy)
                    Text("Top Hazards")
                        .font(.caption)
                        .foregroundStyle(AppColors.darkNavy.opacity(0.6))
                } else {
                    Text("Select state")
                        .font(.caption)
                        .foregroundStyle(AppColors.darkNavy.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [AppColors.purpleGrey.opacity(0.3), AppColors.darkPurpleGrey.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppColors.purpleGrey.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: AppColors.darkNavy.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var contextualTipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: warningIcon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(warningColor)
                if let state = viewModel.selectedState {
                    Text("This month in \(state.name)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
            
            if viewModel.hasActiveDisasters {
                Text(viewModel.activeDisasterSummary)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(warningColor)
                    .lineLimit(2)
                if let alert = viewModel.primaryActiveAlert {
                    Text(alert.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else if !viewModel.activeSeasonalRisks.isEmpty {
                    Text("Seasonal risk period")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("\(viewModel.contextualTips.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Preparedness Tips")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(warningBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(warningColor.opacity(0.3), lineWidth: viewModel.hasActiveDisasters ? 1.5 : 0)
        )
    }
    
    private var warningIcon: String {
        if let alert = viewModel.primaryActiveAlert {
            switch alert.severity {
            case .extreme: return "exclamationmark.triangle.fill"
            case .severe: return "exclamationmark.circle.fill"
            case .moderate: return "info.circle.fill"
            case .minor, .unknown: return "bell.fill"
            }
        } else if viewModel.hasActiveDisasters {
            return "exclamationmark.triangle.fill"
        }
        return "sparkles"
    }
    
    private var warningColor: Color {
        if let alert = viewModel.primaryActiveAlert {
            switch alert.severity {
            case .extreme: return .red
            case .severe: return .orange
            case .moderate: return .yellow
            case .minor: return .blue
            case .unknown: return .gray
            }
        } else if viewModel.hasActiveDisasters {
            return .orange
        }
        return AppColors.ctaGreen
    }
    
    private var warningBackgroundColor: Color {
        if viewModel.hasActiveDisasters {
            return warningColor.opacity(0.1)
        }
        // Use sky blue gradient when no warnings (matching the landscape aesthetic)
        return AppColors.skyBlue.opacity(0.4)
    }
    
    private var askSafeSeasonsConversationalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with gradient background (dark navy to medium blue)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.paleBeige)
                    Text("Ask SafeSeasons")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppColors.paleBeige)
                    Spacer()
                    if !viewModel.chatMessages.isEmpty {
                        Button {
                            viewModel.clearChatHistory()
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(AppColors.paleBeige.opacity(0.8))
                        }
                    }
                }
                
                // State context hint
                if let state = viewModel.selectedState {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColors.paleBeige.opacity(0.9))
                        Text("Ask about preparedness in \(state.name)")
                            .font(.caption)
                            .foregroundStyle(AppColors.paleBeige.opacity(0.8))
                    }
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [AppColors.darkNavy, AppColors.mediumBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            Divider()
                .background(AppColors.oceanBlue.opacity(0.3))
            
            // Chat messages area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if viewModel.chatMessages.isEmpty {
                            // Welcome message with state-specific suggestions
                            VStack(alignment: .leading, spacing: 24) {
                                if let state = viewModel.selectedState {
                                    // Welcome text
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Hi! I can help you prepare for disasters in \(state.name).")
                                            .font(.body)
                                            .foregroundStyle(AppColors.darkNavy.opacity(0.9))
                                            .lineSpacing(6)
                                        
                                        if viewModel.hasActiveDisasters {
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(warningColor)
                                                    Text("Active warnings for this month:")
                                                        .font(.subheadline.weight(.semibold))
                                                        .foregroundStyle(AppColors.darkNavy.opacity(0.9))
                                                }
                                                .padding(.bottom, 4)
                                                
                                                if let alert = viewModel.primaryActiveAlert {
                                                    HStack(spacing: 8) {
                                                        Circle()
                                                            .fill(warningColor)
                                                            .frame(width: 8, height: 8)
                                                        Text(alert.title)
                                                            .font(.subheadline)
                                                            .foregroundStyle(warningColor)
                                                    }
                                                }
                                                if !viewModel.activeSeasonalRisks.isEmpty {
                                                    ForEach(viewModel.activeSeasonalRisks.prefix(3), id: \.self) { risk in
                                                        HStack(spacing: 8) {
                                                            Circle()
                                                                .fill(Color.orange)
                                                                .frame(width: 8, height: 8)
                                                            Text("\(risk) risk")
                                                                .font(.subheadline)
                                                                .foregroundStyle(Color.orange)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 14)
                                            .padding(.horizontal, 16)
                                            .background(warningColor.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(warningColor.opacity(0.2), lineWidth: 1)
                                            )
                                        }
                                    }
                                    
                                    // Suggested questions
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text("Try asking:")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(suggestedQuestions(for: state), id: \.self) { question in
                                                Button {
                                                    questionInput = question
                                                    sendMessage()
                                                } label: {
                                                    HStack(spacing: 12) {
                                                        Text(question)
                                                            .font(.subheadline)
                                                            .foregroundStyle(AppColors.mediumBlue)
                                                            .multilineTextAlignment(.leading)
                                                            .lineLimit(2)
                                                        Spacer(minLength: 8)
                                                        Image(systemName: "arrow.right.circle.fill")
                                                            .font(.subheadline)
                                                            .foregroundStyle(AppColors.mediumBlue.opacity(0.7))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        LinearGradient(
                                                            colors: [AppColors.purpleGrey.opacity(0.12), AppColors.skyBlue.opacity(0.15)],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(AppColors.purpleGrey.opacity(0.3), lineWidth: 1)
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)
                        } else {
                            ForEach(viewModel.chatMessages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                                    .padding(.horizontal, 24)
                            }
                            
                            // Show streaming response if in progress
                            if viewModel.isStreaming && !viewModel.streamingResponse.isEmpty {
                                ChatBubble(message: ChatMessage(content: viewModel.streamingResponse, isUser: false, usedAppleIntelligence: viewModel.lastUsedAppleIntelligence))
                                    .padding(.horizontal, 24)
                                    .id("streaming")
                            }
                            
                            // Show loading indicator
                            if viewModel.isAsking || viewModel.isStreaming {
                                HStack(spacing: 10) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(AppColors.mediumBlue)
                                    Text(viewModel.isStreaming ? "Generating…" : "Thinking…")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.vertical, 24)
                }
                .frame(maxHeight: 360)
                .background(AppColors.cardBg)
                .onChange(of: viewModel.chatMessages.count) { _ in
                    if let last = viewModel.chatMessages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.streamingResponse) { _ in
                    if viewModel.isStreaming {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("streaming", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input field with purple-grey background
            VStack(spacing: 0) {
                Divider()
                    .background(AppColors.oceanBlue.opacity(0.3))
                HStack(spacing: 14) {
                    TextField("Ask a question...", text: $questionInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(AppColors.paleBeige.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .lineLimit(1...3)
                        .focused($isChatFieldFocused)
                        .foregroundStyle(AppColors.darkNavy)
                        .onSubmit {
                            sendMessage()
                        }
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(questionInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAsking ? AppColors.darkNavy.opacity(0.3) : AppColors.mediumBlue)
                    }
                    .disabled(questionInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAsking || viewModel.isStreaming)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppColors.purpleGrey.opacity(0.18), AppColors.darkPurpleGrey.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .background(AppColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.mediumBlue.opacity(0.4), AppColors.purpleGrey.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: AppColors.darkNavy.opacity(0.12), radius: 16, x: 0, y: 4)
    }
    
    @State private var questionInput = ""
    @FocusState private var isChatFieldFocused: Bool
    
    private func sendMessage() {
        let question = questionInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !viewModel.isAsking, !viewModel.isStreaming else { return }
        viewModel.ask(question: question)
        questionInput = ""
        isChatFieldFocused = false
    }
    
    private func suggestedQuestions(for state: StateRisk) -> [String] {
        var questions: [String] = []
        
        // State-specific questions based on top hazards
        if state.topHazards.contains(where: { $0.contains("Tornado") }) {
            questions.append("What should I do during a tornado?")
        }
        if state.topHazards.contains(where: { $0.contains("Hurricane") }) {
            questions.append("How do I prepare for a hurricane?")
        }
        if state.topHazards.contains(where: { $0.contains("Wildfire") }) {
            questions.append("What should I know about wildfires?")
        }
        if state.topHazards.contains(where: { $0.contains("Flood") }) {
            questions.append("How do I stay safe during flooding?")
        }
        if state.topHazards.contains(where: { $0.contains("Earthquake") }) {
            questions.append("What should I do during an earthquake?")
        }
        
        // Generic fallback
        if questions.isEmpty {
            questions.append("What disasters are common in \(state.name)?")
            questions.append("How can I prepare for emergencies?")
        }
        
        return Array(questions.prefix(3))
    }

    private var digitalBeaconCard: some View {
        Button {
            showUtilityInfo = .digitalBeacon
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "flashlight.on.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                Text("Digital Beacon")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("SOS flashlight")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var evacuationDrillCard: some View {
        Button {
            showUtilityInfo = .evacuationDrill
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.title)
                    .foregroundStyle(AppColors.ctaGreen)
                Text("Evacuation Drill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("2-minute practice")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var compassCoordinatesCard: some View {
        Button {
            showUtilityInfo = .compassCoordinates
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "location.north.circle.fill")
                    .font(.title)
                    .foregroundStyle(.blue)
                Text("Compass & Coordinates")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Your location")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var checklistCard: some View {
        Button {
            tabSelection.selectedTab = 2
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "checklist")
                    .font(.title)
                    .foregroundStyle(.green)
                Text("My Checklist")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Preparedness items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var mapCard: some View {
        Button {
            tabSelection.selectedTab = 3
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.title)
                    .foregroundStyle(.blue)
                Text("Emergency Map")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Find help nearby")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var askSafeSeasonsCard: some View {
        Button {
            showAskSafeSeasons = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title)
                    .foregroundStyle(AppColors.ctaGreen)
                Text("Ask SafeSeasons")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Get answers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(AppColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Utility Info Sheet
struct UtilityInfoSheet: View {
    let utilityType: HomeView.UtilityType
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: iconName)
                            .font(.system(size: 64))
                            .foregroundStyle(iconColor)
                            .frame(width: 100, height: 100)
                            .background(iconColor.opacity(0.15))
                            .clipShape(Circle())
                        
                        Text(title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(AppColors.darkNavy)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // What it does
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What it does")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColors.darkNavy)
                        Text(whatItDoes)
                            .font(.body)
                            .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                            .lineSpacing(6)
                    }
                    .padding()
                    .background(AppColors.skyBlue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Why it's helpful
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why it's helpful")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColors.darkNavy)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(whyHelpful, id: \.self) { reason in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.mediumBlue)
                                    Text(reason)
                                        .font(.body)
                                        .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.purpleGrey.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // When to use
                    if let whenToUse = whenToUse {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When to use")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            Text(whenToUse)
                                .font(.body)
                                .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(AppColors.terracotta.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Continue Button
                    Button {
                        dismiss()
                        onContinue()
                    } label: {
                        HStack {
                            Text("Continue to \(title)")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppColors.darkNavy, AppColors.mediumBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(AppColors.cardBg)
            .navigationTitle("Utility Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var iconName: String {
        switch utilityType {
        case .digitalBeacon: return "flashlight.on.fill"
        case .evacuationDrill: return "figure.run"
        case .compassCoordinates: return "location.north.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch utilityType {
        case .digitalBeacon: return .yellow
        case .evacuationDrill: return AppColors.mediumBlue
        case .compassCoordinates: return .blue
        }
    }
    
    private var title: String {
        switch utilityType {
        case .digitalBeacon: return "Digital Beacon"
        case .evacuationDrill: return "Evacuation Drill"
        case .compassCoordinates: return "Compass & Coordinates"
        }
    }
    
    private var whatItDoes: String {
        switch utilityType {
        case .digitalBeacon:
            return "Turns your device's flashlight into an SOS beacon that flashes in Morse code. The pattern (three short, three long, three short) is the universal distress signal recognized worldwide."
        case .evacuationDrill:
            return "A timed 2-minute practice drill that helps you prepare for real emergencies. You'll practice gathering essential items (keys, wallet, medications) while racing against the clock."
        case .compassCoordinates:
            return "Shows your current location using GPS coordinates (latitude and longitude) and a compass heading. This information works completely offline and doesn't require cell service."
        }
    }
    
    private var whyHelpful: [String] {
        switch utilityType {
        case .digitalBeacon:
            return [
                "Visible from great distances, especially at night or in low-light conditions",
                "Works even when your phone has no cell service or internet connection",
                "The SOS pattern is internationally recognized by search and rescue teams",
                "Can help rescuers locate you when you're lost, stranded, or in danger",
                "Uses minimal battery compared to keeping your screen on",
                "Can be seen from aircraft, boats, or ground search parties"
            ]
        case .evacuationDrill:
            return [
                "Builds muscle memory so you react quickly in real emergencies",
                "Helps you identify what items you actually need vs. what you can leave behind",
                "Reveals gaps in your preparedness (missing items, unclear plans)",
                "Reduces panic by making emergency procedures familiar",
                "Improves your evacuation time with practice",
                "Helps family members know exactly what to grab and where to go"
            ]
        case .compassCoordinates:
            return [
                "Share your exact location with rescuers via text or emergency services",
                "Navigate to safety using compass direction when GPS apps fail",
                "Works completely offline - no cell service or internet needed",
                "Critical for search and rescue teams to find you quickly",
                "Helps you communicate your location when landmarks aren't visible",
                "Useful for coordinating meetup points with family or emergency contacts"
            ]
        }
    }
    
    private var whenToUse: String? {
        switch utilityType {
        case .digitalBeacon:
            return "Use when you're lost, stranded, injured, or in immediate danger and need to signal for help. Best used at night or in low-visibility conditions. Make sure to conserve battery if you're in a remote area."
        case .evacuationDrill:
            return "Practice regularly (monthly is recommended) to keep your skills sharp. Especially important before hurricane season, wildfire season, or other predictable disaster periods in your area."
        case .compassCoordinates:
            return "Use whenever you need to know your exact location - during evacuations, when lost, when coordinating with rescue teams, or when sharing your location with family during emergencies."
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
            }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(message.isUser ? AppColors.paleBeige : AppColors.darkNavy)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser
                            ? LinearGradient(
                                colors: [AppColors.terracotta, AppColors.terracotta.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [AppColors.skyBlue.opacity(0.5), AppColors.oceanBlue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                message.isUser
                                    ? AppColors.terracotta.opacity(0.3)
                                    : AppColors.mediumBlue.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                if !message.isUser {
                    VStack(alignment: .leading, spacing: 4) {
                        if message.usedAppleIntelligence {
                            HStack(spacing: 4) {
                                Image(systemName: "apple.logo")
                                    .font(.caption2)
                                Text("Apple Intelligence")
                                    .font(.caption2)
                            }
                            .foregroundStyle(AppColors.darkNavy.opacity(0.5))
                        }
                        
                        // Attribution for preparedness guidance
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
                    }
                    .padding(.leading, 4)
                }
            }
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

// MARK: - Risk Overview Info Sheet
struct RiskOverviewInfoSheet: View {
    let state: StateRisk?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(state?.riskLevel.accentColor ?? AppColors.mediumBlue)
                            .frame(width: 100, height: 100)
                            .background((state?.riskLevel.accentColor ?? AppColors.mediumBlue).opacity(0.15))
                            .clipShape(Circle())
                        
                        Text("Risk Overview")
                            .font(.title.weight(.bold))
                            .foregroundStyle(AppColors.darkNavy)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    if let state = state {
                        // What it means
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What this means")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            Text("This card shows your state's overall disaster risk level and the number of primary hazards you should be prepared for. The risk level is based on the frequency and severity of disasters that commonly affect \(state.name).")
                                .font(.body)
                                .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(AppColors.skyBlue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Risk Level Explanation
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Risk Level: \(state.riskLevel.rawValue)")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(state.riskLevel.accentColor)
                                    .frame(width: 16, height: 16)
                                Text(riskLevelExplanation(state.riskLevel))
                                    .font(.body)
                                    .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                    .lineSpacing(4)
                            }
                        }
                        .padding()
                        .background(state.riskLevel.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Top Hazards List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Hazards for \(state.name)")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            Text("These are the \(state.topHazards.count) most common disaster types in your state:")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                                .padding(.bottom, 4)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(state.topHazards, id: \.self) { hazard in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .foregroundStyle(AppColors.mediumBlue)
                                            .padding(.top, 6)
                                        Text(hazard)
                                            .font(.body)
                                            .foregroundStyle(AppColors.darkNavy.opacity(0.9))
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.purpleGrey.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Why it's helpful
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Why this is helpful")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(whyHelpful, id: \.self) { reason in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColors.mediumBlue)
                                        Text(reason)
                                            .font(.body)
                                            .foregroundStyle(AppColors.darkNavy.opacity(0.8))
                                            .lineSpacing(4)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.terracotta.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Text("Please select a state to see risk information.")
                            .font(.body)
                            .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .background(AppColors.cardBg)
            .navigationTitle("Risk Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func riskLevelExplanation(_ level: RiskLevel) -> String {
        switch level {
        case .low:
            return "Low risk means fewer and less severe disasters occur. Still important to be prepared, but emergencies are less frequent."
        case .moderate:
            return "Moderate risk indicates occasional disasters that require preparedness. Stay informed and have basic emergency supplies ready."
        case .high:
            return "High risk means frequent and potentially severe disasters. Active preparedness is essential. Review your emergency plans regularly."
        case .veryHigh:
            return "Very High risk indicates frequent, severe disasters. Maximum preparedness is critical. Have comprehensive emergency plans and supplies ready at all times."
        }
    }
    
    private var whyHelpful: [String] {
        [
            "Helps you prioritize which disasters to prepare for first",
            "Gives you a quick overview of your state's disaster profile",
            "Helps you understand the urgency level of your preparedness efforts",
            "Guides you to focus on the most relevant hazards in your area",
            "Useful for planning evacuation routes and emergency supplies",
            "Helps you know when to be extra vigilant (e.g., during high-risk seasons)"
        ]
    }
}

struct AskSafeSeasonsSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    let onDismiss: () -> Void
    @State private var questionText = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with gradient
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.paleBeige)
                        Text("Ask SafeSeasons")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.paleBeige)
                    }
                    if let state = viewModel.selectedState {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                                .foregroundStyle(AppColors.paleBeige.opacity(0.9))
                            Text("Preparedness guidance for \(state.name)")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.paleBeige.opacity(0.85))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [AppColors.darkNavy, AppColors.mediumBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ask a preparedness question")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.darkNavy)
                            Text("Examples: \"What should I do during a tornado?\" or \"How do I prepare for a hurricane?\"")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(AppColors.skyBlue.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 20)
                        
                        // Input field
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                TextField("Your question…", text: $questionText, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(AppColors.paleBeige.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .lineLimit(2...6)
                                    .focused($isFieldFocused)
                                    .foregroundStyle(AppColors.darkNavy)
                                Button {
                                    isFieldFocused = false
                                    viewModel.ask(question: questionText)
                                    questionText = ""
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAsking ? AppColors.darkNavy.opacity(0.3) : AppColors.mediumBlue)
                                }
                                .disabled(questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAsking)
                            }
                            
                            if viewModel.isAsking {
                                HStack(spacing: 10) {
                                    ProgressView()
                                        .tint(AppColors.mediumBlue)
                                    Text("Thinking…")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.darkNavy.opacity(0.7))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                            }
                            
                            if let err = viewModel.askError {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                    Text(err)
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Response
                        if !viewModel.askResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.mediumBlue)
                                    Text("Response")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(AppColors.darkNavy)
                                }
                                
                                Text(viewModel.askResponse)
                                    .font(.body)
                                    .foregroundStyle(AppColors.darkNavy.opacity(0.9))
                                    .lineSpacing(6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if viewModel.lastUsedAppleIntelligence {
                                    HStack(spacing: 4) {
                                        Image(systemName: "apple.logo")
                                            .font(.caption2)
                                        Text("Apple Intelligence")
                                            .font(.caption2)
                                    }
                                    .foregroundStyle(AppColors.darkNavy.opacity(0.5))
                                    .padding(.top, 6)
                                }
                                
                                // Attribution for preparedness guidance
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
                                .padding(.top, 4)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.skyBlue.opacity(0.4), AppColors.oceanBlue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppColors.mediumBlue.opacity(0.3), lineWidth: 1.5)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(AppColors.cardBg)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onDismiss()
                        dismiss()
                    } label: {
                        Text("Done")
                            .foregroundStyle(AppColors.paleBeige)
                    }
                }
            }
        }
        .onAppear { viewModel.clearAskState() }
    }
}

struct EmergencyGuideSheet: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What to do in an emergency")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    VStack(alignment: .leading, spacing: 12) {
                        bullet("Call 911 for life-threatening emergencies.")
                        bullet("Stay calm. Follow official alerts (WEA, NOAA Radio, local news).")
                        bullet("Evacuate if told to. Know your routes and meetup points.")
                        bullet("Have water, food, first aid, flashlight, and documents ready.")
                        bullet("Check on neighbors, especially older or vulnerable people.")
                    }
                    .padding()
                    .background(AppColors.softYellow.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Use the Browse tab for hazard-specific steps and the Map for hospitals, fire stations, and shelters near you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Emergency Guide")
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

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(AppColors.ctaGreen)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatePickerSheet: View {
    let selectedState: StateRisk?
    let states: [StateRisk]
    let onSelect: (StateRisk) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(states) { state in
                Button {
                    onSelect(state)
                    dismiss()
                } label: {
                    HStack {
                        Text(state.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedState?.id == state.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.ctaGreen)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let c = DependencyContainer()
    return HomeView()
        .environmentObject(c.homeViewModel)
        .environmentObject(c.browseViewModel)
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.mapViewModel)
        .environmentObject(c.alertsViewModel)
        .environmentObject(TabSelectionHolder())
}
