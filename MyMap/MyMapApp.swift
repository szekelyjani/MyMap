//
//  MyMapApp.swift
//  MyMap
//
//  Created by János Székely on 15/04/2024.
//

import SwiftUI

@main
struct MyMapApp: App {
    @State private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                MapView()
            } else {
                LocationDeniedView()
            }
        }
        .environment(locationManager)
    }
}
