//
//  PhotoViewController.swift
//  VirtualToursit(V1)
//
//  Created by Guneet Garg on 09/05/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoViewController  : UIViewController , MKMapViewDelegate ,UICollectionViewDataSource , UICollectionViewDelegate , NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var geoView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar : UINavigationBar!
    
    var coreDataController : DataController!
    var coord = CLLocationCoordinate2D ()
    var client : Networking!
    var oldPins : Pin!
    var fetchedController : NSFetchedResultsController<Photo>!
    
    override func viewDidLoad () {
        super.viewDidLoad ()
        navBar.isTranslucent = false
        navBar.isHidden = false
        client = Networking (incomingPins: oldPins,incomingDataController: coreDataController)
        print("View Loaded")
        setFetchedController ()
        print("Fetched Controller first time suceesfully")
        setMapView ()
        print("Map View set up successfullt for the first time")
    }
    
    func setFetchedController () {
        let fetchRequest : NSFetchRequest<Photo>
        fetchRequest = Photo.fetchRequest ()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate (format : "pin==%@", argumentArray : [oldPins])
        fetchedController = NSFetchedResultsController (fetchRequest : fetchRequest, managedObjectContext : coreDataController.viewContext, sectionNameKeyPath : nil, cacheName : nil)
        fetchedController.delegate = self
        try?fetchedController.performFetch ()
        print(oldPins.photos?.count ?? 0)
        print("Fetch performed on fetchedController while fetching controller")
        if (oldPins.photos?.count)! == 0 {
            print("Fetching Pins")
            if client == nil {
                print("Nil")
            } else {
                client.fetchPhotos () {
                    try? self.fetchedController.performFetch ()
                }
            }
        }
    }
    
    func setMapView () {
        let span = MKCoordinateSpanMake (0.5, 0.5)
        let region = MKCoordinateRegionMake (coord, span)
        geoView.setCenter (coord, animated: true)
        geoView.setRegion (region, animated: true)
        let annotations = MKPointAnnotation ()
        annotations.coordinate = coord
        print(annotations.coordinate)
        geoView.addAnnotation(annotations)
    }
    
    func collectionView (_ collectionView : UICollectionView, numberOfItemsInSection section : Int) -> Int {
        try? fetchedController.performFetch ()
        print((fetchedController.fetchedObjects?.count)!)
        if fetchedController.fetchedObjects?.count == nil {
            return 1
        } else {
            return (fetchedController.fetchedObjects?.count)!
        }
    }
    
    func collectionView (_ collectionView : UICollectionView , cellForItemAt indexPath : IndexPath) -> UICollectionViewCell {
        try? fetchedController.performFetch ()
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier : "collectionPhotoCell", for : indexPath) as! CollectionView
        collectionCell.activityIndicator.isHidden = false
        collectionCell.activityIndicator.startAnimating()
        if ((fetchedController.fetchedObjects?.count) != nil) {
            let photos = fetchedController.object(at: indexPath)
            if photos.image != nil {
                DispatchQueue.main.async {
                    collectionCell.image.image = UIImage (data : photos.image!)
                    collectionCell.activityIndicator.stopAnimating()
                    collectionCell.activityIndicator.isHidden = true
                    return
                }
            } else {
                URLSession.shared.dataTask(with: URL(string: photos.url!)!) { (data, response, error) in
                    photos.image = data
                    DispatchQueue.main.async {
                        collectionCell.activityIndicator.stopAnimating()
                        collectionCell.activityIndicator.isHidden = true
                        collectionCell.image.image = UIImage (data : photos.image!)
                        return
                    }
                }.resume ()
            }
        }
        return collectionCell
    }
    
    func collectionView (_ collectionView : UICollectionView , didSelectItemAt indexPath : IndexPath) {
        try? fetchedController.performFetch ()
        let photo = fetchedController.object (at: indexPath)
        coreDataController.viewContext.delete (photo)
        try? coreDataController.viewContext.save ()
        collectionView.reloadData ()
    }

    func controller (_ controller : NSFetchedResultsController<NSFetchRequestResult>, didChange anObject : Any, at indexPath : IndexPath?, for type : NSFetchedResultsChangeType, newIndexPath : IndexPath?) {
        if type == .insert {
            collectionView.insertItems (at : [newIndexPath!])
        } else if type == .delete {
            collectionView.deleteItems(at : [indexPath!])
        }
    }
    
    @IBAction func refresh (_ sender : Any) {
        let fetchedResults = fetchedController.fetchedObjects
        for value in fetchedResults! {
            coreDataController.viewContext.delete (value)
            try? coreDataController.viewContext.save ()
        }
        client.fetchPhotos () {
            try? self.fetchedController.performFetch ()
        }
    }
}
