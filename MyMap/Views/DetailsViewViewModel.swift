//
//  DetailsViewViewModel.swift
//  MyMap
//
//  Created by János Székely on 24/04/2024.
//

import Foundation
import MapKit

extension DetailsView {
    @Observable
    class ViewModel {
        var lookAroundScene: MKLookAroundScene?
        var mapSelection: MKMapItem?
        
        func fetchLookAroundPreview() {
            if let mapSelection {
                lookAroundScene = nil
                Task {
                    let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                    lookAroundScene = try? await request.scene
                }
            }
        }
        
        init(mapSelection: MKMapItem?) {
            self.mapSelection = mapSelection
        }
    }
}
