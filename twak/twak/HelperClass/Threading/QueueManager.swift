//
//  QueueManager.swift
//  twak
//
//  Created by Archana on 02/04/21.
//

import Foundation
class QueueManager : NSObject{
    /// The Lazily-instantiated queue
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        queue.waitUntilAllOperationsAreFinished()
        return queue
    }()
    var retryQueue: Array<Operation> = []
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkOnline),
                                               name: .Online,
                                               object: nil
        )
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /// The Singleton Instance
    static let sharedInstance = QueueManager()
    
    /// Add a single operation
    /// - Parameter operation: The operation to be added
    func addInDownloadQueue(_ operation: Operation) {
        DispatchQueue.global(qos: .utility).async {
            self.downloadQueue.addOperation(operation)
        }
        
    }
    // Exponential backoff dealy
    func getDelay(for n: Int) -> Int {
        let maxDelayseconds = 180 // 3 minutes
        let delay = pow(2.0, Double(n)) > 180 ? 180 : Int(pow(2.0, Double(n)))
        let jitter = Int.random(in: 0...60)
        return min(delay + jitter, maxDelayseconds)
    }
    
    /// Add a single operation in retry ary
    /// - Parameter operation: The operation to be added
    func addInRetryQueue(_ operation: Operation) {
        let alreadythere = retryQueue.filter({opr in
            return opr == operation

          //  return ((opr as? DownloadOperation)?.oprationRecord.urlRequest == (operation as? DownloadOperation)?.oprationRecord.urlRequest ) || ((opr as? FetchOpration)?.oprationRecord.url == (operation as? FetchOpration)?.oprationRecord.url)
        })
        if alreadythere.isEmpty {
            let delay = getDelay(for: retryQueue.count)
            let delayOperation = DelayedBlockOperation(delay: TimeInterval(delay), {})
            operation.addDependency(delayOperation)
            retryQueue.append(delayOperation)
            retryQueue.append(operation)
        }
        
    }
    func scheduleRetry() {
        addInDownloadQueue(retryQueue)
        retryQueue = []
    }
    
    /// Add an array of operations
    /// - Parameter operations: The Array of Operation to be added
    func addInDownloadQueue(_ operations: [Operation]) {
        DispatchQueue.global(qos: .utility).async {
            //DispatchQueue.global(qos: .background).async
            self.downloadQueue.addOperations(operations, waitUntilFinished: true)
        }
        
    }
}
extension QueueManager {
    @objc func networkOnline() {
        if !retryQueue.isEmpty {
            scheduleRetry()
        }
    }
}
