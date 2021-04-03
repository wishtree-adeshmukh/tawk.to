//
//  OperationState.swift
//  twak
//
//  Created by Archana on 02/04/21.
//

import Foundation

class DownloadOprationRecord {
    typealias OperationCompletionHandler = ((Result<Data, Error>) -> Void)
    /// The completionHandler that is run when the operation is complete
    var completionHandler: (OperationCompletionHandler)
    var name: String
    var urlRequest: URLRequest
    
    init(name:String, urlRequest:URLRequest, completion: @escaping((Result<Data, Error>) -> Void)) {
        self.name = name
        self.urlRequest = urlRequest
        self.completionHandler = completion
    }
}

class  UserOprationRecord {
    let completionHandler:((Result<Data, Error>) -> Void)
    let url: URL
    init(url:URL, completion: @escaping((Result<Data, Error>) -> Void)){
        self.url = url
        self.completionHandler = completion
    }
    
}
