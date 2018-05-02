//
//  CollectionViewCell.swift
//  VirtualTouristv2
//
//  Created by Sean Goldsborough on 4/2/18.
//  Copyright © 2018 Sean Goldsborough. All rights reserved.
//
//
//  CollectionViewCell.swift
//  VirtualTouristV1
//
//  Created by Sean Goldsborough on 11/26/17.
//  Copyright © 2017 Sean Goldsborough. All rights reserved.
//
import UIKit

protocol CollectionViewCellDelegate: class {
    func delete(cell: CollectionViewCell)
}

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    weak var delegate: CollectionViewCellDelegate?
////
//        func displayContent(image: UIImage) {
//            cellImage.image = image
//            //overlayView.isHidden = false
//            activityIndicator.isHidden = false
//            activityIndicator.startAnimating()
//        }
//
//        // MARK: - Properties
//        override var isSelected: Bool {
//            didSet {
//                //isEditing = true
//                cellImage.alpha = isSelected ? 0.5 : 1.0
//                delegate?.delete(cell: self)
//          }
//        }
//
//
////        var isEditing: Bool = false {
////            didSet{
////                delegate?.delete(cell: self)
////            }
////        }
//
//         //MARK: - View Life Cycle
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            cellImage.alpha = 1.0
//            isSelected = false
//            //isEditing = true
//            overlayView.isHidden = false
//            activityIndicator.startAnimating()
//            activityIndicator.isHidden = false
//        }
}

