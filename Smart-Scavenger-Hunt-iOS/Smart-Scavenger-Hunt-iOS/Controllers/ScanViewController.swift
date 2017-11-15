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
    let api = API()
    var registerViewController : RegisterTeamViewController!
    var uuidWithdrawal = ""
    var uuidDelivery = ""
    let keychain = KeychainSwift()
    var regions = [CLBeaconRegion]()
    
    func getMission(lrID: String) {
        if let home = tabBarController?.viewControllers![0] as? HomeViewController {
            api.getMission(lrID: lrID, completion: { (items) in
                home.hadMission = true
                home.items = items
                self.tabBarController?.selectedIndex = 0
            })
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
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beacons.forEach({ (beacon) in
            if ![1, 2, 3].contains(beacon.proximity.rawValue) { return }
            let lrID = String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
            var message = ""
            message = actByLRID(regionId: region.identifier, lrID: lrID)
            message += " => " + String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
            messageLabel.text = message
        })
    }
    
    func stopBeaconDetection() {
        self.regions.forEach { regionBeacon in
            locationManager.stopRangingBeacons(in: regionBeacon)
        }
    }
    
    func actByLRID(regionId: String, lrID: String) -> String{
        let token = keychain.get("token")
        var message = ""
        switch (token, regionId) {
        case(nil, "depot"):
            print("Informer l'utilisateur qu'il doit s'inscrire")
            message += "you have to go to the registration point first"
            Alert.show(controller: self, message: message)
            break
        case(nil, "inscription_retrait"):
            print("Déclencher code pour s'inscrire")
            message += "inscription"
            displayRegisterView(lrID: lrID)
            break
        case(_, "depot"):
            print("Déclencher code pour déposer photo")
            message += "depot"
            break
        case(_, "inscription_retrait"):
            print("Déclencher code pour retirer mission")
            message += "retrait"
            getMission(lrID: lrID)
            break
        case (_, _):
            // wtf
            break
        }
        stopBeaconDetection()
        return message
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
            stopSessionQrCode()
            messageLabel.text = metadataObj.stringValue!
            guard let raw_qr_code = metadataObj.stringValue else {
                Alert.show(controller: self, message: "Problème")
                return
            }
            if raw_qr_code.range(of: ":") == nil {
                Alert.show(controller: self, message: "QR-Code invalide (1)")
                return
            }
            let metadataSplitted = raw_qr_code.split(separator: ":").map(String.init)
            let pointIdentifier = metadataSplitted[0]
            let lrID = metadataSplitted[1]
            messageLabel.text = actByLRID(regionId: pointIdentifier, lrID: lrID)
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
    
    @IBAction func SearchBeacon(_ sender: Any) {
        api.loadUUID { (uuidDelivery, uuidWithdrawal) in
            self.uuidDelivery = uuidDelivery
            self.uuidWithdrawal = uuidWithdrawal
            self.initBeacon()
        }
    }
    
    @IBAction func searchQRCode(_ sender: Any) {
        prepareCaptureSession()
    }
}
