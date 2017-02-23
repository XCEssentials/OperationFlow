//
//  Flow.Public.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension OperationFlow
{
    func input<Input>(_ value: Input) -> FirstConnector<Input>
    {
        return FirstConnector(self, initialInput: value)
    }
    
    func add<Output>(_ op: @escaping Operation<Output>) -> Connector<Output>
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            self.operations
                .append { (flow, _) throws -> Any? in
                    
                    return try op(flow)
            }
        }
        
        //===
        
        return Connector<Output>(self)
    }
    
    func cancel()
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            switch self.status
            {
            case .pending, .processing:
                self.status = .cancelled
                
            default:
                break // ignore
            }
        }
    }
    
    func executeAgain(after delay: TimeInterval = 0)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain(after: delay) {
            
            if
                self.reset()
            {
                self.start()
            }
        }
    }
}
