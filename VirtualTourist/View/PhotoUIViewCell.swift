//
//  PhotoCellUIView.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/28/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//

import UIKit

class PhotoUIViewCell: UICollectionViewCell {
    static let identifier = "PhotoViewCell"
    
    var imageUrl: String = ""
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
}

