//
//  CollectionVC.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.

import Foundation
import UIKit
import MapKit
import CoreData

fileprivate let itemsPerRow: CGFloat = 3

fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 50.0, right: 20.0)

class CollectionViewController: UIViewController, MKMapViewDelegate {
    
    var urlArray = [String]()
    
    var photos: [NSManagedObject] = []
    
    var blockOperations: [BlockOperation] = []
    
    //var dataController:DataController!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
    
//    var sharedContext: NSManagedObjectContext {
//        return dataController.viewContext
//    }
    
    var pin: Pin? = nil
    
    var indexPathToRemove = [IndexPath]()
    
    var passedPin: Pin!
    var photoAlbum = [Photo]()
    
    var randomNumberResults: Int?
    
    var collCell = CollectionViewCell()
    private let reuseIdentifier = "CollectionItem"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapViewColl: MKMapView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBAction func refreshRemoveButton(_ sender: Any) {
        
        randomNumber(start: 1, to: 25)
        
        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (photos, error) in
            print("refresh button has been pressed")
            print("page number is \(self.randomNumberResults)")
            print("getFlickrPhotos cvc results are \(photos)")
            
            performUpdatesOnMain {
                //self.photoAlbum.removeAll()
                self.removeAllPhotos()
                //self.photosArray.removeAll()
                self.bottomButton.isEnabled = false
            }
            
            if let thesePhotos = photos {
                self.urlArray.removeAll()
                self.urlArray = photos!
                print("photos are in!")
                print("url array is: \(self.urlArray)")
                
                performUpdatesOnMain {
                    self.collectionView.reloadData()
                    self.bottomButton.isEnabled = true
                    self.saveContext()
                }
                
            } else {
                print(error ?? "error on refreshing photos")
                performUpdatesOnMain {
                    AlertView.alertPopUp(view: self, alertMessage: "No Photos Found")
                }
            }
        }
    }
    
    func randomNumber(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        if a > b {
            swap(&a, &b)
        }
        self.randomNumberResults = Int(arc4random_uniform(UInt32(b - a + 1))) + a
        print("page number again is \(randomNumberResults)")
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    func getPhotosFromFlickr(pageNumber: Int) {
        
        var photoTemp: Photo?
        
        FlickrAPIClient.sharedInstance().getFlickrPhotos(lat: "\(self.passedPin.latitude)", long: "\(self.passedPin.longitude)", pageNum: self.randomNumberResults!, chosenPin: self.passedPin) { (photos, error) in
            
            //            for url in photos! {
            //                // photo = Photos(creationDate: Date, photoData: passedPin!, photoURL: url, pin: passedPin, context: self.dataController.viewContext)
            //                //Photos(entity: Photos.entity(), insertInto: self.dataController.viewContext)
            //                //self.urlArray.append(url)
            //            }
            //            self.urlArray = photos!
            //
            //            do {
            //                try self.dataController.viewContext.save()
            //            } catch {
            //                print("Error saving the url")
            //            }
            
            
            DispatchQueue.main.async {
                
                for photo in photos! {
                    let context = self.context
                    if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                        photoTemp = Photo(entity: entity, insertInto: context)
                        //photoTemp?.photoURL = photo["url_m"] as? String
                        photoTemp?.pin = self.pin!
                    }
                }
                do { try? self.context.save() } catch {
                    print("Error saving deletion")
                }
                print("RELOADING DATA...")
                self.photoAlbum = self.photosFetchRequest()
                self.collectionView.reloadData()
            }
            
            performUpdatesOnMain {
                self.collectionView.reloadData()
                self.saveContext()
            }
        }
    }
    
    //TODO: IS THIS ACTUALLY THE BEST WAY TO PERFORM A FETCH?!?!?!?
    private func performPhotosFetch() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", passedPin)
        // fetchRequest:NSFetchRequest<Photo> = NSFetchRequest<Photo>(entityName: "Photo")
        
        do {
            
            photoAlbum = (try fetchedResultsController.fetchedObjects)!
            print("photo album count is: \(photoAlbum.count)")
            
            if photoAlbum.count > 0 {
                let photos = photoAlbum[0]
                photoAlbum.append(photos)
                print("dtc2 of fetch\(fetchedResultsController.fetchedObjects?.count)")
            }
            performUpdatesOnMain {
                self.collectionView.reloadData()
                self.saveContext()
            }
            
        } catch {
            print("ERROR\(error.localizedDescription)")
        }
    }
    
    func photosFetchRequest() -> [Photo] {
        
        print("Fetching Photos...")
        
        // Get the saved Photos
        do {
            return try context.fetch(fetchRequest) as! [Photo]
            //return try
        } catch {
            print("There was an error fetching the list of pins.")
            return [Photo]()
        }
    }
    
    
    
    func removeAllPhotos() {
        
        for object in fetchedResultsController.fetchedObjects! {
//            dataController.viewContext.delete(object as! Photo)
            context.delete(object as! Photo)
        }
    }
    
//    func initializeFetchedResultsController() {
//        //        let request = NSFetchRequest(entityName: "Photos")
//        let request:NSFetchRequest<Photo> = Photo.fetchRequest()
//        let creationDateSort = NSSortDescriptor(key: "creationDate", ascending: true)
//        request.sortDescriptors = [creationDateSort]
//        let moc = context  //managedObjectContext
////        let moc = dataController.viewContext  //managedObjectContext
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "creationDate", cacheName: nil)
//        fetchedResultsController.delegate = self
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("Failed to initialize FetchedResultsController: \(error)")
//        }
//    }
//
//    fileprivate func setupFetchedResultsController() {
//        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
//        //        let predicate = NSPredicate(format: "pin == %@", self.passedPin)
//        //        fetchRequest.predicate = predicate
//        let sortDescriptor = NSSortDescriptor(key: "photoURL", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        //        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(passedPin)-photos")
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//            print("dtc of fetch\(fetchedResultsController.fetchedObjects?.count)")
//        } catch {
//            fatalError("could not fetch: \(error.localizedDescription)")
//        }
//    }
    
    fileprivate func setupFetchedResultsController() {
        
        let entityName = String(describing: Photo.self)
        let fetchRequest = NSFetchRequest<Photo>(entityName: entityName)
        //      let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", passedPin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsController.delegate = self
        
        if let result = try? context.fetch(fetchRequest) {
            photoAlbum = result
            for photos in photoAlbum {
                //addAnnotationCoordinate(pins)
                //print("fetched pins photos are\(pins.photos?.count)")
            }
        }
        
        do {
            try fetchedResultsController.performFetch()
            print("fetch successful")
            
        } catch {
            //fatalError("could not fetch: \(error.localizedDescription)")
            AlertView.alertPopUp(view: self, alertMessage: "could not fetch: \(error.localizedDescription)")
        }
        
        let fetchCount = try? context.count(for: fetchRequest)
        
        print("data controller on Map VC contains: \(fetchCount) Pin objects")
        
    }
    
    func saveContext() {
        do {
            try? context.save()
        }catch {
            AlertView.alertPopUp(view: self, alertMessage: "ERROR: Unable to save context")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomNumber(start: 1, to: 50)
        
        navigationItem.rightBarButtonItem = editButtonItem
        self.collCell.isSelected == false
        self.bottomButton.isEnabled = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView?.allowsMultipleSelection = true
        
        mapViewColl.delegate = self
        
        let passedPinLocation = CLLocation(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
        let regionRadius: CLLocationDistance = 1000000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius, regionRadius)
            mapViewColl.setRegion(coordinateRegion, animated: true)
        }
        
        centerMapOnLocation(location: passedPinLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.passedPin.latitude, longitude: self.passedPin.longitude)
        mapViewColl.addAnnotation(annotation)
        
        
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.passedPin!)
        
        //self.initializeFetchedResultsController()
        setupFetchedResultsController()
        //photosFetchRequest()
        
        performUpdatesOnMain {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

// MARK: - Navigation

extension CollectionViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return 1
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let fetchedRC = fetchedResultsController
        return fetchedResultsController.sections![0].numberOfObjects
        //return photoAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //print("cellForItemAt func actualally waorks!!!")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        //        // Cleanup reused cell
        //       performUpdatesOnMain {
        //            cell.cellImage.image = nil
        //        }
        
        // Check if saved data exists in coredata
        //        if let imageURL = self.photoAlbum[indexPath.item].photoURL {
        //            print("Loading new photo from coredata")
        //
        ////            performUpdatesOnMain {
        ////                FlickrAPIClient.sharedInstance().getImage(urlString: imageURL, completionHandler: results, Error) {
        ////                let imageData = try Data(contentsOf: url!)
        ////                if let image = UIImage(data: imageData as Data) {
        ////                    cell.cellImage.image = image
        ////                    // stop animating here
        ////                    cell.activityIndicator.stopAnimating()
        ////                }
        ////            }
        ////            }
        //        } else {
        //            print("Loading new photo from web URL link(s)")
        //            cell.activityIndicator.startAnimating()
        //            FlickrAPIClient.sharedInstance().loadNewPhoto(indexPath, photosArray: self.photoAlbum) { (image, data, error) in
        //                guard error == nil else{
        //                    AlertView.alertPopUp(view: self, alertMessage: "error coll cell vc")
        //                    return
        //                }
        //                performUpdatesOnMain {
        //                    cell.cellImage.image = image
        //                    cell.activityIndicator.stopAnimating()
        //                }
        //                self.photoAlbum[indexPath.item].photoData = data
        //
        //                // Save data
        //                do { try self.saveContext() } catch {
        //                    print("Error saving photo data")
        //                }
        //            }
        //        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        print("didSelect func actualally waorks!!!")
        
        if editButtonItem.title == "Done" {
            print("edit button works!")
            
        } else if editButtonItem.title == "Edit" {
            print("edit button not yet working")
        }
        
        let indexPaths = collectionView.indexPathsForSelectedItems!
        print(indexPaths)
        
        let index = self.collectionView.indexPathsForSelectedItems?.first
        print("coll vc didSelect func index is \(index)")
        
        performUpdatesOnMain {
            //self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
        }
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

//EXTENSION DELEGATE TO GET CONTROLLER TO EXCECUTE DELETION CODE ON VIEW (CELL)
extension CollectionViewController: CollectionViewCellDelegate {
    func delete(cell: CollectionViewCell) {
        if editButtonItem.title == "Done" {
            //            collCell.isSelected == true
            //            collCell.isEditing == true
            
            if let indexPath = collectionView?.indexPath(for: cell) {
                //TODO COMMENTED OUT PHOTO ALBUM AS PER VIDEO 8 IN SIMPLIFYING CORE DATA LESSON
                //let item = photoAlbum[indexPath.item]
                // delete photo from data source?
                //photosArray.remove(at: indexPath.item)
                //TODO: FIX THIS!!!
                //            let photoToDelete = fetchedResultsController.object(at: indexPath)
                //                dataController.viewContext.delete(photoToDelete)
                //                try? dataController.viewContext.save()
            }
        } else {
            //            collCell.isSelected == false
            //            collCell.isEditing == false
        }
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
//  EXTENSION TO DOWNLOAD IMAGE DATA FROM IMAGE URL
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

//extension CollectionViewController: NSFetchedResultsControllerDelegate {
//  //TODO FIX TO MEME
//    func fetchedRCSearch() {
//        if let fetchedRC = fetchedResultsController {
//            do {
//                try fetchedRC.performFetch()
//            } catch let e as NSError {
//               AlertView.alertPopUp(view: self, alertMessage: "error on fetch")
//            }
//        }
//    }
//
////    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//////        collectionView.beginUpdates()
//////        collectionView.updateUserActivityState()
//////        collectionView.beginInteractiveMovementForItem(at: indexPath)
////    }
////
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            self.collectionView.insertItems(at: [newIndexPath!])
//        case .delete:
//            self.collectionView.deleteItems(at: [newIndexPath!])
//        default:
//            break
//        }
//    }
//}

extension CollectionViewController:NSFetchedResultsControllerDelegate {
    
    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    //        switch type {
    //        case .insert:
    //            collectionView.insertItems(at: [newIndexPath!])
    //            break
    //        case .delete:
    //            collectionView.deleteItems(at: [indexPath!])
    //            break
    //        case .update:
    //            collectionView.reloadItems(at: [indexPath!])
    //        case .move:
    //            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
    //        }
    //    }
    //
    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    //        let indexSet = IndexSet(integer: sectionIndex)
    //        switch type {
    //        case .insert: collectionView.insertSections(indexSet)
    //        case .delete: collectionView.deleteSections(indexSet)
    //        case .update, .move:
    //            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
    //        }
    //    }
    //
    //
    //    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //        collectionView.beginUpdates()
    //        collectionView.
    //    }deinit
    //
    //    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //        collectionView.endUpdates()
    //    }
    
    //https://gist.github.com/nazywamsiepawel/e88790a1af1935ff5791c9fe2ea19675
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    //    deinit {
    //        for operation: BlockOperation in blockOperations {
    //            operation.cancel()
    //        }
    //
    //        blockOperations.removeAll(keepingCapacity: false)
    //    }
    
    
}



