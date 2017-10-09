/*
  GetDetailsOperation.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/15/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 
 Abstract:
     This file setup operation to download and parse photos details data. It will also decide to display an error message, if approperiate.
*/

import Foundation

/// A composite `Operation` to both download and parse data.
final class GetDetailsOperation: GroupOperation {
    //MARK: Properties
    
    let downloadOperation: DownloadDetailsOperation
    let parseOperation: ParseDetailsOperation
    
    fileprivate var hasProducedAlert = false

    /**
     - parameter detailsPresenter: The class or struct where parsed data will present there. This presenter must conform to FetchedDetailsDelegate protocol.
     */

    init(detailsPresenter: FetchedDetailsDelegate) {
        let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cacheFile = cachesFolder.appendingPathComponent("ClassicPhotosDictionary.plist")

        /*
         This operation is made for two child operation:
         1. The operation to download the plist feed
         2. The operation to parse the plist feed and insert the elements into the Core Data store
         */

        downloadOperation = DownloadDetailsOperation(cacheFile: cacheFile)
        parseOperation = ParseDetailsOperation(cacheFile: cacheFile, presenter: detailsPresenter)
        
        // These operations must be executed in order
        parseOperation.addDependency(downloadOperation)

        super.init(operations: [downloadOperation, parseOperation])
        
        name = "Get Details"
    }
    
    
    override func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [NSError]) {
        if let firstError = errors.first, (operation === downloadOperation || operation === parseOperation) {
            produceAlert(firstError)
        }
    }
    
    fileprivate func produceAlert(_ error: NSError) {
        /*
         We only want to show the first Error, since subsequent errors might be caused
         by the first.
         */
        if hasProducedAlert { return }
        
        let alert = AlertOperation()
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
        //These are example of errors for which we might choose to display an error to the user
        let failedReachability = (OperationErrorDomain, OperationErrorCode.conditionFailed, ReachabilityCondition.name)
        
        let failedJSON = (NSCocoaErrorDomain, NSPropertyListReadCorruptError, nil as String?)
        
        switch errorReason {
        case failedReachability:
            // We failed because the network isn't reachable.
            let hostURL = error.userInfo[ReachabilityCondition.hostKey] as! URL
            
            alert.title = "Unable to Connect"
            alert.message = "Cannot connect to \(hostURL.host!). Make sure your device is connected to the internet and try again."
        case failedJSON:
            // We failed because the JSON was malformed.
            alert.title = "Unable to Download"
            alert.message = "Cannot Download data. try again later."
        default:
            return
        }
        
        produceOperation(alert)
        hasProducedAlert = true
    }
}

// Operators to use in the switch statement.
private func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~=(lhs: (String, OperationErrorCode, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}

