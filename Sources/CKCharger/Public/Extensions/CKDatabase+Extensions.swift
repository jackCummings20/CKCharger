//
//  CKDatabase+Extensions.swift
//  CKCharger
//
//  Created by Jack Cummings on 10/13/20.
//

import CloudKit

public extension CKDatabase {
    /// Begins execution of the operation on the database
    func add<Q: CKCQuery, O: CKCQueryOperation<Q>>(_ operation: O) {
        operation.begin()
    }
}
