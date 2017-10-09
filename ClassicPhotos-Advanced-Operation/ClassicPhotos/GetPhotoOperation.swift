/*
  GetPhotoOperation.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/16/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 Abstract:
     This file contain operation which manages photos downloading and filtering.
*/

import Foundation

/// A composite `Operation` to both download and filtering a photo.
final class GetPhotoOperation: GroupOperation {
    //MARK: Properties
    let photoOperation: Operation?
    
    init(photoRecord: PhotoRecord, indexPath: IndexPath, presenter: FetchedDetailsDelegate) {
        
        if photoRecord.state == .new {
            photoOperation = DownloadPhotoOperation(photoRecord: photoRecord, indexPath: indexPath, presenter: presenter)
        }
        else if photoRecord.state == .downloaded {
            photoOperation = FilterPhotoOperation(photoRecord: photoRecord, indexPath: indexPath, presenter: presenter)
        }
        else {
            photoOperation = nil
        }
        
        if let operation = photoOperation {
            super.init(operations: [operation])
        }
        else {
            super.init(operations: [])
        }
        
        name = "Get Photo"
    }
    
}
