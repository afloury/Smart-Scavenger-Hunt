import UIKit
import AVFoundation
import CoreLocation
import Alamofire
import SwiftyJSON
import KeychainSwift

class ScanViewController: UIViewController, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    var captureSession:AVCaptureSession!
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    let locationManager = CLLocationManager()
    var urlBaseLocationRestriction = "http://172.30.1.208:5002/"
    var urlBaseRouter = "http://172.30.1.208:5001/"

    var uuidWithdrawal = ""
    var uuidDelivery = ""
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCaptureSession()
        loadUUID()
    }
    
    func loadUUID() {
        // 172.30.1.208:5002/uuid/
        Alamofire.request("\(urlBaseLocationRestriction)uuid/").responseJSON { response in
            //debugPrint(response)
            
            if let json = response.result.value {
                print("JSON: \(json)")
                let jsonObject = JSON(json)
                self.uuidDelivery = jsonObject["depot"].stringValue
                self.uuidWithdrawal = jsonObject["inscription_retrait"].stringValue
                self.initBeacon()
            }
        }
    }
    
    func initBeacon() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        let uuidW = UUID(uuidString: self.uuidWithdrawal)!
        let uuidD = UUID(uuidString: self.uuidDelivery)!
        let regions = [CLBeaconRegion(proximityUUID: uuidD, identifier: "depot"),
                       CLBeaconRegion(proximityUUID: uuidW, identifier: "inscription_retrait")]
        
        regions.forEach { region in
            region.notifyOnExit = true
            region.notifyOnEntry = true
            region.notifyEntryStateOnDisplay = true
            locationManager.startRangingBeacons(in: region)
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("")
        beacons.forEach({ (beacon) in
            if ![1, 2, 3].contains(beacon.proximity.rawValue) { return }
            
            var message = ""
            let token_equipe_present = keychain.get("token")
            
            switch (token_equipe_present, region.identifier) {
            case(nil, "depot"):
                print("Informer l'utilisateur qu'il doit s'inscrire")
                message += "svp inscrire?"
                break
            case(nil, "inscription_retrait"):
                print("Déclencher code pour s'inscrire")
                message += "inscription"
                break
            case(_, "depot"):
                print("Déclencher code pour déposer photo")
                message += "depot"
                break
            case(_, "inscription_retrait"):
                print("Déclencher code pour retirer mission")
                message += "retrait"
                break
            case (_, _):
                // wtf
                break
            }
            
            message += " => " + String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
            messageLabel.text = message
        })
    }
    
    func prepareCaptureSession() {
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Device has no camera.")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Set the input device on the capture session.
            captureSession?.addInput(input)
        } catch {
            print(error.localizedDescription)
        }
        prepareCamera()
        qrCode()
    }
    
    func qrCode() {
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [ .qr ]
        // start it
        captureSession?.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        guard metadataObjects.count > 0 else {
            messageLabel.text = "Identifiant"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == .qr && metadataObj.stringValue != nil {
            messageLabel.text = metadataObj.stringValue
        } else {
            messageLabel.text = "Identifiant"
        }
    }
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        beginSession()
    }
    
    func beginSession () {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        //CONSTRAINTS
        //self.previewLayer.translatesAutoresizingMaskIntoConstraints = false
        /*let horizontalConstraint = NSLayoutConstraint(item: self.previewLayer, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let leadConstraint = NSLayoutConstraint(item: self.previewLayer, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 20)
        //let trailingConstraint = NSLayoutConstraint(item: self.previewLayer, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 20)
        let topConstraint = NSLayoutConstraint(item: self.previewLayer, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)
        let bottomConstraint = NSLayoutConstraint(item: self.previewLayer, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 20)
        view.addConstraints([horizontalConstraint, leadConstraint, topConstraint, bottomConstraint])
        */
        
        captureSession.startRunning()
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
