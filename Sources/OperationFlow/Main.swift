//
//  Main.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/24/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias OFL = OperationFlow // for scoping when necessary

//===

public
final
class OperationFlow
{
    let core: Core
    
    //===
    
    public
    enum State: String
    {
        case
            ready,
            processing,
            failed,
            completed,
            cancelled
    }
    
    //===
    
    public internal(set)
    var state: State
    
    public internal(set)
    var failedAttempts: UInt = 0
    
    //===
    
    var targetOperationIndex: UInt = 0
    
    //===
    
    var isCancelled: Bool { return state == .cancelled }
    
    //===
    
    init(_ core: Core)
    {
        self.core = core
        self.state = .ready
        
        //===
        
        OFL.ensureOnMain { try! self.start() } //swiftlint:disable:this force_try
    }
}

//===

public
extension OFL
{
    func cancel() throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .cancelled
    }
    
    func executeAgain(after delay: TimeInterval = 0) throws
    {
        try OFL.checkFlowState(self, OFL.validStatesBeforeReset)
        
        //===
        
        // use 'ensure...' here only because of the delay
        
        OFL.ensureOnMain(after: delay) {
            
            try! self.reset() //swiftlint:disable:this force_try
        }
    }
}
