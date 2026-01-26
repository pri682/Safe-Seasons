//
//  WeatherAlertRepository.swift
//  SafeSeasons
//
//  SRP: weather alert data access only. DIP: depends on EmbeddedData (offline templates).
//

import Foundation

final class WeatherAlertRepository: WeatherAlertRepositoryProtocol {
    func fetchAlerts(stateAbbr: String, month: String) -> [WeatherAlert] {
        EmbeddedData.weatherAlertTemplates
            .filter { template in
                template.stateAbbr == stateAbbr
                    && (template.months.contains(month) || template.months.contains("All Year"))
            }
            .map { $0.alert }
    }
}
