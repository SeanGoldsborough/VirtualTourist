//
//  CollectionVCExtensions.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 6/17/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

fileprivate let itemsPerRow: CGFloat = 3

fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 50.0, right: 20.0)

private let reuseIdentifier = "CollectionItem"

extension CollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Get numberOfItemsInSection", section, photoAlbum.count, fetchedResultsController.sections![section].numberOfObjects)
        
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
            cell.cellImage.image = nil
            cell.activityIndicator.startAnimating()
            cell.overlayView.isHidden = false
        //print("number of cells is now \(indexPath.row)")

        performUpdatesOnMain {
            cell.cellImage.image = nil
            cell.activityIndicator.startAnimating()
            cell.overlayView.isHidden = false
        }
        
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let collViewCell = cell as! CollectionViewCell
        collViewCell.imageUrl = photo.photoURL!
     
        //TODO: configCollViewCellImage here
        //setupPhoto(cell: collViewCell, photo: photo, collectionView: collectionView, indexPath: indexPath)
        performUpdatesOnMain {
            self.configImage(cell: collViewCell, photo: photo, collectionView: collectionView, indexPath: indexPath)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        self.context.delete(photoToDelete)
        self.appDelegate.saveContext()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt: IndexPath) {
//        TODO:  CAN PROBABLY DELETE THIS!
//        let collViewCell = cell as! CollectionViewCell
//        collViewCell.activityIndicator.stopAnimating()
//        collViewCell.overlayView.isHidden = true
//        self.appDelegate.saveContext()

        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
//        let collViewCell = cell as! CollectionViewCell
//        //photo.photoData = NSData(data: photo.photoData! as Data)
//        collViewCell.cellImage.image = UIImage(data: photo.photoData! as Data)
        
        
        if let imageUrl = photo.photoURL {
            //Client.shared().cancelDownload(imageUrl)
            
            //TODO: func to stop downloading here
        }
    }
    
    private func configImage(cell: CollectionViewCell, photo: Photo, collectionView: UICollectionView, indexPath: IndexPath) {

        if let imageData = photo.photoData {
            cell.activityIndicator.stopAnimating()
            cell.overlayView.isHidden = true
            cell.cellImage.image = UIImage(data: Data(referencing: imageData))
        } else {
            if let imageUrl = photo.photoURL {
                cell.activityIndicator.startAnimating()
                cell.overlayView.isHidden = false
                
                    FlickrAPIClient.sharedInstance().getImage(urlString: imageUrl, completionHandler: { (data, error) in
                        if let _ = error {
                            performUpdatesOnMain {
                                cell.activityIndicator.stopAnimating()
                                cell.overlayView.isHidden = true
                                AlertView.alertPopUp(view: self, alertMessage: "Unable to download images. Please try again. Error: \(error!.localizedDescription)")
                            }
                            return
                        } else if let data = data {
                            performUpdatesOnMain {
                                
                                if let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                                    if currentCell.imageUrl == imageUrl {
                                        currentCell.cellImage.image = UIImage(data: data as Data)
                                        cell.activityIndicator.stopAnimating()
                                        cell.overlayView.isHidden = true
                                    }
                                }
                               photo.photoData = NSData(data: data as Data)
                                
                                DispatchQueue.global(qos: .background).async {
                                    self.appDelegate.saveContext()                                    
                                }
                            }
                        }
                    })

                }
            }
        }
    }
// MARK: - Helpers

//private func configImage(using cell: PhotoViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
//
//    if let imageData = photo.image {
//        cell.activityIndicator.stopAnimating()
//        cell.imageView.image = UIImage(data: Data(referencing: imageData))
//    } else {
//        if let imageUrl = photo.imageUrl {
//            cell.activityIndicator.startAnimating()
//            Client.shared().downloadImage(imageUrl: imageUrl) { (data, error) in
//                if let _ = error {
//                    self.performUIUpdatesOnMain {
//                        cell.activityIndicator.stopAnimating()
//                        self.errorForImageUrl(imageUrl)
//                    }
//                    return
//                } else if let data = data {
//                    self.performUIUpdatesOnMain {
//
//                        if let currentCell = collectionView.cellForItem(at: index) as? PhotoViewCell {
//                            if currentCell.imageUrl == imageUrl {
//                                currentCell.imageView.image = UIImage(data: data)
//                                cell.activityIndicator.stopAnimating()
//                            }
//                        }
//                        photo.image = NSData(data: data)
//                        DispatchQueue.global(qos: .background).async {
//                            self.save()
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
//        guard let url = URL(string: imageUrl) else {
//            return
//        }
//        let task = taskForGETMethod(nil, url, parameters: [:]) { (data, error) in
//            result(data, error)
//            self.tasks.removeValue(forKey: imageUrl)
//        }
//
//        if tasks[imageUrl] == nil {
//            tasks[imageUrl] = task
//        }
//    }
//
//    func cancelDownload(_ imageUrl: String) {
//        tasks[imageUrl]?.cancel()
//        if tasks.removeValue(forKey: imageUrl) != nil {
//            print("\(#function) task canceled: \(imageUrl)")
//        }
//    }
//}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension CollectionViewController:NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        deletedIndexPaths = [IndexPath]()
        insertedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move called.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
}
