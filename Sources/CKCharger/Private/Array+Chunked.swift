//
//  Array+Chunked.swift
//  CKCharger
//
//  Created by Jack Cummings on 8/21/21.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
