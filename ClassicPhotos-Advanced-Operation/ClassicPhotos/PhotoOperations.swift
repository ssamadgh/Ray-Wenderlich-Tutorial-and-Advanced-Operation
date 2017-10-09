//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Seyed Samad Gholamzadeh on 11/26/1395 AP.
//  Copyright © 1395 AP raywenderlich. All rights reserved.
//

import Foundation
import UIKit


struct PendingOperations {
    
    lazy var downloadsInProgress = [IndexPath : Foundation.Operation]()
    lazy var downloadQueue: Foundation.OperationQueue = {
        
        var queue = Foundation.OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        
    }()
    
    lazy var filtrationsInProgress = [IndexPath : Foundation.Operation]()
    lazy var filtrationQueue: Foundation.OperationQueue = {
        
        var queue = Foundation.OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        
    }()
}

final class ImageDownloader: Foundation.Operation {
    //1
    var photoRecord: PhotoRecord
    let completion: ((PhotoRecord) -> Void)?
    //2
    init(photoRecord: PhotoRecord, completion: ((PhotoRecord) -> Void)? = nil) {
        self.photoRecord = photoRecord
        self.completion = completion
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        //5

        let task = URLSession.shared.dataTask(with: self.photoRecord.url) { (data, response, error) in

            //7
            if let data = data {
                self.photoRecord.image = UIImage(data:data)
                self.photoRecord.state = .downloaded
            }
            else
            {
                self.photoRecord.state = .failed
                self.photoRecord.image = UIImage(named: "Failed")
            }
            self.completion?(self.photoRecord)

        }
        task.resume()
//        let imageData = try! Data(contentsOf: self.photoRecord.url)
        
        //6
        if self.isCancelled {
            return
        }
        
    }
}


final class ImageFiltration: Foundation.Operation {
    var photoRecord: PhotoRecord
    let completion: ((PhotoRecord) -> Void)?

    init(photoRecord: PhotoRecord, completion: ((PhotoRecord) -> Void)? = nil) {
        self.photoRecord = photoRecord
        self.completion = completion
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        if self.photoRecord.state != .downloaded {
            return
        }
        
        if let filteredImage = self.applySepiaFilter(image: self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .filtered
        }
        completion?(photoRecord)
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




