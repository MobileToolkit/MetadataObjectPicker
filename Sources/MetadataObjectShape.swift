//
//  MetadataObjectShape.swift
//  MetadataObjectPicker
//
//  Created by Sebastian Owodzin on 31/03/2017.
//  Copyright © 2017 mobiletoolkit.org. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class MetadataObjectShape {
    let metadataObject: AVMetadataObject

    var color: CGColor

    var selected: Bool = false

    var outlineLayer: CALayer {
        outline.path = createCGPath(points: extractPoints(metadataMachineReadableCodeObject: metadataMachineReadableCodeObject))
        outline.strokeColor = color
        outline.fillColor = selected ? outline.strokeColor : UIColor.clear.cgColor

        return outline
    }

    fileprivate var metadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject?

    fileprivate var outline: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 2.0
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }()

    init(metadataObject: AVMetadataObject, color: CGColor) {
        self.metadataObject = metadataObject
        self.color = color

        if let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject {
            metadataMachineReadableCodeObject = metadataObject
        }
    }

    // MARK: - Private methods

    fileprivate func extractPoints(metadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject?) -> [CGPoint]? {
        return (metadataMachineReadableCodeObject?.corners as? [NSDictionary])?.map({ CGPoint(dictionaryRepresentation: $0)! }) ?? nil
    }

    fileprivate func createCGPath(points: [CGPoint]?) -> CGPath? {
        if let points = points {
            let bezierPath = UIBezierPath()

            let firstCornerPoint = points.first!

            bezierPath.move(to: firstCornerPoint)

            points.filter({ $0 != points.first! }).forEach({ bezierPath.addLine(to: $0) })

            bezierPath.addLine(to: firstCornerPoint)

            return bezierPath.cgPath
        }

        return nil
    }
}
