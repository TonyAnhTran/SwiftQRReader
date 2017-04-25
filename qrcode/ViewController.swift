//
//  ViewController.swift
//  qrcode
//
//  Created by Tu (Tony) A. TRAN on 4/24/17.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var detector: CIDetector? = nil
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: Life cirle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    
    @IBAction func scanImageButtonDidTap(_ sender: Any) {
        //TODO: You can handle here to get image from library or from camera
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    // MARK: Business methods
    
    /// Check QR Code with CIDetector
    ///
    /// - Parameter image: input image
    /// - Returns: QR hightlign image + decoded string
    func performQRCodeDetection(image: CIImage) -> (outImage: CIImage?, decode: String) {
        var resultImage: CIImage?
        var decode = ""
        detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        if let detector = detector {
            let features = detector.features(in: image)
            for feature in features as! [CIQRCodeFeature] {
                resultImage = drawHighlightOverlayForPoints(image,
                                                            topLeft: feature.topLeft,
                                                            topRight: feature.topRight,
                                                            bottomLeft: feature.bottomLeft,
                                                            bottomRight: feature.bottomRight)
                decode = feature.messageString!
            }
        }
        return (resultImage, decode)
    }
    
    /// QR images with highlight
    func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.compositingOverImage(image)
    }


    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // use the image
            if let imageCI = CIImage(image: image) {
                let result = self.performQRCodeDetection(image: imageCI)
                qrImageView.image = UIImage(ciImage: result.outImage!)
                resultLabel.text = result.decode
            }
        } else{
            print("Something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

