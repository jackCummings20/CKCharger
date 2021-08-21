//
//  CKCOperationResultView.swift
//  CKCharger
//
//  Created by Jack Cummings on 5/1/20.
//  Copyright © 2020 Jack Cummings. All rights reserved.
//

import CloudKit
import SwiftUI

/// A SwiftUI View useful for displaying the progress and result of a CKCQueryOperation.
public struct CKCQueryOperationView<Q: CKCQuery, EmptyView: View, ErrorView: View, SuccessView: View>: View {
   
    @ObservedObject var operation: CKCQueryOperation<Q>
    private let errorView: (Error) -> ErrorView
    private let emptyView: () -> EmptyView
    private let successView: ([Q.T]) -> SuccessView
    
    public init(operation: CKCQueryOperation<Q>, @ViewBuilder errorView: @escaping (Error) -> ErrorView, @ViewBuilder emptyView: @escaping () -> EmptyView, @ViewBuilder successView: @escaping ([Q.T]) -> SuccessView) {
        self.operation = operation
        self.errorView = errorView
        self.emptyView = emptyView
        self.successView = successView
    }
    
    public init(query: Q, @ViewBuilder errorView: @escaping (Error) -> ErrorView, @ViewBuilder emptyView: @escaping () -> EmptyView, @ViewBuilder successView: @escaping ([Q.T]) -> SuccessView) {
        self.init(operation: CKCQueryOperation(query), errorView: errorView, emptyView: emptyView, successView: successView)
    }
    
    @ViewBuilder public var body: some View {
        Group {
            switch operation.state {
            case .loading:
                ProgressView()
                    .task {
                        CKCharger.defaultDatabase.add(operation)
                    }
            case .failure(let error):
                errorView(error)
            case .success(let results):
                if results.isEmpty {
                    emptyView()
                } else {
                    successView(results)
                }
            }
        }.id(operation.id)
    }
}

public struct CKCQueryOperationListStyleView<Q: CKCQuery, ErrorView: View, EmptyView: View, Content: View>: View {

    internal let operation: CKCQueryOperation<Q>
    internal let errorView: (Error) -> ErrorView
    internal let emptyView: () -> EmptyView
    internal let content: (Q.T) -> Content
            
    public init(query: Q, @ViewBuilder errorView: @escaping (Error) -> ErrorView, @ViewBuilder emptyView: @escaping () -> EmptyView, @ViewBuilder content: @escaping (Q.T) -> Content) {
        self.operation = CKCQueryOperation(query)
        self.errorView = errorView
        self.emptyView = emptyView
        self.content = content
    }
    
    public var body: some View {
        CKCQueryOperationView(operation: operation) { error in
            errorView(error)
        } emptyView: {
            emptyView()
        } successView: { results in
            successView(results)
        }
    }
    
    // MARK: Helper views
    private var pagingIndicator: some View {
        ProgressView()
            .padding()
            .task {
                print("task called")
                CKCharger.defaultDatabase.add(operation)
            }
    }
    
    // MARK: Functions
    private func successView(_ results: [Q.T]) -> some View {
        List(results) { item in
            VStack {
                content(item)
                if let _ = operation.cursor, results.isLastItem(item) {
                    pagingIndicator
                }
            }
        }
    }
}

public struct CKCQueryOperationSectionStyleView<Q: CKCQuery, EmptyView: View, ErrorView: View, Content: View>: View {

    internal let operation: CKCQueryOperation<Q>
    internal let errorView: (Error) -> ErrorView
    internal let emptyView: () -> EmptyView
    internal let content: (Q.T) -> Content
            
    public init(operation: CKCQueryOperation<Q>, @ViewBuilder errorView: @escaping (Error) -> ErrorView, @ViewBuilder emptyView: @escaping () -> EmptyView, @ViewBuilder content: @escaping (Q.T) -> Content) {
        self.operation = operation
        self.errorView = errorView
        self.emptyView = emptyView
        self.content = content
    }
    
    public var body: some View {
        CKCQueryOperationView(operation: operation) { error in
            errorView(error)
        } emptyView: {
            emptyView()
        } successView: { results in
            ForEach(results) { result in
                content(result)
            }
        }
    }
}
