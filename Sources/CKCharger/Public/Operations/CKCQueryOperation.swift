//
//  CKCQueryOperation.swift
//  CKCharger
//
//  Created by Jack Cummings on 5/15/19.
//  Copyright © 2019 Jack Cummings. All rights reserved.
//

import Combine
import CloudKitCodable

private let operationCache = CKCQueryCache()

public class CKCQueryOperation<Q: CKCQuery>: ObservableObject {
        
    @Published public var state: CKCQueryOperationState<[Q.T]> = .loading

    public var query: Q
    internal var cursor: CKQueryOperation.Cursor?
    internal var results: [Q.T]
  
    public convenience init(_ query: Q) {
        if let cacheObject: CKCQueryCache.CacheObject<Q> = operationCache.object(forKey: query.id) {
            self.init(cacheObject: cacheObject)
        } else {
            self.init(query: query)
        }
    }
    
    private init(cacheObject: CKCQueryCache.CacheObject<Q>) {
        self.cursor = cacheObject.cursor
        self.query = cacheObject.query
        self.results = cacheObject.results
    }
    
    private init(query: Q) {
        self.cursor = nil
        self.query = query
        self.results = []
    }
    
    public func begin() {
        DispatchQueue.main.async {
            if !self.results.isEmpty, let _ = self.cursor {
                // We have existing results, and a cursor. Update with the preliminary results, and continue the operation with the cursor.
                self.performRemoteFetch()
                return self.state = .success(self.results)
            } else if !self.results.isEmpty && self.cursor == nil {
                // We have existing results, and no cursor. The operation is finished.
                return self.state = .success(self.results)
            } else {
                // No existing results, nor a cursor.  Begin the operation.
                self.performRemoteFetch()
            }
        }
    }
    
    private func performRemoteFetch() {
        // Starts a new CKCQueryOperation, using a query cursor if one exists.
        let operation = cursor != nil ? CKQueryOperation(cursor: cursor!) : CKQueryOperation(query: query.ckQuery)
        operation.resultsLimit = query.limit != nil ? query.limit! : 40
        operation.qualityOfService = .userInitiated
        CKCharger.defaultDatabase.add(operation)
        
        var temporaryResultStore: [Q.T] = []
       
        operation.recordMatchedBlock = { _, result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let record):
                let decodedResult = Q.T(from: record)
                temporaryResultStore.append(decodedResult)
            }
        }
                
        operation.queryResultBlock = { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    return self.state = .failure(error)
                }
            case .success(let cursor):
                // If a limit has not been set on the operation, save the cursor for later use.
                if self.query.limit == nil {
                    self.cursor = cursor
                }
                // Cache the results for future use.
                self.results.append(contentsOf: temporaryResultStore)
               // self.results = Array(Set(self.results))
                let cacheObject = CKCQueryCache.CacheObject(operation: self)
                operationCache.setObject(cacheObject, forKey: self.query.id)
                // Return to the main thread to update the UI.
                DispatchQueue.main.async {
                    return self.state = .success(self.results)
                }
            }
        }
    }
}

extension CKCQueryOperation: Equatable, Hashable, Identifiable {
    public var id: String {
        query.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(query.id)
    }
    
    public static func == (lhs: CKCQueryOperation, rhs: CKCQueryOperation) -> Bool {
        lhs.query == rhs.query
    }
}

private class CKCQueryCache {
    private var nsCache = NSCache<NSString, AnyObject>()
    
    func setObject<Q: CKCQuery>(_ cacheObject: CacheObject<Q>, forKey: String) {
        nsCache.setObject(cacheObject, forKey: cacheObject.query.id as NSString)
    }
    
    func object<Q: CKCQuery>(forKey: String) -> CacheObject<Q>? {
        return nsCache.object(forKey: forKey as NSString) as? CacheObject<Q>
    }
    
    class CacheObject<Q: CKCQuery> {
        let cursor: CKQueryOperation.Cursor?
        let query: Q
        let results: [Q.T]
        
        init(operation: CKCQueryOperation<Q>) {
            self.cursor = operation.cursor
            self.query = operation.query
            self.results = operation.results
        }
    }
}

public enum CKCQueryOperationState<Success: Equatable> {
    case success(Success), failure(Error), loading
}
