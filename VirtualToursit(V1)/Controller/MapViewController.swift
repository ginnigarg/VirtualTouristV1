//
//  MapViewVC.swift
//  VirtualToursit(V1)
//
//  Created by Guneet Garg on 09/05/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController : UIViewController , UIGestureRecognizerDelegate , MKMapViewDelegate{
    
    var coreDataController  : DataController!
    var coords = CLLocationCoordinate2D ()
    @IBOutlet weak var geoView : MKMapView!
    var pin : Pin? = nil
    
    override func viewDidLoad () {
        super.viewDidLoad ()
        fetchPins ()
        setFetchedPin ()
        addGesture()
    }
    
    func fetchPins () {
        let fetchRequest : NSFetchRequest <Pin> = Pin.fetchRequest ()
        fetchRequest.sortDescriptors = []
        if let results = try?coreDataController.viewContext.fetch (fetchRequest) {
            for values in results {
                let annotations = MKPointAnnotation ()
                annotations.coordinate.latitude = values.lat
                annotations.coordinate.longitude = values.long
                geoView.addAnnotation (annotations)
            }
        }
    }
    
    func setFetchedPin () {
        let fetchRequest : NSFetchRequest <Map> = Map.fetchRequest ()
        fetchRequest.sortDescriptors = []
        if let results = try?coreDataController.viewContext.fetch (fetchRequest) {
            if results.count == 0 {
                print ("Error Fetching Map")
            } else {
                var geoState = CLLocationCoordinate2D ()
                geoState.latitude = (results.last?.lat)!
                geoState.longitude = (results.last?.long)!
                geoView.setCenter (geoState, animated: true)
            }
        }
    }
    
    func addGesture () {
        let gesture = UILongPressGestureRecognizer (target: self , action : #selector(addAnnotation (_ : )))
        gesture.minimumPressDuration = 1
        geoView.addGestureRecognizer (gesture)
    }
    
    @objc func addAnnotation (_ sender  : UILongPressGestureRecognizer) {
        let location = sender.location (in : geoView)
        coords = geoView.convert(location, toCoordinateFrom: geoView)
        let annotation = MKPointAnnotation ()
        annotation.coordinate = coords
        geoView.addAnnotation (annotation)
        print(coords.latitude)
        print(coords.longitude)
        let annotationCoords = Pin (context : coreDataController.viewContext)
        print("AnnotationCoords successfully declared")
        annotationCoords.lat = coords.latitude
        annotationCoords.long = coords.longitude
        print(annotationCoords.lat)
        print(annotationCoords.long)
        try? coreDataController.viewContext.save ()
    }
    
    func mapView (_ mapView : MKMapView , didSelect view : MKAnnotationView) {
        print("Selected a annotation")
        let fetchRequests : NSFetchRequest <Pin> = Pin.fetchRequest()
        fetchRequests.sortDescriptors = []
        let newController = storyboard?.instantiateViewController(withIdentifier: "PhotoView") as! PhotoViewController
        if let results = try?coreDataController.viewContext.fetch (fetchRequests) {
            for value in results {
                if value.lat == view.annotation?.coordinate.latitude , value.long == view.annotation?.coordinate.longitude {
                    newController.oldPins = value
                }
            }
        }
        print("New Controller to presented")
        newController.coord = (view.annotation?.coordinate)!
        newController.coreDataController = coreDataController
        present (newController, animated : true, completion : nil)
    }
    
    func mapView (_ mapView : MKMapView , regionDidChangeAnimated animated : Bool) {
        print("Region Changed")
        let entity = NSEntityDescription.entity (forEntityName: "Map", in: coreDataController.viewContext)
        let newMapRegion = Map(entity: entity!, insertInto: coreDataController.viewContext)
        newMapRegion.spanLat = geoView.region.span.latitudeDelta
        newMapRegion.spanLong = geoView.region.span.longitudeDelta
        newMapRegion.lat = geoView.region.center.latitude
        newMapRegion.long = geoView.region.center.longitude
        try?coreDataController.viewContext.save ()
    }

}
