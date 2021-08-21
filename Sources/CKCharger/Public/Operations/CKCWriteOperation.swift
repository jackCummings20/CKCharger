//
//  CKCWriteOperation.swift
//  CKCCharger
//
//  Created by Jack Cummings on 7/11/21.
//

import CloudKitCodable

public class CKCWriteOperation {
    
    @Published public var state: CKCWriteOperationState = .loading

    public init() { }
    
    public func write(_ records: [CKRecord]) async {
        let chunks = records.chunked(into: 400)
        for chunk in chunks {
            let _ = await uploadChanges(recordsToSave: chunk)
        }
    }
    
    public func delete(_ records: [CKRecord]) async {
        let chunks = records.chunked(into: 400)
        for chunk in chunks {
            let _ = await uploadChanges(recordsToDelete: chunk.map(\.recordID))
        }
    }

    private func uploadChanges(recordsToSave: [CKRecord] = [], recordsToDelete: [CKRecord.ID] = []) async -> Result<Void, Error> {
        return await withCheckedContinuation { continuation in
            uploadChanges(recordsToSave: recordsToSave, recordsToDelete: recordsToDelete) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func uploadChanges(recordsToSave: [CKRecord], recordsToDelete: [CKRecord.ID], _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordsToDelete)
        operation.savePolicy = .changedKeys
        CKCharger.defaultDatabase.add(operation)

        operation.perRecordSaveBlock = { _, result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                print("Succesfully updated record \(record.recordID.recordName)")
            }
        }
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                return completionHandler(.failure(error))
            case .success():
                print("completed upload")
                return completionHandler(.success(()))
            }
        }
    }
}

public enum CKCWriteOperationState {
    case loading, failure(Error), success
}
