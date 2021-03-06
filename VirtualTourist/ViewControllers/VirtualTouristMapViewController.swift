//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Sujay Bhowmick on 5/27/18.
//  Copyright © 2018 Sujay Bhowmick. All rights reserved.
//

import UIKit
import MapKit

class VirtualTouristMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    @IBOutlet weak var footerView: UIView!
    
    var pinAnnotation: MKPointAnnotation? = nil
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mkMapView)
        let pinCoordinates = self.mkMapView.convert(location, toCoordinateFrom: self.mkMapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = pinCoordinates
            
            print("\(#function) Coordinates: \(pinCoordinates.latitude),\(pinCoordinates.longitude)")
            
            self.mkMapView.addAnnotation(pinAnnotation!)
            
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = pinCoordinates
        } else if sender.state == .ended {
            
            _ = Pin(
                latitude: String(pinAnnotation!.coordinate.latitude),
                longitude: String(pinAnnotation!.coordinate.longitude),
                context: CoreDataStack.shared().context
            )
            save()
            
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        footerView.isHidden = !editing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mkMapView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        footerView.isHidden = true
        
        if let pins = loadPins() {
            showPins(pins)
        }
    }
    
    func loadPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = CoreDataStack.shared().fetchAllPins(entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return pins
    }
    
    func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = CoreDataStack.shared().fetchPin(predicate, entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    func showPins(_ pins: [Pin]){
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            self.mkMapView.addAnnotation(annotation)
        }
        self.mkMapView.showAnnotations(self.mkMapView.annotations, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoAlbumViewController {
            guard let pin = sender as? Pin else {
                return
            }
            let controller = segue.destination as! PhotoAlbumViewController
            controller.pin = pin
        }
    }
}

extension VirtualTouristMapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showInfo(withMessage: "Not Available.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                CoreDataStack.shared().context.delete(pin)
                save()
                return
            }
            performSegue(withIdentifier: "showVirtualTouristAlbum", sender: pin)
        }
    }
}
