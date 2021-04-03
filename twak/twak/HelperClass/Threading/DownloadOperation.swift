//
//  DownloadOperation.swift
//  twak
//
//  Created by Archana on 02/04/21.
//

import Foundation
class DownloadOperation : Operation {
    let oprationRecord: DownloadOprationRecord
    
    init(_ oprationRecord: DownloadOprationRecord) {
        self.oprationRecord = oprationRecord
    }
    override func main () {
        if isCancelled {
            return
        }
        WSManager.shared.downloadImage(oprationRecord.urlRequest, foruser: oprationRecord.name, completion: { Result in
            switch Result {
            case .success(let data):
                self.oprationRecord.completionHandler(.success(data))
                
            case .failure(let error):
                switch error {
                case .retry:
                    let reAddInQueue = DownloadOperation(self.oprationRecord)
                    QueueManager.sharedInstance.addInRetryQueue(reAddInQueue)
                    fallthrough
                case .httpError:
                    self.oprationRecord.completionHandler(.failure(error))
                }
            }
            
        })
    }
}
