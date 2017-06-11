//
//  Yashin.swift
//
//  Created by SatoShunsuke on 2015/12/29.
//
//
import Foundation
import UIKit

public class Yashin : UIView {
    
    public typealias Value = ([UInt], UIColor)
    
    private var keys   = [String]()
    private var values = [Value]()
    
    public var minValue :UInt = 0
    public var maxValue :UInt = 10
    public var padding :CGFloat = 60
    public var scaleLineWidth :CGFloat = 3.0
    public var scaleLineHidden = false
    
    // font
    public var fontSize :CGFloat = 11.0
    
    // color
    public var lineColor    = UIColor.darkGray
    public var subLineColor = UIColor.darkGray.withAlphaComponent(0.50)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(keys :[String], _ values :[Value]) {
        self.keys = keys
        self.values = values
    }
    
    public override func draw(_ rect: CGRect) {
        
        if !self.validateMinAndMax() {
            print("Invalid combination minValue and maxValue")
            return
        }
        
        if !self.validateKeyCount() {
            print("key count is needed at least 3")
            return
        }
        
        if !self.validateIntegrityKeyAndValue() {
            print("invalid combination key and value")
            return
        }
        
        if !self.validateSufficientFrame() {
            print("frame size is too small to show")
            return
        }
        
        let keyCount   = self.keys.count
        let valueCount = self.values.count
        let len = min(self.frame.width, self.frame.height) - padding * 2
        let center = CGPoint(x:self.center.x - self.frame.origin.x, y:self.center.y - self.frame.origin.y)
        let scales :[CGFloat] = self.getScaleValues(minValue:  self.minValue, self.maxValue)
        
        var rad :CGFloat = 2 * CGFloat(M_PI) * 3 / 4
        var maxPoints    = [CGPoint]()
        var valuePoints  = Array(repeating: [CGPoint](), count: valueCount)
        
        for (index, key) in self.keys.enumerated() {
            
            let currentMaxPoint = self.getPoint(centerPoint: center, len: len / 2, rad: rad)
            maxPoints.append(currentMaxPoint)
            
            for (valueIndex, value) in self.values.enumerated() {
                let values :[UInt] = value.0
                let valueRatio :CGFloat = min(1.0, (CGFloat(values[index]) - CGFloat(self.minValue)) / CGFloat(self.maxValue - self.minValue))
                let point = self.getPoint(centerPoint: center, len: len * valueRatio / 2, rad: rad)
                valuePoints[valueIndex].append(point)
            }
            
            // draw inner-line
            self.subLineColor.setStroke()
            self.drawLine(from: currentMaxPoint, center)
            
            // draw text
            let paragraphStyle = NSMutableParagraphStyle()
            let dic = [
                NSParagraphStyleAttributeName  : paragraphStyle,
                NSForegroundColorAttributeName : self.lineColor,
                NSFontAttributeName            : UIFont.systemFont(ofSize: self.fontSize)
                ] as [String : Any]
            let namePoint = self.getPoint(centerPoint: center, len: (len + 10) / 2, rad: rad)
            let textWidth  :CGFloat = 200.0
            let textHeight :CGFloat = 14.0
            var textX :CGFloat = namePoint.x
            var textY :CGFloat = namePoint.y
            
            if index == 0 {
                paragraphStyle.alignment = NSTextAlignment.center
                textX = namePoint.x - textWidth / 2
                textY = namePoint.y - textHeight
            } else if index == keyCount / 2 && keyCount % 2 == 0 {
                paragraphStyle.alignment = NSTextAlignment.center
                textX = namePoint.x - textWidth / 2
            } else if index == keyCount / 4 && keyCount % 4 == 0 {
                paragraphStyle.alignment = NSTextAlignment.left
                textY = namePoint.y - textHeight / 2
            } else if index == keyCount / 4 * 3 && keyCount % 4 == 0 {
                paragraphStyle.alignment = NSTextAlignment.right
                textX = namePoint.x - textWidth
                textY = namePoint.y - textHeight / 2
            } else {
                if namePoint.x < center.x {
                    paragraphStyle.alignment = NSTextAlignment.right
                    textX = namePoint.x - textWidth
                } else {
                    paragraphStyle.alignment = NSTextAlignment.left
                }
                
                if namePoint.y < center.y {
                    textY = namePoint.y - textHeight
                }
            }
            key.draw(in: CGRect(x:textX, y:textY, width:textWidth, height:textHeight), withAttributes: dic)
            
            let nextRad = rad + 2 * CGFloat(M_PI) / CGFloat(keyCount)
            
            // draw scale lines
            if scaleLineHidden || (self.maxValue - self.minValue < 2) {
                rad = nextRad
                continue
            }
            self.subLineColor.setStroke()
            for scaleValue in scales {
                let ratio :CGFloat = (scaleValue - CGFloat(self.minValue)) / CGFloat(self.maxValue - self.minValue)
                let targetPoint = self.getPoint(centerPoint: center, len: len / 2 * ratio, rad: rad)
                let fromRad = rad + CGFloat(M_PI) / 2
                let toRad   = rad + CGFloat(M_PI) / 2 * 3
                let fromPoint = self.getPoint(centerPoint: targetPoint, len: scaleLineWidth, rad: fromRad)
                let toPoint   = self.getPoint(centerPoint: targetPoint, len: scaleLineWidth, rad: toRad)
                self.drawLine(from: fromPoint, toPoint)
            }
            
            rad = nextRad
        }
        
        // draw outer-line
        for (index, _) in maxPoints.enumerated() {
            self.lineColor.setStroke()
            if index == maxPoints.count - 1 {
                self.drawLine(from: maxPoints[index], maxPoints[0])
            } else {
                self.drawLine(from: maxPoints[index], maxPoints[index + 1])
            }
        }
        
        // fill value
        for (index, points) in valuePoints.enumerated() {
            let fillColor :UIColor = self.values[index].1
            let fillPath = UIBezierPath()
            fillColor.setFill()
            for (subIndex, point) in points.enumerated() {
                if subIndex == 0 {
                    fillPath.move(to: point)
                }
                fillPath.addLine(to: point)
            }
            fillPath.fill()
        }
        
    }
    
    // MARK: - validate
    public func validateMinAndMax() -> Bool {
        return self.minValue < self.maxValue
    }
    
    public func validateKeyCount() -> Bool {
        let count = self.keys.count
        return !(count < 3)
    }
    
    public func validateIntegrityKeyAndValue() -> Bool {
        let count = self.keys.count
        for value in self.values {
            if value.0.count != count {
                return false
            }
        }
        return true
    }
    
    public func validateSufficientFrame() -> Bool {
        let len = min(self.frame.width, self.frame.height) - padding * 2
        return !(len < 60)
    }
    
    // MARK: - private funcs
    private func drawLine(from :CGPoint, _ to :CGPoint, width :CGFloat = 1.0) {
        let path = UIBezierPath()
        path.lineWidth = width
        path.move(to: from)
        path.addLine(to: to)
        path.stroke()
    }
    
    private func getPoint(centerPoint :CGPoint, len :CGFloat, rad :CGFloat) -> CGPoint {
        return CGPoint(x:centerPoint.x + len * cos(rad), y:centerPoint.y + len * sin(rad))
    }
    
    private func getScaleValues(minValue :UInt, _ maxValue :UInt) -> [CGFloat] {
        var values = [CGFloat]()
        if (maxValue - minValue) < 2 {
            return values
        }
        if (maxValue - minValue) < 10 {
            for value in (minValue + 1)...(maxValue - 1) {
                values.append(CGFloat(value))
            }
            return values
        }
        for index in 1...(10 - 1) {
            let diff :CGFloat = CGFloat(maxValue - minValue) / 10.0
            values.append(CGFloat(minValue) + diff * CGFloat(index))
        }
        return values
    }
}
