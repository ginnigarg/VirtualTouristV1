//
//  Constants.swift
//  VirtualToursit(V1)
//
//  Created by Guneet Garg on 09/05/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

struct Constants {
    
    struct Flickr {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest/"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let GalleryId = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    struct ParameterValues {
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryId = "5704-72157622566655097"
    }
    
}
