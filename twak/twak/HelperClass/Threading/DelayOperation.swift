//
//  DelayOperation.swift
//  twak
//
//  Created by Archana on 03/04/21.
//

import Foundation
class DelayedBlockOperation: Operation {
    private var delay: TimeInterval = 0 // seconds
    private var block: (() -> Void)? = nil
    
    init(delay: TimeInterval, _ block: @escaping () -> Void) {
        self.delay = delay
        self.block = block
    }
    
    @objc func performBlock() {
        guard !self.isCancelled else {
            return
        }
        guard let block = self.block else {
            return
        }
        block()
    }
    
    override func start() {
        super.start()
        perform(#selector(performBlock), with: nil, afterDelay: delay)
        
    }
    override func main() {
        
    }
}
