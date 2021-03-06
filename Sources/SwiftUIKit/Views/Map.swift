//
//  Map.swift
//  SwiftUIKit
//
//  Created by Oskar on 12/04/2020.
//

import Foundation
import MapKit

public struct MapPoint {
  public let latitude: Double
  public let longitude: Double
  public let title: String
  public let subtitle: String
  
  public init(latitude: Double, longitude: Double, title: String, subtitle: String) {
    self.latitude = latitude
    self.longitude = longitude
    self.title = title
    self.subtitle = subtitle
  }
}

public class Map: MKMapView {
  
  fileprivate var initialCoordinates: CLLocationCoordinate2D
  
  fileprivate var onFinishLoadingHandler: ((MKMapView) -> ())? = nil
  
  fileprivate var afterRegionChangeHandler: ((MKMapView) -> ())? = nil
  
  fileprivate var beforeRegionChangeHandler: ((MKMapView) -> ())? = nil
  
  fileprivate var annotationViewConfigurationHandler: ((MKAnnotationView?, MKAnnotation) -> (MKAnnotationView?))? = nil
  
  fileprivate var onAccessoryTapHandler: ((MKMapView, MKAnnotationView, UIControl) -> ())? = nil
  
  fileprivate var onAnnotationViewStateChangeHandler: ((MKMapView, MKAnnotationView, MKAnnotationView.DragState, MKAnnotationView.DragState) -> ())? = nil
  
  fileprivate var onAnnotationSelectHandler: ((MKMapView, MKAnnotationView) -> ())? = nil
  
  fileprivate var onAnnotationDeselectHandler: ((MKMapView, MKAnnotationView) -> ())? = nil
  
  fileprivate var annotationViewIdentifier: String? = nil
  
  public init(lat latitude: Double,
              lon longitude: Double,
              points: (() -> [MapPoint])? = nil) {
    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    initialCoordinates = coordinates
    
    super.init(frame: .zero)
    
    let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2,
                                longitudeDelta: region.span.longitudeDelta / 2)
    
    let region = MKCoordinateRegion(center: coordinates, span: span)
    setRegion(region, animated: true)
    
    if let points = points {
      add(points: points())
    }
    
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Initializers
public extension Map {
  convenience init(region: MKCoordinateRegion,
                   points: (() -> [MapPoint])? = nil) {
    self.init(lat: region.center.latitude,
              lon: region.center.longitude,
              points: points)
  }
}

// MARK: - Accessing Map Properties
public extension Map {
  @discardableResult
  func type(_ type: MKMapType) -> Self {
    mapType = type
    
    return self
  }
  
  @discardableResult
  func zoomEnabled(_ value: Bool = true) -> Self {
    isZoomEnabled = value
    
    return self
  }
  
  @discardableResult
  func scrollEnabled(_ value: Bool = true) -> Self {
    isScrollEnabled = value
    
    return self
  }
  
  @discardableResult
  func pitchEnabled(_ value: Bool = true) -> Self {
    isPitchEnabled = value
    
    return self
  }
  
  @discardableResult
  func rotateEnabled(_ value: Bool = true) -> Self {
    isRotateEnabled = value
    
    return self
  }
  
  /// Note: If delegate isn't its own class, modifiers based on delegate's methods will do nothing.
  @discardableResult
  func delegate(_ delegate: MKMapViewDelegate?) -> Self {
    self.delegate = delegate ?? self
    
    return self
  }
}

// MARK: - Manipulating the Visible Portion of the Map
public extension Map {
  @discardableResult
  func zoom(_ multiplier: Double) -> Self {
    let _center = initialCoordinates
    let _span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / multiplier / 10,
                                longitudeDelta: region.span.longitudeDelta / multiplier / 10)
    let _region = MKCoordinateRegion(center: _center, span: _span)
    
    setRegion(_region, animated: false)
    return self
  }
  
  @discardableResult
  func visible(rect: MKMapRect,
                          animate: Bool = true,
                          edgePadding: UIEdgeInsets? = nil
                          ) -> Self {
    if let padding = edgePadding {
      setVisibleMapRect(rect, edgePadding: padding, animated: animate)
    } else {
      setVisibleMapRect(rect, animated: animate)
    }
    
    return self
  }
  
  /// Changes coordinates and span.
  @discardableResult
  func move(to region: MKCoordinateRegion, animate: Bool = true) -> Self {
    initialCoordinates = region.center
    setRegion(region, animated: animate)
    
    return self
  }
  
  
  /// Changes only coordinates.
  @discardableResult
  func move(to coordinates: CLLocationCoordinate2D, animate: Bool = true) -> Self {
    let _region = MKCoordinateRegion(center: coordinates, span: region.span)
    initialCoordinates = coordinates
    setRegion(_region, animated: animate)
    
    return self
  }
  
  @discardableResult
  func center(_ center: CLLocationCoordinate2D, animated: Bool = true) -> Self {
    setCenter(center, animated: animated)
    
    return self
  }
  
  @discardableResult
  func show(annotations: [MKAnnotation], animated: Bool = true) -> Self {
    super.showAnnotations(annotations, animated: animated)
    
    return self
  }
  
  @discardableResult
  func show(annotations: MKAnnotation..., animated: Bool = true) -> Self {
    super.showAnnotations(annotations, animated: animated)
    
    return self
  }
}

// MARK: - Constraining the Map View

@available(iOS 13.0, *)
public extension Map {
  @discardableResult
  func camera(boundary: MKMapView.CameraBoundary?, animated: Bool = true) -> Self {
    setCameraBoundary(boundary, animated: animated)
    
    return self
  }
  
  @discardableResult
  func set(cameraZoomRange: MKMapView.CameraZoomRange?, animated: Bool) -> Self {
    super.setCameraZoomRange(cameraZoomRange, animated: animated)
    
    return self
  }
}

// MARK: - Configuring the Map's Appearance
public extension Map {
  @discardableResult
  func camera(_ camera: MKMapCamera, animated: Bool = true) -> Self {
    setCamera(camera, animated: animated)
    
    return self
  }
  
  @discardableResult
  func showBuildings(_ bool: Bool) -> Self {
    showsBuildings = bool
    
    return self
  }
}

@available(iOS 13.0, *)
public extension Map {
  @discardableResult
  func showCompass(_ bool: Bool) -> Self {
    showsCompass = bool
    
    return self
  }
  
  @discardableResult
  func showScale(_ bool: Bool) -> Self {
    showsScale = bool
    
    return self
  }
  
  @discardableResult
  func showTraffic(_ bool: Bool) -> Self {
    showsTraffic = bool
    
    return self
  }
  
  @discardableResult
  func pointOfInterestFilter(filter: MKPointOfInterestFilter?) -> Self {
    pointOfInterestFilter = filter
    
    return self
  }
}

// MARK: - Displaying the User's Location
public extension Map {
  @discardableResult
  func showUserLocation(_ bool: Bool) -> Self {
    showsUserLocation = bool
    
    return self
  }
  
  @discardableResult
  func user(trackingMode: MKUserTrackingMode, animated: Bool = true) -> Self {
    setUserTrackingMode(trackingMode, animated: animated)
    
    return self
  }
}

// MARK: - Managing Annotation Selections
public extension Map {
  @discardableResult
  func select(annotation: MKAnnotation, animated: Bool = true) -> Self {
    selectAnnotation(annotation, animated: animated)
    
    return self
  }
  
  @discardableResult
  func deselect(annotation: MKAnnotation, animated: Bool = true) -> Self {
    deselectAnnotation(annotation, animated: animated)
    
    return self
  }
}

// MARK: - Annotating the Map
public extension Map {
  @discardableResult
  func remove(annotation: MKAnnotation) -> Self {
    removeAnnotation(annotation)
    
    return self
  }
  
  @discardableResult
  func remove(annotations: [MKAnnotation]) -> Self {
    removeAnnotations(annotations)
    
    return self
  }
  
  @discardableResult
  func add(annotation: MKAnnotation) -> Self {
    addAnnotation(annotation)
    
    return self
  }
  
  @discardableResult
  func add(point: MapPoint) -> Self {
    DispatchQueue.global().async {
      let annotation = MKPointAnnotation()
      
      annotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude,
                                                     longitude: point.longitude)
      annotation.title = point.title
      annotation.subtitle = point.subtitle
      
      DispatchQueue.main.async {
        self.addAnnotation(annotation)
      }
    }
    
    return self
  }
  
  @discardableResult
  func add(annotations: [MKAnnotation]) -> Self {
    addAnnotations(annotations)
    
    return self
  }
  
  @discardableResult
  func add(points: [MapPoint]) -> Self {
    for point in points {
      add(point: point)
    }
    
    return self
  }
}

// MARK: - Creating Annotation Views
@available(iOS 11.0, *)
public extension Map {
  @discardableResult
  func register(classes: [String: AnyClass?]) -> Self {
    for (identifier, annotationClass) in classes {
      register(annotationClass, forAnnotationViewWithReuseIdentifier: identifier)
    }
    
    return self
  }
}

// MARK: - Adjusting Map Regions and Rectangles
public extension Map {
  @discardableResult
  func fitTo(region: MKCoordinateRegion) -> Self {
    self.region = regionThatFits(region)
    
    return self
  }
  
  @discardableResult
  func fitTo(rect: MKMapRect, edgePadding: UIEdgeInsets? = nil) -> Self {
    if let edgePadding = edgePadding {
      mapRectThatFits(rect, edgePadding: edgePadding)
    } else {
      mapRectThatFits(rect)
    }
    
    return self
  }
}

// MARK: - Delegate wrappers
// If delegate isn't its own class, methods below will not execute.
public extension Map {
  @discardableResult
  func onFinishLoading(_ handler: @escaping (MKMapView) -> ()) -> Self {
    guard delegate === self else { return self }
    onFinishLoadingHandler = handler
    
    return self
  }
  
  @discardableResult
  func afterRegionChange(_ handler: @escaping (MKMapView) -> ()) -> Self {
    guard delegate === self else { return self }
    afterRegionChangeHandler = handler
    
    return self
  }
  
  @discardableResult
  func beforeRegionChange(_ handler: @escaping (MKMapView) -> ()) -> Self {
    guard delegate === self else { return self }
    beforeRegionChangeHandler = handler
    
    return self
  }
  
  @discardableResult
  func configure(identifier: String?, _ annotationView: @escaping ((MKAnnotationView?, MKAnnotation) -> (MKAnnotationView?))) -> Self {
    guard delegate === self else { return self }
    annotationViewIdentifier = identifier
    annotationViewConfigurationHandler = annotationView
    
    return self
  }
  
  @discardableResult
  func onAccessoryTap(_ handler: @escaping (MKMapView, MKAnnotationView, UIControl) -> ()) -> Self {
    onAccessoryTapHandler = handler
    
    return self
  }
  
  @discardableResult
  func onAnnotationViewStateChange(_ handler: @escaping ((MKMapView, MKAnnotationView, MKAnnotationView.DragState, MKAnnotationView.DragState) -> ())) -> Self {
    onAnnotationViewStateChangeHandler = handler
    
    return self
  }
  
  @discardableResult
  func onAnnotationSelect(_ handler: @escaping ((MKMapView, MKAnnotationView) -> ())) -> Self {
    onAnnotationSelectHandler = handler
    
    return self
  }
  
  @discardableResult
  func onAnnotationDeselect(_ handler: @escaping ((MKMapView, MKAnnotationView) -> ())) -> Self {
    onAnnotationDeselectHandler = handler
    
    return self
  }
}

// MARK: - Delegation
extension Map: MKMapViewDelegate {
  public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    onFinishLoadingHandler?(mapView)
  }
  
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    afterRegionChangeHandler?(mapView)
  }
  
  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    beforeRegionChangeHandler?(mapView)
  }
  
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let identifier = annotationViewIdentifier {
      let annotationView = dequeueReusableAnnotationView(withIdentifier: identifier)
      
      return annotationViewConfigurationHandler?(annotationView, annotation)
    }
    
    return annotationViewConfigurationHandler?(nil, annotation)
  }
  
  public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    onAccessoryTapHandler?(mapView, view, control)
  }
  
  public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
    onAnnotationViewStateChangeHandler?(mapView, view, newState, oldState)
  }
  
  public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    onAnnotationSelectHandler?(mapView, view)
  }
  
  public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    onAnnotationDeselectHandler?(mapView, view)
  }
}
