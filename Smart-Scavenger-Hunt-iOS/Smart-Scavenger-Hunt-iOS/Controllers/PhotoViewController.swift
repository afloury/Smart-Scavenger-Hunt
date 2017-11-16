import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import Photos

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var labelCenter: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var imageTake: UIImageView!
    var imagePicker: UIImagePickerController!
    var captureSession:AVCaptureSession!
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var listenNextLocation = false
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareCaptureSession()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if listenNextLocation {
            listenNextLocation = false
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            latitude = locValue.latitude
            longitude = locValue.longitude
        }
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
    }
    
    //MARK: - Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            Alert.show(controller: self, message: "Device has no camera.", buttonTitle: "Alright")
        } else {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendImage(_ sender: AnyObject) {
        // This button shoudn't be enabled in production,
        // it help us for testing, otherwise the photo
        // is send when scanning QRCode or Beacon
        sendPhoto(lrID: "trolol")
    }
    
    func sendPhoto(lrID: String) {
        guard let imageTaken = imageTake.image else {
            Alert.show(controller: self, message: "Il faut prendre une photo avant de pouvoir l'envoyer.")
            return
        }
        let resizedImage = imageTaken.resized(toWidth: 800)
        let imageData = UIImageJPEGRepresentation(resizedImage!, 0.75)!
        api.sendPhoto(lrID: lrID, lat: String(latitude), long: String(longitude), imageData: imageData, completion: { (response) in
            Alert.show(controller: self, message: response)
            // display instruction in home screen
            if let home = self.tabBarController?.viewControllers![0] as? HomeViewController {
                home.displayInstructions()
            }
        })
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageTake.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        listenNextLocation = true    }
}
