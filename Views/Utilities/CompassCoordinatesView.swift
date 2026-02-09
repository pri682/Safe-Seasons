//
//  CompassCoordinatesView.swift
//  SafeSeasons
//
//  Offline compass and coordinates using CoreLocation.
//

import SwiftUI
import CoreLocation
import UIKit

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    /// Heading in degrees (from magnetic north). Avoids capturing non-Sendable CLHeading across isolation.
    @Published var headingDegrees: Double?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.activityType = .other
        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
    }

    func requestPermission() {
        // Defer to next run loop so the system permission dialog can appear (avoids no-op when triggered from a button tap).
        DispatchQueue.main.async { [weak self] in
            self?.manager.requestWhenInUseAuthorization()
        }
    }

    func startUpdates() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        authorizationStatus = status

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            requestPermission()
            return
        }
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.headingFilter = 3
            manager.startUpdatingHeading()
        }
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        Task { @MainActor [weak self] in
            self?.location = last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let degrees = newHeading.magneticHeading
        Task { @MainActor [weak self] in
            self?.headingDegrees = degrees
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startUpdates()
            }
        }
    }
}

struct CompassCoordinatesView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Compass
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    // Cardinal directions
                    ForEach(["N", "E", "S", "W"], id: \.self) { dir in
                        Text(dir)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .offset(y: -90)
                            .rotationEffect(.degrees(rotationForDirection(dir)))
                    }
                    
                    // Needle
                    if let degrees = locationManager.headingDegrees {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(-degrees))
                    } else {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                    }
                }
                .padding()

                // Coordinates
                VStack(spacing: 16) {
                    if let location = locationManager.location {
                        VStack(spacing: 8) {
                            Text("Latitude")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.6f", location.coordinate.latitude))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.softBlue.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(spacing: 8) {
                            Text("Longitude")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.6f", location.coordinate.longitude))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.softBlue.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 16) {
                            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(AppColors.mediumBlue)
                                Text("Acquiring location…")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: "location.slash")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("Location unavailable")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text("Enable location to see coordinates and use the compass.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    if locationManager.authorizationStatus == .notDetermined {
                                        Button {
                                            locationManager.requestPermission()
                                        } label: {
                                            Text("Enable Location")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 12)
                                                .background(AppColors.ctaGreen)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        Text("If no prompt appears, use Open Settings below.")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                    if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .notDetermined {
                                        Button {
                                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(url)
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "gear")
                                                Text("Open Settings")
                                                    .font(.headline)
                                            }
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(AppColors.mediumPurple)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Compass & Coordinates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                locationManager.startUpdates()
            }
            .onDisappear {
                locationManager.stopUpdates()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                locationManager.startUpdates()
            }
        }
    }

    private func rotationForDirection(_ dir: String) -> Double {
        switch dir {
        case "N": return 0
        case "E": return 90
        case "S": return 180
        case "W": return 270
        default: return 0
        }
    }
}
