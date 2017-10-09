/*
  PhotoRecord.swift
  ClassicPhotos

  Created by Seyed Samad Gholamzadeh on 7/15/1396 AP.
  Copyright © 1396 AP raywenderlich. All rights reserved.
 
 Abstract:
     This file contains model struct of the app.
*/

import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new, downloaded, filtered, failed
}

/// A struct to represent a parsed photo details.
struct PhotoRecord {
    //MARK: Properties

    let name:String
    let url: URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    
    //MARK: Initializer
    
    init(name:String, url: URL) {
        self.name = name
        self.url = url
    }
}


