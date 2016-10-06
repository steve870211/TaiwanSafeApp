//
//  ViewController.swift
//  Safe
//
//  Created by 許佳航 on 2016/10/3.
//  Copyright © 2016年 許佳航. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var mapView: GMSMapView?
    var addressArray: [AnyObject] = []
    var noArray: [AnyObject] = []
    var markers: [[String:AnyObject]] = [[:]]
    var int = 0
    var camera = GMSCameraPosition.cameraWithLatitude(23.284681, longitude: 118.158177, zoom: 6)
    let locationManager = CLLocationManager()
    var startLatitude: CLLocationDegrees?
    var startLongitude: CLLocationDegrees?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        getPositionInformation()
        getUserLocation()
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView?.myLocationEnabled = true
        mapView?.mapType = GoogleMaps.kGMSTypeNormal
        self.view = mapView
        
        let backToMyPositionButton = UIButton(frame: CGRect(x: 300, y: 670, width: 75, height: 35))
        backToMyPositionButton.setTitle("Back", forState: .Normal)
        backToMyPositionButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        backToMyPositionButton.addTarget(self, action: #selector(backToMyPosition), forControlEvents: .TouchUpInside)
        self.view.addSubview(backToMyPositionButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToMyPosition() {
        if startLatitude != nil && startLongitude != nil {
            let sydney = GMSCameraPosition.cameraWithLatitude(startLatitude!, longitude: startLongitude!, zoom: 16)
            mapView!.animateToCameraPosition(sydney)
        }
    }
    
    func getUserLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        startLatitude = locValue.latitude
        startLongitude = locValue.longitude
    }
    
    func getPositionInformation() {
        if let url = NSURL(string: "http://210.69.35.216/api/v1/rest/datastore/A01010000C-000628-011") {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            if let ajaxString = try? String(contentsOfURL: url) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let data = ajaxString.parsedAsJson() as? [String: AnyObject] {
                    if let dangerous = data["result"]!["records"] as? [AnyObject] {
                        for information in dangerous {
                            if let no = information["No"] as? Int {
                                noArray.insert(no, atIndex: noArray.count)
                                self.addProduct
                            }
                            if let address = information["Address"] as? String {
                                addressArray.insert(address, atIndex: addressArray.count)
                            }
                        }
                    }
                }
            } else { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
        }
    }
    
    func addProduct(address:String, latitude:Double, longitude:Double) {
        let product = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.moc) as? Product
        product.name = name
        product.price = price
        do {
            try self.moc.save()
        }catch{
            fatalError("Failure to save context: \(error)")
        }
    }
}
extension String {
    public func parsedAsJson() -> AnyObject? {
        var result: AnyObject?
        if let jsonData = self.dataUsingEncoding(NSUTF8StringEncoding) {
            if let json = try? NSJSONSerialization.JSONObjectWithData(
                jsonData , options: .MutableContainers
                ) { result = json }
        }
        return result
    }
}