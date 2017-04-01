//
//  MetadataObjectPicker.swift
//  MetadataObjectPicker
//
//  Created by Sebastian Owodzin on 31/03/2017.
//  Copyright © 2017 mobiletoolkit.org. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public class MetadataObjectPicker: NSObject {

    public enum Mode {
        case single
        case multi
    }

//    public var debug = false

    public var view: UIView

    fileprivate var previewLayer: AVCaptureVideoPreviewLayer

    fileprivate var mode: Mode

    fileprivate var shapes: [MetadataObjectShape] = []

    fileprivate let colors = [ UIColor.cyan.cgColor, UIColor.magenta.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor ]
    fileprivate var colorIndex = 0
    fileprivate var nextColor: CGColor {
        let index = colorIndex

        colorIndex += 1
        if colorIndex == colors.count {
            colorIndex = 0
        }

        return colors[index]
    }

    public init(previewLayer: AVCaptureVideoPreviewLayer, mode: Mode = .single) {
        self.previewLayer = previewLayer
        self.mode = mode

        view = UIView(frame: previewLayer.frame)
    }

    // MARK: - Private methods

    fileprivate func render(metadataObjects: [AVMetadataObject]) {
//        if debug {
//            print("metadataObjects: \(metadataObjects.count)")
//            metadataObjects.forEach { print("metadataObject: \($0)") }
//        }

        clear()

        shapes.append(contentsOf: metadataObjects.map({ MetadataObjectShape(metadataObject: previewLayer.transformedMetadataObject(for: $0), color: nextColor) }))

//        metadataObjects.forEach { metadataObject in
//            shapes.append(MetadataObjectShape(metadataObject: previewLayer.transformedMetadataObject(for: metadataObject), color: colors[nextColorIndex]))
//        }

        DispatchQueue.main.async {
            self.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.shapes.forEach { self.view.layer.addSublayer($0.outlineLayer) }
        }
    }

    fileprivate func clear() {
        shapes.removeAll()
        colorIndex = 0
    }

}

extension MetadataObjectPicker: AVCaptureMetadataOutputObjectsDelegate {

    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let objects = metadataObjects as? [AVMetadataObject] {
            render(metadataObjects: objects)
        }

//        metadataObjects.forEach { metadataObject in
//            print("metadataObject: \(metadataObject)")
//
////            if let qr = metadataObject as? AVMetadataMachineReadableCodeObject {
////                print("metadataObject: \(metadataObject)")
////            }
//        }

//        print("metadataObjects: \(metadataObjects)")
//
//        if let qr = metadataObject as? AVMetadataMachineReadableCodeObject {
//            dismiss(animated: true, completion: { () -> Void in
//                self.delegate?.scannedCode(qr.stringValue)
//                return
//            })
//        }
    }

}
