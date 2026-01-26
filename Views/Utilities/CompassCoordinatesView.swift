//
//  CompassCoordinatesView.swift
//  SafeSeasons
//
//  Offline compass and coordinates using CoreLocation.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdates()
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
                    if let heading = locationManager.heading {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(-heading.magneticHeading))
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
                        VStack(spacing: 12) {
                            Image(systemName: "location.slash")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("Location unavailable")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            if locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .denied {
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
