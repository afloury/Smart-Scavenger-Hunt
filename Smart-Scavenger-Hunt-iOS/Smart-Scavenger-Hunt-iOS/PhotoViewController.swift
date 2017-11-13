import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import Photos

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var imageTake: UIImageView!
    var imagePicker: UIImagePickerController!
    var captureSession:AVCaptureSession!
    var urlBaseLocationRestriction = "http://172.30.1.208:5002/"
    var urlBaseRouter = "http://172.30.1.208:5001/"
    let locationManager = CLLocationManager()
    
    var latitude = 0.0
    var longitude = 0.0
    var listenNextLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        takePhotoButton.setTitle("Géolocalisation en cours...", for: .disabled)
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
            takePhotoButton.setTitle("Take Photo", for: .normal)
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
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
        //takePhotoButton.isEnabled = false
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
                //self.takePhotoButton.isEnabled = true
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendImage(_ sender: AnyObject) {
        sendPhoto()
    }
    
    func sendPhoto() {
        if imageTake.image != nil {
            let resizedImage = imageTake.image!.resized(toWidth: 800)
            let imageData = UIImageJPEGRepresentation(resizedImage!, 0.75)!
            
            Alamofire.upload(imageData, to: "\(urlBaseRouter)picture/").responseJSON { response in
                //debugPrint(response)
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let jsonObject = JSON(json)
                    let message =  jsonObject["message"].stringValue
                    let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController.init(title: nil, message: "Il faut prendre une photo avant de pouvoir l'envoyer.", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageTake.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        listenNextLocation = true
        takePhotoButton.setTitle("Retake Photo", for: .normal)
    }
}
