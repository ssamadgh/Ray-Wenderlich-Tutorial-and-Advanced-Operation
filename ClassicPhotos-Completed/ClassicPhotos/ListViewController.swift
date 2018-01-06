//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UITableViewController {
	
	//  lazy var photos = NSDictionary(contentsOf:dataSourceURL!)!
	var photos = [PhotoRecord]()
	let pendingOperations = PendingOperations()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Classic Photos"
		fetchPhotoDetails()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// #pragma mark - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
		
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
		case .failed:
			indicator.stopAnimating()
			cell.textLabel?.text = "Failed to load"
		case .new, .downloaded:
			indicator.startAnimating()
			if (!tableView.isDragging && !tableView.isDecelerating) {
				self.startOperationsForPhotoRecord(photoDetails, indexPath: indexPath)
			}
		}
		return cell
	}
	
	func fetchPhotoDetails() {
		let request = URLRequest(url: dataSourceURL!)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if data != nil {
				let datasourceDictionary = try? PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as! NSDictionary
				
				for (key, value) in datasourceDictionary! {
					let name = key as? String
					let url = URL(string:value as? String ?? "")
					if name != nil && url != nil {
						let photoRecord = PhotoRecord(name:name!, url:url!)
						self.photos.append(photoRecord)
					}
				}
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
			
			if error != nil {
				let alert = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
				alert.addAction(action)
				self.present(self, animated: true, completion: nil)
			}
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			}.resume()
		
	}
	
	
	
	func startOperationsForPhotoRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
		switch (photoDetails.state) {
		case .new:
			startDownloadForRecord(photoDetails, indexPath: indexPath)
		case .downloaded:
			startFiltrationForRecord(photoDetails, indexPath: indexPath)
		default:
			NSLog("do nothing")
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
	
	
	func startDownloadForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
		//1
		if pendingOperations.downloadsInProgress[indexPath] != nil {
			return
		}
		
		//2
		let downloader = ImageDownloader(photoRecord: photoDetails)
		
		//3
		downloader.completionBlock = {
			if downloader.isCancelled {
				return
			}
			DispatchQueue.main.async(execute: {
				self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
				self.tableView.reloadRows(at: [indexPath], with: .fade)
			})
		}
		//4
		pendingOperations.downloadsInProgress[indexPath] = downloader
		//5
		pendingOperations.downloadQueue.addOperation(downloader)
		
	}
	
	
	func startFiltrationForRecord(_ photoDetails: PhotoRecord, indexPath: IndexPath){
		if pendingOperations.filtrationsInProgress[indexPath] != nil{
			return
		}
		
		let filterer = ImageFiltration(photoRecord: photoDetails)
		filterer.completionBlock = {
			if filterer.isCancelled {
				return
			}
			DispatchQueue.main.async(execute: {
				self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
				self.tableView.reloadRows(at: [indexPath], with: .fade)
			})
		}
		pendingOperations.filtrationsInProgress[indexPath] = filterer
		pendingOperations.filtrationQueue.addOperation(filterer)
	}
	
	func suspendAllOperations () {
		pendingOperations.downloadQueue.isSuspended = true
		pendingOperations.filtrationQueue.isSuspended = true
	}
	
	func resumeAllOperations () {
		pendingOperations.downloadQueue.isSuspended = false
		pendingOperations.filtrationQueue.isSuspended = false
	}
	
	func loadImagesForOnscreenCells () {
		//1
		if let pathsArray = tableView.indexPathsForVisibleRows {
			//2
			var allPendingOperations = Set(Array(pendingOperations.downloadsInProgress.keys))
			allPendingOperations = allPendingOperations.union(Array(pendingOperations.filtrationsInProgress.keys))
			
			//3
			var toBeCancelled = allPendingOperations
			let visiblePaths = Set(pathsArray)
			toBeCancelled.subtract(visiblePaths)
			
			//4
			var toBeStarted = visiblePaths
			toBeStarted.subtract(allPendingOperations)
			
			// 5
			for indexPath in toBeCancelled {
				if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
					pendingDownload.cancel()
				}
				pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
				if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
					pendingFiltration.cancel()
				}
				pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
			}
			
			// 6
			for indexPath in toBeStarted {
				let indexPath = indexPath as IndexPath
				let recordToProcess = self.photos[indexPath.row]
				startOperationsForPhotoRecord(recordToProcess, indexPath: indexPath)
			}
		}
	}
	
	
	
	
}
