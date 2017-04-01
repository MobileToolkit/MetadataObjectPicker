//
//  SingleSelectionViewController.swift
//  ExampleApp
//
//  Created by Sebastian Owodzin on 31/03/2017.
//  Copyright © 2017 mobiletoolkit.org. All rights reserved.
//

import AVFoundation
import MetadataObjectPicker
import UIKit

class SingleSelectionViewController: UIViewController {

    fileprivate let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    fileprivate let session = AVCaptureSession()
    fileprivate let output = AVCaptureMetadataOutput()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!

    fileprivate var metadataObjectPicker: MetadataObjectPicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            session.addInput(try AVCaptureDeviceInput(device: device) as AVCaptureInput)
            session.addOutput(output)

            output.metadataObjectTypes = [ AVMetadataObjectTypeQRCode ]

            previewLayer = AVCaptureVideoPreviewLayer(session: session) as AVCaptureVideoPreviewLayer
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.frame = view.frame

            view.layer.addSublayer(previewLayer)

            metadataObjectPicker = MetadataObjectPicker(previewLayer: previewLayer)
            view.addSubview(metadataObjectPicker.view)

            output.setMetadataObjectsDelegate(metadataObjectPicker, queue: DispatchQueue.global())
        } catch {
            print("error: \(error)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        session.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.stopRunning()
    }

}

//extension ScanQRViewController: AVMetadataObjectSelectorDelegate {
//    func selectedMetadataObject(_ metadataObject: AVMetadataObject) {
//        if let qr = metadataObject as? AVMetadataMachineReadableCodeObject {
//            dismiss(animated: true, completion: { () -> Void in
//                self.delegate?.scannedCode(qr.stringValue)
//                return
//            })
//        }
//    }
//}
