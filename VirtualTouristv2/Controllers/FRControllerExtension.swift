////
////  FRControllerExtension.swift
////  VirtualTouristv2
////
////  Created by Sean Goldsborough on 4/29/18.
////  Copyright © 2018 Sean Goldsborough. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//
//extension NSFetchedResultsControllerDelegate {
//    
//    //https://gist.github.com/nazywamsiepawel/e88790a1af1935ff5791c9fe2ea19675
//    //might need this stuff:
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        if type == NSFetchedResultsChangeType.insert {
//            print("Insert Object: \(newIndexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertItems(at: [newIndexPath!])
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.update {
//            print("Update Object: \(indexPath)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.move {
//            print("Move Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.delete {
//            print("Delete Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//    }
//    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        
//        
//        if type == NSFetchedResultsChangeType.insert {
//            print("Insert Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.update {
//            print("Update Section: \(sectionIndex)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == NSFetchedResultsChangeType.delete {
//            print("Delete Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView!.performBatchUpdates({ () -> Void in
//            for operation: BlockOperation in self.blockOperations {
//                operation.start()
//            }
//        }, completion: { (finished) -> Void in
//            self.blockOperations.removeAll(keepingCapacity: false)
//        })
//    }
//}
//
