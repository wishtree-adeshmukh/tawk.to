//
//  FetchOpration.swift
//  twak
//
//  Created by Archana on 02/04/21.
//

import Foundation

class FetchOpration : Operation {
    let oprationRecord: UserOprationRecord
    
    init(_ oprationRecord: UserOprationRecord) {
        self.oprationRecord = oprationRecord
    }
    
    override func main () {
        if isCancelled {
            return
        }
        WSManager.shared.load(oprationRecord.url, completion: {result in
            switch result {
            case .success(let data):
                self.oprationRecord.completionHandler(.success(data))
            case .failure(let error):
                switch error {
                case .retry:
                    let reAddInQueue = FetchOpration(self.oprationRecord)
                    QueueManager.sharedInstance.addInRetryQueue(reAddInQueue)
                    fallthrough
                case .httpError :
                    self.oprationRecord.completionHandler(.failure(error))
                }
            }
            
        })
    }
}
