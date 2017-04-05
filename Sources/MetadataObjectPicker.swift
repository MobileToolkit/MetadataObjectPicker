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

        #if DEBUG
            print("selectedMetadataObject: \(String(describing: selectedMetadataObject))")
        #endif

        delegate?.metadataObjectPicker(self, didSelectedMetadataObject: selectedMetadataObject!)

        selectedMetadataObject = nil
    }

    fileprivate func render(metadataObjects: [AVMetadataObject]) {
        #if DEBUG
            print("metadataObjects: \(metadataObjects.count)")
            metadataObjects.forEach { print("metadataObject: \($0)") }
        #endif

        shapes.removeAll()
        colorIndex = 0

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

        DispatchQueue.main.async {
            self.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.shapes.forEach { self.view.layer.addSublayer($0.shapeLayer) }
        }
    }

}

extension MetadataObjectPicker: AVCaptureMetadataOutputObjectsDelegate {

    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let objects = metadataObjects as? [AVMetadataObject] {
            render(metadataObjects: objects)
        }
    }

}
