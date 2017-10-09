/*
  ParseDetails.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/15/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 
 Abstract:
 Contains the logic to parse a plist file of photos details and insert them into an PhotoRecord struct.

*/

import Foundation
/**
     A protocol which will notify the presenter for receiving photos details
     - note: The presenter for photos must be conformed to this protocol.
*/
protocol FetchedDetailsDelegate {
/**

    This method must be called into `ParseDetailsOperation`
     to notify the conformed presenter about photos data.
*/
    func fetched(_ photoRecords: [PhotoRecord])
    
    /// Notify downloaded photo to the presenter
    func photoDownloaded(photoRecord: PhotoRecord, at indexPath: IndexPath)
    
    /// Notify filtered photo to the presenter
    func photoFiltered(photoRecord: PhotoRecord, at indexPath: IndexPath)
}

/// An `Operation` to parse photos details out of a downloaded data.
final class ParseDetailsOperation: Operation {
    
    let cacheFile: URL
    let presenter: FetchedDetailsDelegate

    /**
     - parameter cacheFile: The file `URL` from which to load photos data.
     - parameter presenter: The presenter which conforms to `FetchedDetailsDelegate` and will present photos details.
     */
    init(cacheFile: URL, presenter: FetchedDetailsDelegate) {
        self.cacheFile = cacheFile
        self.presenter = presenter
        
        super.init()
        
        name = "Parse Details"
    }
    
    override func execute() {
        guard let stream = InputStream(url: cacheFile) else  {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }

        do {
            let plist = try PropertyListSerialization.propertyList(with: stream, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as? [String: String]
            
            if let photoRecords = plist {
                self.parse(photoRecords)
            }
            else {
                finish()
            }

        }
        catch let plistError as NSError {
            finishWithError(plistError)
        }
    }
    
    fileprivate func parse(_ dic: [String: String]) {
        let photoRecords = dic.filter {$0.value != "NO URL" }.flatMap{ PhotoRecord(name: $0.key, url: URL(string: $0.value)!)}
        
        // Here we calling the `FetchedDetailsDelegate` method to notify presenter for fetched photo details.
        self.presenter.fetched(photoRecords)
        self.finish()
    }
    
}
