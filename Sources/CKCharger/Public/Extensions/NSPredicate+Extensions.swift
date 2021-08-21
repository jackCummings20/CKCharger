//
//  NSPredicate+Extensions.swift
//  PredicateKit
//
//  Created by Jack Cummings on 5/1/20.
//  Copyright © 2020 Jack Cummings. All rights reserved.
//

import Foundation

public extension NSPredicate {
    /// A predicate that always evaluates as true.
    static var `true`: NSPredicate {
        NSPredicate(value: true)
    }
    
    static func `where`(_ key: String, contains value: CVarArg?) -> NSPredicate {
        guard let value = value else { return .true }
        return NSPredicate(format: "%K CONTAINS %d", key, value)
    }
    
    /// Creates and returns a CloudKit NSPrediccate that checks if an array contains specified values.
    /// - Parameters:
    ///   - key: The array key in the CloudKit object
    ///   - values: The values tthat the array must contain
    static func `where`(_ key: String, containsAny values: [CVarArg?]) -> NSPredicate {
        return NSPredicate(format: "ANY %K IN %@", key, values)
    }
    
    /// Simplified method of creaating a CloudKit NSPredicate comparing a key and value.
    /// - Parameters:
    ///   - key: The key in the CloudKit object
    ///   - comparatorString: The NSPredicate comparison string
    ///   - value: The value that the key must match
    static func `where`(_ key: String, _ comparatorString: String, _ value: CVarArg?) -> NSPredicate {
        guard let value = value else { return NSPredicate(value: true) }
        if let intValue = value as? Int {
            return NSPredicate(format: "%K \(comparatorString) %d", key, intValue)
        }
        return NSPredicate(format: "%K \(comparatorString) %@", key, value)
    }
}
