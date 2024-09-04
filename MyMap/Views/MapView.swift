//
//  MapView.swift
//  MyMap
//
//  Created by János Székely on 15/04/2024.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var viewModel = ViewModel()
    @Namespace private var locationSpace
    
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $viewModel.mapSelection, scope: locationSpace) {
                UserAnnotation()
                ForEach(viewModel.searchResults, id: \.self) { mapItem in
                    if viewModel.showRoute {
                        if mapItem == viewModel.routeDestionation {
                            let placeMark = mapItem.placemark
                            Marker(placeMark.name ?? "", coordinate: placeMark.coordinate)
                                .tint(.blue)
                        }
                    } else {
                        let placeMark = mapItem.placemark
                        Marker(placeMark.name ?? "",
                               coordinate: placeMark.coordinate)
                        .tint(.blue)
                    }
                }
                
                if viewModel.showRoute, let route = viewModel.route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .navigationTitle("MyMap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(viewModel.showRoute ? .hidden : .visible, for: .navigationBar)
            .searchable(text: $viewModel.searchText, isPresented: $viewModel.showSearch)
            .mapStyle(viewModel.mapStyleConfig.mapStyle)
            .mapControls {
                MapCompass(scope: locationSpace)
                MapPitchToggle(scope: locationSpace)
                MapUserLocationButton(scope: locationSpace)
            }
            .overlay(alignment: .bottomTrailing) {
                MapCompass(scope: locationSpace)
                MapPitchToggle(scope: locationSpace)
                MapUserLocationButton(scope: locationSpace)
                mapStyleSelectorButton
            }
            .sheet(isPresented: $viewModel.showDetails, onDismiss: {
                if let rect = viewModel.route?.polyline.boundingMapRect, viewModel.showRoute {
                    withAnimation {
                        cameraPosition = .rect(rect)
                    }
                }
            }, content:  {
                if let mapSelection = viewModel.mapSelection {
                    DetailsView(mapSelection: mapSelection, transportType: $viewModel.transportType, showDetails: $viewModel.showDetails, showRoute: $viewModel.showRoute, travelInterval: $viewModel.travelInterval)
                        .presentationDetents([.height(300)])
                }
            })
            .sheet(isPresented: $viewModel.showMapStyleModifier) {
                MapStyleView(mapStyleConfig: $viewModel.mapStyleConfig)
                    .presentationDetents([.height(300)])
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.showRoute {
                    HStack {
                        endRouteButton
                        showSteps
                    }
                }
            }
            .task(id: viewModel.transportType) {
                viewModel.fetchRoute()
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.visibleRegion = context.region
        }
        .onChange(of: viewModel.showSearch, initial: false) { oldValue, newValue in
            if let rect = viewModel.route?.polyline.boundingMapRect, viewModel.showRoute {
                cameraPosition = .rect(rect)
            }
        }
        .onSubmit(of: .search) {
            Task {
                guard let userLcoation = locationManager.userLocation, !viewModel.searchText.isEmpty else { return }
                let userRegion = MKCoordinateRegion(center: userLcoation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
                await viewModel.searchPlaces(region: userRegion)
            }
        }
        .onChange(of: viewModel.mapSelection) { _, newValue in
            viewModel.showDetails = newValue != nil
            viewModel.fetchRoute()
        }
        .onChange(of: viewModel.showSearch, initial: false) { _, newValue in
            if !viewModel.showSearch {
                viewModel.removeAllResult()
                withAnimation {
                    cameraPosition = cameraPosition
                }
            }
        }
    }
    
    private var mapStyleSelectorButton: some View {
        Button {
            viewModel.showMapStyleModifier.toggle()
        } label: {
            Image(systemName: "globe.americas.fill")
                .imageScale(.large)
                .padding(10)
                .background(.background)
                .clipShape(Circle())
                .padding(5)
        }
    }
    
    private var endRouteButton: some View {
        Button(role: .destructive) {
            withAnimation {
                viewModel.showRoute = false
                viewModel.showDetails = false
                viewModel.mapSelection = nil
                viewModel.route = nil
                updateCameraPosition()
            }
        } label: {
            Label("End Route", systemImage: "xmark.circle")
        }
        .fixedSize(horizontal: true, vertical: false)
        .background(.red.gradient, in: .rect(cornerRadius: 15))
        .buttonStyle(.borderedProminent)
    }
    
    private var showSteps: some View {
        Button("Show Steps", systemImage: "location.north") {
            withAnimation {
                viewModel.showSteps = true
            }
        }
        .buttonStyle(.borderedProminent)
        .fixedSize(horizontal: true, vertical: false)
        .sheet(isPresented: $viewModel.showSteps) {
            if let route = viewModel.route {
                NavigationStack {
                    List {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
                            Text("From my location")
                            Spacer()
                        }
                        ForEach(1..<route.steps.count, id: \.self) { idx in
                            VStack(alignment: .leading) {
                                Text("\(viewModel.transportType == .automobile ? "Drive" : "Walk" ) \(MapManager.distance(meters: route.steps[idx].distance))")
                                Text(" - \(route.steps[idx].instructions)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateCameraPosition() {
        if let userLocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.1,
                    longitudeDelta: 0.1
                )
            )
            withAnimation {
                cameraPosition = .region(userRegion)
            }
        }
    }
}

#Preview {
    MapView()
}
