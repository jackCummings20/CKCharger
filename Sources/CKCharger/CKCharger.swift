//
//  CKCharger.swift
//  CKCharger
//
//  Created by Jack Cummings on 10/12/20.
//

@_exported import CloudKit
@_exported import CloudKitCodable

public class CKCharger {
    /// The default database to use for all CloudKit operations.
    public static var defaultDatabase: CKDatabase = CKContainer.default().privateCloudDatabase
}
