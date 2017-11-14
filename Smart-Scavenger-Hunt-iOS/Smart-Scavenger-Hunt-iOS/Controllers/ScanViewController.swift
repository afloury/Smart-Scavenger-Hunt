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
    var registerViewController : RegisterTeamViewController!

    var uuidWithdrawal = ""
    var uuidDelivery = ""
    let keychain = KeychainSwift()
    var regions = [CLBeaconRegion]()
    var idRegion = ""
    
    func loadUUID() {
        Alamofire.request("\(urlBaseLocationRestriction)uuid/").responseJSON { response in
            if let json = response.result.value {
                let jsonObject = JSON(json)
                self.uuidDelivery = jsonObject["depot"].stringValue
                self.uuidWithdrawal = jsonObject["inscription_retrait"].stringValue
                self.initBeacon()
            }
        }
    }
    
    func getMission(lrID: String, token: String) {
        if let home = tabBarController?.viewControllers![0] as? HomeViewController {
            let headers = [
                "X-SmartScavengerHunt-LRID": lrID,
                "Authentication": token
            ]
            Alamofire.request("\(urlBaseRouter)mission/", headers: headers).responseJSON { response in
                if let json = response.result.value {
                    let jsonObject = JSON(json)
                    var items = [String]()
                    for element in jsonObject.arrayValue {
                        items.append(element.stringValue)
                    }
                    home.hadMission = true
                    home.items = items
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }
    }
    
    func initBeacon() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        let uuidW = UUID(uuidString: self.uuidWithdrawal)!
        let uuidD = UUID(uuidString: self.uuidDelivery)!
        regions = [CLBeaconRegion(proximityUUID: uuidD, identifier: "depot"),
                       CLBeaconRegion(proximityUUID: uuidW, identifier: "inscription_retrait")]
        regions.forEach { region in
            region.notifyOnExit = true
            region.notifyOnEntry = true
            region.notifyEntryStateOnDisplay = true
            locationManager.startRangingBeacons(in: region)
        }
    }
    
    func displayRegisterView(lrID: String) {
        registerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "registerViewController") as! RegisterTeamViewController
        registerViewController.lrID = lrID
        registerViewController.tabBarCtrl = tabBarController!
        let card = registerViewController.view!
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        card.frame = CGRect(x: 16, y: screenHeight * 0.20, width: view.bounds.width - 32, height: screenHeight * 0.60)
        let maskPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 20)
        let maskShape = CAShapeLayer()
        maskShape.path = maskPath.cgPath
        card.layer.mask = maskShape
        self.view.addSubview(card)
    }
    
    func displayAlert(message: String, actionTitle: String = "Ok") {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: actionTitle, style: .default, handler: {(alert: UIAlertAction!) in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("")
        beacons.forEach({ (beacon) in
            print("dump")
            dump(beacon)
            if ![1, 2, 3].contains(beacon.proximity.rawValue) { return }
            let lrID = String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
            var message = ""
            let token_equipe_present = keychain.get("token")
            switch (token_equipe_present, region.identifier) {
            case(nil, "depot"):
                print("Informer l'utilisateur qu'il doit s'inscrire")
                if idRegion == region.identifier {
                    idRegion = region.identifier
                    message += "you have to go to the registration point first"
                    displayAlert(message: message)
                    self.regions.forEach { regionBeacon in
                        locationManager.stopRangingBeacons(in: regionBeacon)
                    }
                }
                break
            case(nil, "inscription_retrait"):
                print("Déclencher code pour s'inscrire")
                if idRegion == region.identifier {
                    idRegion = region.identifier
                    message += "inscription"
                    displayRegisterView(lrID: lrID)
                    self.regions.forEach { regionBeacon in
                        locationManager.stopRangingBeacons(in: regionBeacon)
                    }
                }
                break
            case(_, "depot"):
                print("Déclencher code pour déposer photo")
                message += "depot"
                break
            case(_, "inscription_retrait"):
                print("Déclencher code pour retirer mission")
                message += "retrait"
                getMission(lrID: lrID, token: token_equipe_present!)
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
        let token_equipe_present = keychain.get("token")
        
        if metadataObj.type == .qr && metadataObj.stringValue != nil {
            stopSessionQrCode()
            
            messageLabel.text = metadataObj.stringValue!
            
            guard let raw_qr_code = metadataObj.stringValue else {
                displayAlert(message: "Problème")
                return
            }
            
            if raw_qr_code.range(of: ":") == nil {
                displayAlert(message: "QR-Code invalide (1)")
                return
            }
        
            let metadataSplitted = raw_qr_code.split(separator: ":").map(String.init)
            let pointIdentifier = metadataSplitted[0]
            let lrID = metadataSplitted[1]
            
            if pointIdentifier != "inscription_retrait" && pointIdentifier != "depot" {
                displayAlert(message: "QR-Code invalide (2)")
            }
            
            if pointIdentifier == "inscription_retrait" && token_equipe_present == nil {
                displayRegisterView(lrID: lrID)
            }
            
            if pointIdentifier == "inscription_retrait" && token_equipe_present != nil {
                getMission(lrID: lrID, token: token_equipe_present!)
            }
            
            
            //displayAlert(message: "Point scanné : " + explode_test[0] + ", LRID=" + explode_test[1])
            
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
    
    func stopSessionQrCode() {
        captureSession?.stopRunning()
        previewLayer.removeFromSuperlayer()
        self.previewLayer = nil
        self.captureSession = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    @IBAction func SearchBeacon(_ sender: Any) {
        loadUUID()
    }
    
    @IBAction func searchQRCode(_ sender: Any) {
        prepareCaptureSession()
    }
}
