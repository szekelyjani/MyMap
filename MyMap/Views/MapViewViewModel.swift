//
//  MapViewViewModel.swift
//  MyMap
//
//  Created by János Székely on 24/04/2024.
//

import CoreLocation
import Foundation
import LocalAuthentication
import MapKit
import Observation

extension MapView {
    
    @Observable
    final class ViewModel {
        var mapStyleConfig = MapStyleConfig()
        var showMapStyleModifier = false
        var searchText = ""
        var searchResults = [MKMapItem]()
        var showSearch = false
        var visibleRegion: MKCoordinateRegion?
        var mapSelection: MKMapItem?
        var showDetails = false
        var route: MKRoute?
        var transportType = MKDirectionsTransportType.automobile
        var travelInterval: TimeInterval?
        var showRoute = false
        var routeDestionation: MKMapItem?
        var showSteps = false
        
        func searchPlaces(region: MKCoordinateRegion) async {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = visibleRegion ?? region
            
            let results = try? await MKLocalSearch(request: request).start()
            searchResults = results?.mapItems ?? []
        }
        
        func removeAllResult() {
            searchResults.removeAll(keepingCapacity: false)
            showDetails = false
        }
        
        func fetchRoute() {
            if let mapSelection {
                Task {
                    let request = MKDirections.Request()
                    request.source = MKMapItem.forCurrentLocation()
                    request.destination = mapSelection
                    request.transportType = transportType
                    let result = try? await MKDirections(request: request).calculate()
                    route = result?.routes.first
                    routeDestionation = mapSelection
                    travelInterval = route?.expectedTravelTime
                }
            }
        }
        
        func removeRoute() {
            route = nil
            showRoute = false
            mapSelection = nil
        }
        
    }
}
