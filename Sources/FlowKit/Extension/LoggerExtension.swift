//
//  File.swift
//
//
//  Created by Andrew Althage on 6/8/24.
//

import Foundation
import os

extension Logger {
  init(category: String) {
    self.init(subsystem: "com.drewalth.FlowKit", category: category)
  }
}
