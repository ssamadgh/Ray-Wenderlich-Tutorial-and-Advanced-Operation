//
//  FilterPhotoOperation.swift
//  ClassicPhotos
//
//  Created by Seyed Samad Gholamzadeh on 7/16/1396 AP.
//  Copyright © 1396 AP raywenderlich. All rights reserved.
//

import UIKit

final class FilterPhotoOperation: Operation {
    // MARK: Properties
    
    var photoRecord: PhotoRecord
    let presenter: FetchedDetailsDelegate
    let indexPath: IndexPath
    
    // MARK: Initialization
    
    init(photoRecord: PhotoRecord, indexPath: IndexPath, presenter: FetchedDetailsDelegate) {
        assert(photoRecord.state == .downloaded, "photo state must be downloaded to filter its data")

        self.photoRecord = photoRecord
        self.presenter = presenter
        self.indexPath = indexPath
        
        super.init()
        
        name = "Filter OPeration"
    }
    
    override func execute() {
        if self.photoRecord.state != .downloaded {
            finish()
        }
        
        if let filteredImage = self.applySepiaFilter(image: self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .filtered
        }

        self.presenter.photoFiltered(photoRecord: self.photoRecord, at: indexPath)
        
        finish()
    }
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter?.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }

    
}
