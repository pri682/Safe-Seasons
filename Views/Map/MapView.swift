//
//  MapView.swift
//  SafeSeasons
//
//  Map tab: emergency resources map, legend. Embedded data only (no network).
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var viewModel: MapViewModel

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                MapViewRepresentable(resources: viewModel.filteredResources)
                mapLegend
            }
            .navigationTitle("Emergency Map")
            .onAppear { viewModel.load() }
        }
    }

    private var mapLegend: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Legend")
                .font(.headline)
                .foregroundStyle(.primary)
            ForEach(viewModel.allTypes, id: \.self) { type in
                LegendRow(
                    type: type,
                    isOn: viewModel.visibleTypes.contains(type),
                    toggle: { viewModel.toggleType(type) }
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        .padding()
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    let resources: [EmergencyResource]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = false
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Resource")
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let existing = map.annotations.compactMap { $0 as? ResourceAnnotation }
        let ids = Set(existing.map(\.resource.id))
        let toAdd = resources.filter { !ids.contains($0.id) }
        let toRemove = existing.filter { !resources.map(\.id).contains($0.resource.id) }
        map.removeAnnotations(toRemove)
        map.addAnnotations(toAdd.map { ResourceAnnotation(resource: $0) })
        if !resources.isEmpty {
            let coords = resources.map { CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            let lats = coords.map(\.latitude)
            let lons = coords.map(\.longitude)
            let center = CLLocationCoordinate2D(
                latitude: (lats.min()! + lats.max()!) / 2,
                longitude: (lons.min()! + lons.max()!) / 2
            )
            let span = max(
                max((lats.max()! - lats.min()!) * 1.5, 0.05),
                max((lons.max()! - lons.min()!) * 1.5, 0.05)
            )
            map.setRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)), animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            guard let a = annotation as? ResourceAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Resource", for: annotation) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Resource")
            view.markerTintColor = a.resource.type.uiColor
            view.glyphImage = UIImage(systemName: a.resource.type.icon)
            view.glyphTintColor = .white
            return view
        }
    }
}

final class ResourceAnnotation: NSObject, MKAnnotation {
    let resource: EmergencyResource
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: resource.coordinate.latitude, longitude: resource.coordinate.longitude)
    }
    var title: String? { resource.name }
    var subtitle: String? { resource.address }

    init(resource: EmergencyResource) {
        self.resource = resource
    }
}

struct LegendRow: View {
    let type: EmergencyResource.ResourceType
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.subheadline)
                    .foregroundStyle(type.color)
                    .frame(width: 28, alignment: .center)
                Text(type.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(isOn ? AppColors.ctaGreen : .secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let c = DependencyContainer()
    return MapView()
        .environmentObject(c.mapViewModel)
        .environmentObject(c.homeViewModel)
        .environmentObject(c.browseViewModel)
        .environmentObject(c.checklistViewModel)
        .environmentObject(c.alertsViewModel)
}
