//
//  DetailsView.swift
//  MyMap
//
//  Created by János Székely on 24/04/2024.
//

import MapKit
import SwiftUI

struct DetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showDetails: Bool
    @Binding var showRoute: Bool
    @Binding var travelInterval: TimeInterval?
    @Binding var transportType:  MKDirectionsTransportType
    @State private var viewModel: ViewModel
    var mapSelection: MKMapItem
    
    var travelTime: String? {
        guard let travelInterval else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: travelInterval)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    selectedPlaceTitle
                    selectedPlaceDescription
                    
                    HStack {
                        showDriveRouteButton
                        showWalkingRouteButton
                        if let travelTime {
                            let prefix = transportType == .automobile ? "Driving" : "Walking"
                            Text("\(prefix) me: \(travelTime)")
                        }
                    }
                }
                
                Spacer()
                
                closeButton
            }
            Divider()
            Spacer()
            ZStack {
                LookAroundPreview(initialScene: viewModel.lookAroundScene).opacity(viewModel.lookAroundScene == nil ? 0 : 1)
                ContentUnavailableView("No preview available", systemImage: "eye.slash").opacity(viewModel.lookAroundScene == nil ? 1 : 0)
            }
            .frame(minWidth: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            showDirectionsbutton
        }
        .onAppear {
            viewModel.fetchLookAroundPreview()
        }
        .onChange(of: mapSelection) { _, _ in
            viewModel.fetchLookAroundPreview()
        }
        .padding()
    }
    
    private var selectedPlaceTitle: some View {
        Text(mapSelection.placemark.name ?? "")
            .font(.title2)
            .fontWeight(.semibold)
    }
    
    private var selectedPlaceDescription: some View {
        Text(mapSelection.placemark.title ?? "")
            .font(.footnote)
            .foregroundStyle(.gray)
            .lineLimit(2)
            .padding(.trailing)
    }
    
    private var showDriveRouteButton: some View {
        Button {
            transportType = .automobile
        } label: {
            Image(systemName: "car")
                .symbolVariant(transportType == .automobile ? .circle : .none)
                .imageScale(.large)
        }
    }
    
    private var showWalkingRouteButton: some View {
        Button {
            transportType = .walking
        } label: {
            Image(systemName: "figure.walk")
                .symbolVariant(transportType == .walking ? .circle : .none)
                .imageScale(.large)
        }
    }
    
    private var closeButton: some View {
        Button {
            viewModel.mapSelection = nil
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.black, Color(.red).opacity(0.6))
        }
    }
    
    private var showDirectionsbutton: some View {
        Button {
            showDetails = false
            showRoute = true
        } label: {
            Text("Show Route")
                .padding()
                .font(.headline)
                .padding()
                .frame(height: 44)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    init(mapSelection: MKMapItem,
         transportType: Binding<MKDirectionsTransportType>,
         showDetails: Binding<Bool>,
         showRoute: Binding<Bool>,
         travelInterval: Binding<TimeInterval?>
    ) {
        self.mapSelection = mapSelection
        self._showDetails = showDetails
        self._showRoute = showRoute
        self._transportType = transportType
        self._travelInterval = Binding(projectedValue: travelInterval)
        _viewModel = State(initialValue: ViewModel(mapSelection: mapSelection))
    }
    
}

//#Preview {
//    DetailsView()
//}
