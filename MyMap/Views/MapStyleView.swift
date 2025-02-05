//
//  MapStyleView.swift
//  MyMap
//
//  Created by János Székely on 25/04/2024.
//

import SwiftUI

struct MapStyleView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mapStyleConfig: MapStyleConfig
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                LabeledContent("Base Style") {
                    Picker("Base Style", selection: $mapStyleConfig.baseStyle) {
                        ForEach(MapStyleConfig.BaseMapStyle.allCases, id: \.self) { type in
                            Text(type.label)
                        }
                    }
                }
                
                LabeledContent("Elevation") {
                    Picker("Elevation", selection: $mapStyleConfig.pointsOfInterest) {
                        Text("None").tag(MapStyleConfig.MapPOI.excludingAll)
                        Text("All").tag(MapStyleConfig.MapPOI.all)
                    }
                }
                if mapStyleConfig.baseStyle != .imagery {
                    LabeledContent("Points of Interest") {
                        Picker("Points of Interest", selection: $mapStyleConfig.pointsOfInterest) {
                            Text("None").tag(MapStyleConfig.MapPOI.excludingAll)
                            Text("All").tag(MapStyleConfig.MapPOI.all)
                        }
                    }
                    Toggle("Show Traffic", isOn: $mapStyleConfig.showTraffic)
                }
                Button("OK") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Map Style")
            .navigationBarTitleDisplayMode(.inline)
            Spacer()
        }
    }
}

#Preview {
    MapStyleView(mapStyleConfig: .constant(MapStyleConfig.init()))
}
