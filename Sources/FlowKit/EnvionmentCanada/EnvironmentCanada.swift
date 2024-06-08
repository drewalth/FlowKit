//
//  EnvironmentCanada.swift
//
//
//  Created by Andrew Althage on 6/8/24.
//

import Foundation
import os

// MARK: - EnvironmentCanadaAPIProtocol

public protocol EnvironmentCanadaAPIProtocol {
  func fetchGaugeStationData(
    siteID: String,
    province: EnvironmentCanada.Province) async throws -> [FKReading]
  func fetchGaugeStationData(
    for siteIDs: [String],
    province: EnvironmentCanada.Province) async throws -> [FKReading]
}

// MARK: - EnvironmentCanada

public struct EnvironmentCanada: EnvironmentCanadaAPIProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public enum Errors: Error, LocalizedError {
    case failedToFetch(Error)
    case invalidCSV(String)
    case invalidURL
    case failedToDownloadCSV(String)
    case failedToParseDate(String)
    case failedToParseWaterLevel(String)

    // MARK: Public

    public var errorDescription: String? {
      switch self {
      case .failedToFetch(let error):
        "Failed to fetch data: \(error.localizedDescription)"
      case .invalidCSV(let siteID):
        "Invalid CSV for siteID: \(siteID)"
      case .invalidURL:
        "Invalid URL Provided"
      case .failedToDownloadCSV(let siteID):
        "Failed to download CSV for siteID: \(siteID)"
      case .failedToParseDate(let siteID):
        "Failed to parse date for siteID: \(siteID)"
      case .failedToParseWaterLevel(let siteID):
        "Failed to parse water level for siteID: \(siteID)"
      }
    }

  }

  /// The province codes for the gauge stations
  public enum Province: String, CaseIterable {
    case ab
    case bc
    case mb
    case nb
    case nl
    case ns
    case nt
    case nu
    case on
    case pe
    case qc
    case sk
    case yt
  }


  /// Fetches the latest readings for multiple gauge stations from the Environment Canada API concurrently.
  /// - Parameters:
  /// - siteIDs: An array of site IDs
  /// - province: The province code of the gauge stations
  /// - Returns: An array of FKReading objects
  /// - Throws: An error if the fetch fails
  public func fetchGaugeStationData(for siteIDs: [String], province: Province) async throws -> [FKReading] {
    var results = [FKReading]()

    try await withThrowingTaskGroup(of: [FKReading].self) { taskGroup in
      for siteID in siteIDs {
        taskGroup.addTask {
          try await fetchData(siteID: siteID, province: province)
        }
      }

      for try await result in taskGroup {
        results.append(contentsOf: result)
      }
    }

    return results
  }

  /// Fetches the latest reading from the Environment Canada API
  /// - Parameters:
  ///  - siteID: The site ID of the gauge station
  ///  - province: The province code of the gauge station
  ///  - Returns: An array of FKReading objects
  ///  - Throws: An error if the fetch fails
  public func fetchGaugeStationData(siteID: String, province: Province) async throws -> [FKReading] {
    try await fetchData(siteID: siteID, province: province)
  }

  // MARK: Private

  private let logger = Logger(category: "EnvironmentCanadaAPI")

  /// Fetches the latest readings for a single gauge station from the Environment Canada API.
  /// - Parameters:
  /// - siteID: The site ID of the gauge station
  /// - province: The province code of the gauge station
  /// - Returns: An array of FKReading objects
  /// - Throws: An error if the fetch fails
  /// - Note: This function is private and should not be called directly.
  /// Use `fetchGaugeStationData(siteID:province:)` or `fetchGaugeStationData(for:province:)` instead.
  /// - Note: Canadian gauge readings are served as CSV files.
  private func fetchData(siteID: String, province: Province) async throws -> [FKReading] {
    let csvManager = CSVManager()
    let tempDirectory = try csvManager.createTempDirectory()
    do {
      var newReadings = [FKReading]()

      let urlString = String(
        format: "https://dd.weather.gc.ca/hydrometric/csv/%@/hourly/%@_%@_hourly_hydrometric.csv",
        province.rawValue.uppercased(),
        province.rawValue.uppercased(),
        siteID)

      guard let url = URL(string: urlString) else {
        throw Errors.invalidURL
      }

      guard let downloadedFileURL = try? await csvManager.downloadCSV(from: url) else {
        throw Errors.failedToDownloadCSV(urlString)
      }

      let tempFileURL = tempDirectory.appendingPathComponent(downloadedFileURL.lastPathComponent)
      try FileManager.default.moveItem(at: downloadedFileURL, to: tempFileURL)

      let parsedData = try csvManager.parseCSV(at: tempFileURL)

      guard csvManager.validateFirstRow(of: parsedData) else {
        throw Errors.invalidCSV(siteID)
      }

      for row in parsedData where row[0] == siteID {
        guard let createdAt = dateFromString(row[1]) else {
          throw Errors.failedToParseDate(siteID)
        }

        guard let heightReading = Double(row[2]) else {
          throw Errors.failedToParseWaterLevel(siteID)
        }

        guard let dischargeReading = Double(row[6]) else {
          throw Errors.failedToParseWaterLevel(siteID)
        }

        newReadings.append(.init(id: .init(), value: heightReading, timestamp: createdAt, unit: .meter, siteID: siteID))
        newReadings.append(.init(id: .init(), value: dischargeReading, timestamp: createdAt, unit: .cms, siteID: siteID))
      }

      try csvManager.deleteTempDirectory(at: tempDirectory)
      return newReadings
    } catch {
      logger.error("Failed to fetch data for \(siteID): \(error.localizedDescription)")
      try csvManager.deleteTempDirectory(at: tempDirectory)
      throw Errors.failedToFetch(error)
    }
  }

  private func dateFromString(_ dateString: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [
      .withInternetDateTime,
      .withDashSeparatorInDate,
      .withColonSeparatorInTime,
      .withColonSeparatorInTimeZone,
    ]
    return dateFormatter.date(from: dateString)
  }
}

// MARK: EnvironmentCanada.CSVManager

extension EnvironmentCanada {
  private struct CSVManager {

    // MARK: Internal

    func parseCSV(at url: URL) throws -> [[String]] {
      let content = try String(contentsOf: url)
      return content.components(separatedBy: "\n").map { $0.components(separatedBy: ",") }
    }

    /// Ensure that the downloaded CSV is not an HTML 404 page
    func validateFirstRow(of csvContent: [[String]]) -> Bool {
      csvContent[0].joined(separator: ",").replacingOccurrences(of: " ", with: "").contains("ID,Date,Water")
    }

    func downloadCSV(from url: URL) async throws -> URL {
      let (tempLocalURL, _) = try await URLSession.shared.download(from: url)
      return tempLocalURL
    }

    func createTempDirectory() throws -> URL {
      let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
      try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
      return tempDirectoryURL
    }

    func deleteTempDirectory(at url: URL) throws {
      try FileManager.default.removeItem(at: url)
    }

    // MARK: Private

    private let logger = Logger(category: "EnvironmentCanada.CSVManager")
  }
}
