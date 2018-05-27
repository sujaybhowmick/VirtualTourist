//
//  Client+Extension.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/27/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//

extension Client {
    
    // MARK: - Flickr
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
        static let Page = "page"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "51ae1397154026f64620ed6ede39348b"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" // true
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1" // true
        static let PhotosPerPage = 30
        static let AccuracyCityLevel = "11"
        static let AccuracyStreetLevel = "16"
    }
}

