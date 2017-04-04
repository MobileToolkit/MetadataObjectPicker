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

public protocol MetadataObjectPickerDelegate: class {
    func metadataObjectPicker(_ metadataObjectPicker: MetadataObjectPicker, didSelectedMetadataObject metadataObject: AVMetadataObject)
}

public class MetadataObjectPicker: NSObject {

    public weak var delegate: MetadataObjectPickerDelegate?

    public enum Mode {
        case single
        case multi
    }

//    public var debug = false

    public var view: UIView

    fileprivate var previewLayer: AVCaptureVideoPreviewLayer

    fileprivate var mode: Mode

    fileprivate var shapes: [MetadataObjectShape] = []

    fileprivate let colors = [ UIColor.cyan, UIColor.magenta, UIColor.yellow, UIColor.green ]
    fileprivate var colorIndex = 0
    fileprivate var nextColor: UIColor {
        let index = colorIndex

        colorIndex += 1
        if colorIndex == colors.count {
            colorIndex = 0
        }

        return colors[index]
    }

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?

    fileprivate var selectedMetadataObject: AVMetadataObject?

    public init(previewLayer: AVCaptureVideoPreviewLayer, mode: Mode = .single) {
        self.previewLayer = previewLayer
        self.mode = mode

        view = UIView(frame: previewLayer.frame)
    }

    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        selectedMetadataObject = shapes.filter({ $0.metadataObject.bounds.contains(gestureRecognizer.location(in: self.view)) }).map({ $0.metadataObject }).first

        delegate?.metadataObjectPicker(self, didSelectedMetadataObject: selectedMetadataObject!)

//        for shape in self.shapes {
//            if shape.metadataObject.bounds.contains(gestureRecognizer.location(in: self.view)) {
//                //                print("selected: \(shape)")
//
//                delegate?.selectedMetadataObject(shape.metadataObject)
//
//                break
//            }
//        }
    }

    fileprivate func render(metadataObjects: [AVMetadataObject]) {
//        if debug {
//            print("metadataObjects: \(metadataObjects.count)")
//            metadataObjects.forEach { print("metadataObject: \($0)") }
//        }

        clear()

        metadataObjects.forEach { metadataObject in
            if let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
                let shape = MetadataMachineReadableCodeObjectShape(metadataObject: transformedMetadataObject, color: nextColor)

                if let selectedMetadataObject = selectedMetadataObject {
                    shape.selected = shape.isEqual(to: selectedMetadataObject)
                }

                shapes.append(shape)
            }
        }

        if shapes.isEmpty {
            tapGestureRecognizer = nil
            selectedMetadataObject = nil
        } else {
            if tapGestureRecognizer == nil {
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MetadataObjectPicker.handleTap(_:)))
                view.addGestureRecognizer(tapGestureRecognizer!)
            }

            if shapes.filter({ $0.selected }).isEmpty {
                selectedMetadataObject = nil
            }
        }

//        shapes.append(contentsOf: metadataObjects.map({ MetadataMachineReadableCodeObjectShape(metadataObject: previewLayer.transformedMetadataObject(for: $0), color: nextColor) }))

//        metadataObjects.forEach { metadataObject in
//            shapes.append(MetadataObjectShape(metadataObject: previewLayer.transformedMetadataObject(for: metadataObject), color: colors[nextColorIndex]))
//        }

        DispatchQueue.main.async {
            self.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.shapes.forEach { self.view.layer.addSublayer($0.shapeLayer) }
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
