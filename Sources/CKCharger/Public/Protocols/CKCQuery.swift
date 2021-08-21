//
//  CKCQuery.swift
//  CKCharger
//
//  Created by Jack Cummings on 5/15/19.
//  Copyright © 2019 Jack Cummings. All rights reserved.
//

import Combine
import CloudKitCodable

/// A protocol allowing for the creation of simple, user-managed, CloudKit queries for app database types
public protocol CKCQuery: CKCCopying, Equatable, Identifiable, ObservableObject {
    
    associatedtype T: CKDecodable & Identifiable & Hashable
    var limit: Int? { get set }
    var sortDescriptors: [NSSortDescriptor] { get set }
    
    func assemblePredicates() -> [NSPredicate]
}

extension CKCQuery {
    var ckQuery: CKQuery {
        let query = CKQuery(recordType: "\(T.self)", predicate: NSCompoundPredicate(type: .and, subpredicates: assemblePredicates()))
        query.sortDescriptors = sortDescriptors
        return query
    }
    
    public var id: String {
        String(UInt(bitPattern: ObjectIdentifier(self)))
    }
}

public extension CKCQuery {
    func sort(by key: String, ascending: Bool = true) -> Self {
        let query = self.copy()
        query.sortDescriptors.append(NSSortDescriptor(key: key, ascending: ascending))
        return query
    }
    
    func `where`<Value>(_ key: WritableKeyPath<Self, Value>, equals value: Value) -> Self {
        var query = self.copy()
        query[keyPath: key] = value
        return query
    }
}

public extension CKCQuery {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.assemblePredicates() == rhs.assemblePredicates()
    }
}
