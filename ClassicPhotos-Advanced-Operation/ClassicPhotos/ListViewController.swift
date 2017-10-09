//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage


class ListViewController: UITableViewController, FetchedDetailsDelegate {
    
    // MARK: - Properties
    
    var photos = [PhotoRecord]()
    
    var pendingOperations = PendingOperations()
    
    let operationQueue = OperationQueue()
    
    // MARK: - override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        
        let getDetailsOPeration = GetDetailsOperation(detailsPresenter: self)
        self.operationQueue.addOperation(getDetailsOPeration)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        //1
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2
        let photoDetails = photos[indexPath.row]
        
        //3
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4
        switch (photoDetails.state){
            
        case .filtered:
            indicator.stopAnimating()
            cell.textLabel?.isEnabled = true
            
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
            
        case .new, .downloaded:
            cell.textLabel?.isEnabled = false
            indicator.startAnimating()
        }
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    
    func suspendAllOperations () {
        guard !self.photos.isEmpty else { return }
        
        operationQueue.isSuspended = true
        operationQueue.cancelAllOperations()
    }
    
    func resumeAllOperations () {
        guard !self.photos.isEmpty else { return }

        operationQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells () {
        if let indexPaths = self.tableView.indexPathsForVisibleRows, !indexPaths.isEmpty {

            _ = indexPaths.map({ (indexPath) in
                let getPhotosOperation = GetPhotoOperation(photoRecord: photos[indexPath.row], indexPath: indexPath, presenter: self)
                self.operationQueue.addOperation(getPhotosOperation)
            })
        }
    }
    
    
    //MARK: FetchedDetailsDelegate methods
    

    func fetched(_ photoRecords: [PhotoRecord]) {
        self.photos = photoRecords
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if (!self.tableView.isDragging && !self.tableView.isDecelerating) {
                self.loadImagesForOnscreenCells()
            }
        }
    }
    
    func photoDownloaded(photoRecord: PhotoRecord, at indexPath: IndexPath) {
        self.photos[indexPath.row] = photoRecord
        DispatchQueue.main.async {
//            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
        let getPhotosOperation = GetPhotoOperation(photoRecord: photoRecord, indexPath: indexPath, presenter: self)
        self.operationQueue.addOperation(getPhotosOperation)
    }
    
    func photoFiltered(photoRecord: PhotoRecord, at indexPath: IndexPath) {
        self.photos[indexPath.row] = photoRecord
        DispatchQueue.main.async {
//                self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.reloadData()
        }
    }

}
