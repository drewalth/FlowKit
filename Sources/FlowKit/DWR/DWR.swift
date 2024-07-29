//
//  File.swift
//
//
//  Created by Andrew Althage on 7/29/24.
//

import Foundation

// MARK: - DWR

// https://dwr.state.co.us/Rest/GET/api/v2/telemetrystations/telemetrystation/?abbrev=0200616A&format=JSON

// siteId: 0200616A

public struct DWR {

  public enum Errors: Error {
    case invalidURL
    case invalidUnit
    case invalidData
  }

  public func fetchData(_ siteId: String) async throws -> [FKReading] {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    let baseURLString = "https://dwr.state.co.us/Rest/GET/api/v2/telemetrystations/telemetrystation/"

    var urlComps = URLComponents(string: baseURLString)!

    let queryItems = [
      URLQueryItem(name: "format", value: "JSON"),
      URLQueryItem(name: "abbrev", value: siteId),
    ]

    urlComps.queryItems = queryItems

    guard let url = urlComps.url else {
      throw Errors.invalidURL
    }

    let (data, _) = try await URLSession.shared.data(from: url)

    let decoder = JSONDecoder()
    let response = try decoder.decode(DWRResponse.self, from: data)

    var readings = [FKReading]()

    for result in response.ResultList {
      guard let unit = FKReadingUnit(rawValue: result.units.lowercased()) else {
        throw Errors.invalidUnit
      }

      guard let timestamp = dateFormater.date(from: result.measDateTime) else {
        throw Errors.invalidData
      }

      let reading = FKReading(
        id: UUID(),
        value: result.measValue,
        timestamp: timestamp,
        unit: unit,
        siteID: result.abbrev)
      readings.append(reading)
    }

    return readings
  }
}

// MARK: - DWRResponse

public struct DWRResponse: Codable {
  public let PageNumber: Int
  public let PageCount: Int
  public let ResultCount: Int
  public let ResultDateTime: String
  public let ResultList: [DWRResult]
}

// MARK: - DWRResult

public struct DWRResult: Codable {
  public let division: Int
  public let waterDistrict: Int
  public let county: String
  public let stationName: String
  public let dataSourceAbbrev: String
  public let dataSource: String
  public let waterSource: String
  public let gnisId: String
  public let streamMile: Double
  public let abbrev: String
  public let usgsStationId: String?
  public let stationStatus: String
  public let stationType: String
  public let structureType: String
  /// Looks like: "2024-07-29T09:15:00-06:00",
  public let measDateTime: String
  public let parameter: String
  public let stage: Double?
  public let measValue: Double
  public let units: String
  public let flagA: String
  public let flagB: String?
  public let contrArea: Double?
  public let drainArea: Double?
  public let huc10: String?
  public let utmX: Double
  public let utmY: Double
  public let latitude: Double
  public let longitude: Double
  public let locationAccuracy: String
  public let wdid: String
  public let modified: String
  public let moreInformation: String
  public let stationPorStart: String
  public let stationPorEnd: String
  public let thirdParty: Bool
}
