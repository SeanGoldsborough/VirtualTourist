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
    
    var imageUrl: String = ""
}

