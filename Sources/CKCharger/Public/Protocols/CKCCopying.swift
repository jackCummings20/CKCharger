//
//  CKCCopying.swift
//  CKCharger
//
//  Created by Jack Cummings on 5/6/20.
//  Copyright © 2020 Jack Cummings. All rights reserved.
//

import Foundation

public protocol CKCCopying {
    init()
    func copy() -> Self
}
//
//extension CKCCopying {
//    func copy() -> Self {
//        let mirror = Mirror(reflecting: self)
//        let copy = Self()
//        for child in mirror.children {
//            let keyPath = KeyPath<Self, child.self>()
//        }
//        return copy
//    }
//}
