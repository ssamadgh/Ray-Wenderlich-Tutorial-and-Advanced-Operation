/*
  DownloadPhotoOperation.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/16/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 
 Abstract:
 this file contains the code to download the photo.

*/

import UIKit

final class DownloadPhotoOperation: GroupOperation {
    //MARK: Properties
    
    var photoRecord: PhotoRecord
    let indexPath: IndexPath
    let presenter: FetchedDetailsDelegate
    
    init(photoRecord: PhotoRecord, indexPath: IndexPath, presenter: FetchedDetailsDelegate) {
        assert(photoRecord.state == .new, "photo state must be new to download its data")

        self.photoRecord = photoRecord
        self.indexPath = indexPath
        self.presenter = presenter
        
        super.init(operations: [])
        name = "Download Details"
        
        let task = URLSession.shared.dataTask(with: photoRecord.url) { (data, response, error) in
            if let data = data {
                self.photoRecord.image = UIImage(data:data)
                self.photoRecord.state = .downloaded

            }
            else
            {
                if !self.isCancelled {
                    self.photoRecord.state = .failed
                    self.photoRecord.image = UIImage(named: "Failed")
                }
            }

           self.downloadFinished(phoroRecord: photoRecord, at: indexPath, error: error as NSError?)
            return()
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
//        let reachabilityCondition = ReachabilityCondition(host: photoRecord.url)
//        taskOperation.addCondition(reachabilityCondition)

        addOperation(taskOperation)
    }
    
    func downloadFinished(phoroRecord: PhotoRecord, at indexPath: IndexPath, error: NSError?) {
        self.presenter.photoDownloaded(photoRecord: photoRecord, at: indexPath)
    }
}
