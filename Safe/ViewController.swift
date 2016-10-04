//
//  ViewController.swift
//  Safe
//
//  Created by 許佳航 on 2016/10/3.
//  Copyright © 2016年 許佳航. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var mapView: GMSMapView?
    var addressArray: [AnyObject] = []
    var noArray: [AnyObject] = []
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
            let sydney = GMSCameraPosition.cameraWithLatitude(startLatitude!, longitude: startLongitude!, zoom: 6)
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
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getPositionInformation() {
        if let url = NSURL(string: "http://210.69.35.216/api/v1/rest/datastore/A01010000C-000628-011") {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            if let ajaxString = try? String(contentsOfURL: url) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let data = ajaxString.parsedAsJson() as? [String: AnyObject] {
                    if let dangerous = data["result"]!["records"] as? [AnyObject] {
                        for information in dangerous {
                            if let address = information["Address"] as? String {
                                addressArray.insert(address, atIndex: addressArray.count)
                            }
                            if let no = information["No"] as? Int {
                                noArray.insert(no, atIndex: noArray.count)
                            }
                        }
                    }
                }
            } else { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
        }
        geocodeAddressString()
    }
    
    func geocodeAddressString() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressArray[int] as! String, completionHandler: {
            (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if error != nil {
//                print("Error：\(error!.localizedDescription))")
                if self.addressArray.count > self.int {
                    self.geocodeAddressString()
                } else {
                    return
                }
            }
            if let p = placemarks?[0] {
                print("longitude：\(p.location!.coordinate.longitude)" + "latitude：\(p.location!.coordinate.latitude)")
                let longitude = p.location!.coordinate.longitude
                let latitude = p.location!.coordinate.latitude
                if self.addressArray.count > self.int {
                    self.addMarker(longitude, latitude: latitude, title: self.addressArray[self.int] as! String)
                } else {
                    return
                }
            } else {
//                print("No placemarks!")
                if self.addressArray.count > self.int {
                    self.geocodeAddressString()
                } else {
                    return
                }
            }
            self.int += 1
        })
    }
    
    func addMarker(longitude:Double, latitude:Double, title:String) {
        dispatch_async(dispatch_get_main_queue(), {
            let position = CLLocationCoordinate2DMake(latitude,longitude)
            let marker = GMSMarker(position: position)
            marker.title = title
            marker.map = self.mapView
            self.int += 1
        })
        if self.addressArray.count > self.int {
            self.geocodeAddressString()
        } else {
            return
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