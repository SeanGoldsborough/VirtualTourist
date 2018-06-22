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

extension CollectionViewController : UICollectionViewDataSource {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("the photo album array count in # of items in section is: \(photoAlbum.count)")
        print("Get numberOfItemsInSection", section, photoAlbum.count, fetchedResultsController.sections![section].numberOfObjects)
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        performUpdatesOnMain {
            self.setupCell(cell, atIndexPath: indexPath)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let collViewCell = cell as! CollectionViewCell
        collViewCell.imageUrl = photo.photoURL!
        
        setImage(using: collViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        let photo = fetchedResultsController.object(at: forItemAt)
    }
    
    private func setImage(using cell: CollectionViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.photoData {
            cell.overlayView.isHidden = true
            cell.activityIndicator.stopAnimating()
            cell.cellImage.image = UIImage(data: Data(referencing: imageData))
        } else {
            if let imageUrl = photo.photoURL {
                cell.activityIndicator.startAnimating()
                FlickrAPIClient.sharedInstance().getImage(urlString: imageUrl, completionHandler: { (data, error) in
                    
                    if let _ = error {
                        performUpdatesOnMain {
                            cell.overlayView.isHidden = true
                            cell.activityIndicator.stopAnimating()
                        }
                        return
                    } else if let data = data {
                        performUpdatesOnMain {
                            
                            if let currentCell = collectionView.cellForItem(at: index) as? CollectionViewCell {
                                if currentCell.imageUrl == imageUrl {
                                    currentCell.cellImage.image = UIImage(data: data as Data)
                                    cell.overlayView.isHidden = true
                                    cell.activityIndicator.stopAnimating()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        self.context.delete(photoToDelete)
        self.appDelegate.saveContext()
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

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
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
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


