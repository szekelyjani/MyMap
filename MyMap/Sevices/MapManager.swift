//
//  MapManager.swift
//  MyMap
//
//  Created by János Székely on 08/05/2024.
//

import Foundation

enum MapManager {
    
    static func distance(meters: Double) -> String {
        let userLocale = Locale.current
        let formatter = MeasurementFormatter()
        var options: MeasurementFormatter.UnitOptions = []
        options.insert(.providedUnit)
        options.insert(.naturalScale)
        formatter.unitOptions = options
        let meterValue = Measurement(value: meters, unit: UnitLength.meters)
        let yardsValue = Measurement(value: meters, unit: UnitLength.yards)
        return formatter.string(from: userLocale.measurementSystem == .metric ? meterValue : yardsValue)
    }
    
}
