import XCTest
@testable import FlowKit

// bad tests. These are placeholder...
final class FlowKitTests: XCTestCase {

  // run test then visit https://waterdata.usgs.gov/monitoring-location/09359500/#parameterCode=00060&period=P7D&showMedian=false to see the source data
  func testExample() async throws {
    let api = USGS.WaterServices()

    let results = try await api.fetchGaugeStationData(
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

  func testMultipleSites() async throws {
    let api = USGS.WaterServices()

    let results = try await api.fetchGaugeStationData(
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
}
