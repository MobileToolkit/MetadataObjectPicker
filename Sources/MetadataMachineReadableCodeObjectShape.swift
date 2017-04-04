//
//  MetadataObjectShape.swift
//  MetadataObjectPicker
//
//  Created by Sebastian Owodzin on 04/04/2017.
//  Copyright © 2017 mobiletoolkit.org. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public class MetadataMachineReadableCodeObjectShape: MetadataObjectShape {
    public var color: UIColor

    public var selected: Bool = false

    public var shapeLayer: CALayer {
        outline.path = createCGPath(points: extractPoints(metadataObject as? AVMetadataMachineReadableCodeObject))
        outline.strokeColor = color.cgColor
        outline.fillColor = selected ? selectedColor.cgColor : UIColor.clear.cgColor

        return outline
    }

    public let metadataObject: AVMetadataObject

    public required init(metadataObject: AVMetadataObject, color: UIColor) {
        self.metadataObject = metadataObject
        self.color = color
    }

    public func isEqual(to anotherMetadataObject: AVMetadataObject) -> Bool {
        guard let anotherMetadataObject = anotherMetadataObject as? AVMetadataMachineReadableCodeObject, let metadataObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
            return false
        }

        return anotherMetadataObject.stringValue == metadataObject.stringValue
    }

    var outline: CAShapeLayer = {
        let layer = CAShapeLayer()

        layer.lineWidth = 2.0
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }()

    // MARK: - Private methods

    fileprivate func extractPoints(_ metadataObject: AVMetadataMachineReadableCodeObject?) -> [CGPoint]? {
        return (metadataObject?.corners as? [NSDictionary])?.map({ CGPoint(dictionaryRepresentation: $0)! }) ?? nil
    }

    fileprivate func createCGPath(points: [CGPoint]?) -> CGPath? {
        guard let points = points else {
            return nil
        }

        let bezierPath = UIBezierPath()

        let firstCornerPoint = points.first!

        bezierPath.move(to: firstCornerPoint)

        points.filter({ $0 != points.first! }).forEach({ bezierPath.addLine(to: $0) })

        bezierPath.addLine(to: firstCornerPoint)

        return bezierPath.cgPath
    }

}
