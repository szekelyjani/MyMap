//
//  LocationDeniedView.swift
//  MyMap
//
//  Created by János Székely on 24/04/2024.
//

import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        ContentUnavailableView(label: {
            Label("Location Service", systemImage: "location.slash")
        }, description: {
            Text("""
1. Tap the button below and go to "Privacy and Security"
2. Tap on "Location Services"
3. Locate the "MyTrip" app and tap on in
4. Change the setting to "While using the app"
""")
            .multilineTextAlignment(.leading)
        }, actions: {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
            }
            .buttonStyle(.borderedProminent)
        })
    }
}

#Preview {
    LocationDeniedView()
}
