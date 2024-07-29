import XCTest
@testable import FlowKit

// bad tests. These are placeholder...
final class FlowKitTests: XCTestCase {

  // run test then visit https://waterdata.usgs.gov/monitoring-location/09359500/#parameterCode=00060&period=P7D&showMedian=false to see the source data
  func test_usgs_single() async throws {
    let results = try await USGS.waterServices.fetchGaugeStationData(
      siteID: "09359500",
      timePeriod: .predefined(.sevenDays),
      parameters: [.height, .discharge])

    let latestDischarge = results.last { $0.unit == .cfs }
    let latestHeight = results.last { $0.unit == .feet }

    XCTAssertNotNil(latestDischarge)
    XCTAssertNotNil(latestHeight)

    print(latestDischarge!)
    print(latestHeight!)
  }

  func test_usgs_multiple() async throws {
    let results = try await USGS.waterServices.fetchGaugeStationData(
      for: ["09359500", "01646500"],
      timePeriod: .predefined(.sevenDays),
      parameters: [.height, .discharge])

    let site1LatestDischarge = results.last { $0.siteID == "09359500" && $0.unit == .cfs }
    let site1LatestHeight = results.last { $0.siteID == "09359500" && $0.unit == .feet }

    let site2LatestDischarge = results.last { $0.siteID == "01646500" && $0.unit == .cfs }
    let site2LatestHeight = results.last { $0.siteID == "01646500" && $0.unit == .feet }

    XCTAssertNotNil(site1LatestDischarge)
    XCTAssertNotNil(site1LatestHeight)

    XCTAssertNotNil(site2LatestDischarge)
    XCTAssertNotNil(site2LatestHeight)

    print(site1LatestDischarge!)
    print(site1LatestHeight!)

    print(site2LatestDischarge!)
    print(site2LatestHeight!)
  }

  // https://dd.weather.gc.ca/hydrometric/csv/BC/hourly/
  // then select a station, e.g. 07EA004
  func test_environment_canada_single() async throws {
    let api = EnvironmentCanada()

    let results = try await api.fetchGaugeStationData(siteID: "07EA004", province: .bc)

    XCTAssertFalse(results.isEmpty)

    let latestDischarge = results.last { $0.unit == .cms }
    let latestHeight = results.last { $0.unit == .meter }

    XCTAssertNotNil(latestDischarge)
    XCTAssertNotNil(latestHeight)

    print(latestDischarge!)
    print(latestHeight!)
  }

  func test_environment_canada_multiple() async throws {
    let api = EnvironmentCanada()

    let results = try await api.fetchGaugeStationData(for: ["07EA004", "07EA005"], province: .bc)

    XCTAssertFalse(results.isEmpty)

    let site1LatestDischarge = results.last { $0.siteID == "07EA004" && $0.unit == .cms }
    let site1LatestHeight = results.last { $0.siteID == "07EA004" && $0.unit == .meter }

    let site2LatestDischarge = results.last { $0.siteID == "07EA005" && $0.unit == .cms }
    let site2LatestHeight = results.last { $0.siteID == "07EA005" && $0.unit == .meter }

    XCTAssertNotNil(site1LatestDischarge)
    XCTAssertNotNil(site1LatestHeight)

    XCTAssertNotNil(site2LatestDischarge)
    XCTAssertNotNil(site2LatestHeight)

    print(site1LatestDischarge!)
    print(site1LatestHeight!)

    print(site2LatestDischarge!)
    print(site2LatestHeight!)
  }

  func test_dwr_single() async throws {
    let dwr = DWR()

    let siteIDs = ["5800777A", "0200616A"]




    for siteID in siteIDs {
      let results = try await dwr.fetchData(siteID)

      XCTAssertFalse(results.isEmpty)
    }
  }

}
