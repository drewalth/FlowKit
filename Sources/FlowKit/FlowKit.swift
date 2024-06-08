// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - FKReadingProtocol

public protocol FKReadingProtocol {
  var id: UUID { get }
  var value: Double { get }
  var timestamp: Date { get }
  var unit: FKReadingUnit { get }
  var siteID: String { get }
}

// MARK: - FKReading

public struct FKReading: FKReadingProtocol {
  public let id: UUID
  public let value: Double
  public let timestamp: Date
  public let unit: FKReadingUnit
  public let siteID: String
}

// MARK: - FKReadingUnit

public enum FKReadingUnit: String, CaseIterable {
  case cfs
  case feet
  case meter
  case cms
  case temperature
}

// MARK: - TimePeriod

public enum TimePeriod {
  /// A custom time period with a start and end date.
  case custom(start: Date, end: Date)
  /// A predefined time period.
  /// - SeeAlso: `PredefinedTimePeriod`
  case predefined(PredefinedTimePeriod)
}

// MARK: - PredefinedTimePeriod

/// A predefined time period for fetching data from the USGS Water Services API.
/// With predefined time periods, you can fetch data for the last day, week, month, or year.
/// - Note: These values are used to get a date range from the current date.
public enum PredefinedTimePeriod: Int, CaseIterable {
  case oneDay = 1
  case sevenDays = 7
  case thirtyDays = 30
  case oneYear = 365
}
