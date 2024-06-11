![FlowKit](/flowkit-logo.jpg)

[![FlowKit CI](https://github.com/drewalth/FlowKit/actions/workflows/ci.yml/badge.svg)](https://github.com/drewalth/FlowKit/actions/workflows/ci.yml)

FlowKit is a Swift package that aggregates river flow data from various sources into one easy-to-use API.

## Sources

- [USGS](https://waterdata.usgs.gov/nwis)
- [Environment Canada](https://wateroffice.ec.gc.ca)

## Installation

FlowKit is available through the Swift Package Manager. To install it, simply add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/drewalth/FlowKit.git", from: "1.0.0")
]
```

## Usage

> NOTE: The main caveat is you must already know the site ID of the gauge station you want to fetch data for. You can find this by searching the USGS or 
> Environment Canada websites.

```swift
import FlowKit

let api = EnvironmentCanada()
let fkReadings = try await api.fetchGaugeStationData(siteID: siteID, province: .bc)

for reading in fkReadings {
    print(reading)
}
```

## Contributing

To get started with development, clone the repository and run the following commands:

```bash
make setup # Installs dependencies
```

Once you've made your changes, open up a pull request and I'll review it as soon as possible.