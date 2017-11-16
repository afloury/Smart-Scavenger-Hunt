import UIKit
import KeychainSwift
import AVFoundation
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var beaconBtn: UIButton!
    @IBOutlet weak var qrCodeBtn: UIButton!
    @IBOutlet weak var titleTop: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var titleTableV: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var hadMission = false
    
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
    
    var items = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeButton(button: beaconBtn)
        stylizeButton(button: qrCodeBtn)
        titleTableV.isHidden = true
        tableView.isHidden = true
        self.beaconBtn.setTitle("searching...", for: .disabled)
        self.beaconBtn.setTitleColor(.gray, for: .disabled)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("viewDidAppear")
        displayInstructions()
        stopSessionQrCode()
        stopBeaconDetection()
    }
    
    func displayInstructions() {
        if keychain.get("token") != nil {
            titleTop.text = "Hey"
            messageTitle.text = "Go to the withdrawal point to get your mission"
            titleTableV.isHidden = true
            tableView.isHidden = true
        } else {
            titleTop.text = "Hello"
            messageTitle.text = "Welcome to Scavenger Hunt\nto start a session go near to registration point"
            // TODO Uncomment
            titleTableV.isHidden = true
            tableView.isHidden = true
        }
        
        if hadMission {
            titleTop.text = "Let's begin !"
            messageTitle.text = "You need to get one of this:"
            titleTableV.isHidden = false
            tableView.isHidden = false
        }
    }
    
    func stylizeButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.2
    }
    
    func getMission(lrID: String) {
        api.getMission(lrID: lrID, completion: { (items) in
            self.hadMission = true
            self.items = items
            self.displayInstructions()
        })
    }
    
    func sendPhoto(lrID: String) {
        if let photoController = self.tabBarController?.viewControllers![2] as? PhotoViewController {
            photoController.sendPhoto(lrID: lrID)
        }
    }
    
    func displayRegisterView(lrID: String) {
        registerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "registerViewController") as! RegisterTeamViewController
        registerViewController.lrID = lrID
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
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beacons.forEach({ (beacon) in
            if ![1, 2, 3].contains(beacon.proximity.rawValue) { return }
            let lrID = String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
            var message = ""
            message = actByLRID(regionId: region.identifier, lrID: lrID)
            message += " => " + String(format:"%04x", beacon.major as! UInt32) + String(format:"%04x", beacon.minor as! UInt32)
        })
    }
    
    func stopBeaconDetection() {
        self.regions.forEach { regionBeacon in
            locationManager.stopRangingBeacons(in: regionBeacon)
        }
        self.beaconBtn.isEnabled = true
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
            sendPhoto(lrID: lrID)
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
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == .qr && metadataObj.stringValue != nil {
            stopSessionQrCode()
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
            Alert.show(controller: self, message: actByLRID(regionId: pointIdentifier, lrID: lrID))
        } else {
            Alert.show(controller: self, message: "Problem metadataOutput, QRCode detection")
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
        if previewLayer != nil {
            captureSession?.stopRunning()
            previewLayer.removeFromSuperlayer()
            self.previewLayer = nil
            self.captureSession = nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    @IBAction func qrCodeAction(_ sender: Any) {
        stopBeaconDetection()
        prepareCaptureSession()
    }
    
    @IBAction func beaconAction(_ sender: Any) {
        stopSessionQrCode()
        api.loadUUID { (uuidDelivery, uuidWithdrawal) in
            self.uuidDelivery = uuidDelivery
            self.uuidWithdrawal = uuidWithdrawal
            self.beaconBtn.isEnabled = false
            self.initBeacon()
        }
    }
}
