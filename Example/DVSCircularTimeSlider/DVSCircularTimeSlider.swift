//
//  DVSCircularTimeSlider.swift
//  
//
//  Created by Dries Van Schevensteen on 19/06/15.
//
//

import UIKit

@IBDesignable
class DVSCircularTimeSlider: UIControl {
    
    @IBInspectable
    var primaryCircleColor: UIColor = UIColor(red: 47/255, green: 213/255, blue: 100/255, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var primaryCircleStrokeSize: CGFloat = 7 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var primaryCircleHandleRadius: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var shadowCircleColor: UIColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var shadowCircleStrokeSize: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private lazy var timeLabel: UILabel = {
        [unowned self] in
        let label = UILabel()
        label.text = self.timeString
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: self.fontName, size: self.fontSize)
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
        // Constraints
        var leading = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        var trailing = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        var top = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var bottom = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.addConstraints([leading, trailing, top, bottom])
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    var fontSize: CGFloat = 30 {
        didSet {
            timeLabel.font = timeLabel.font.fontWithSize(fontSize)
        }
    }
    var fontName = "HelveticaNeue-Light" {
        didSet {
            timeLabel.font = UIFont(name: fontName, size: fontSize)
        }
    }
    
    var time = NSDate() {
        didSet {
            timeLabel.text = timeString
            setNeedsDisplay()
        }
    }
    var timeString: String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(time)
    }
    
    private var isTracking = false {
        didSet {
            setNeedsDisplay()
        }
    }
    lazy private var isSecondCircle: Bool = {
        [unowned self] in
        return (self.timeInRadians > RadianValuesInCircle.FullCircle) ? true : false
    }()
    
    private var timeInRadians: Double {
        let calender: NSCalendar = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        let components = calender.components(flags, fromDate: time)
        
        let numberFromTime: Double = Double(components.hour) + Double(components.minute) / 60
        let timeInRadians: Double = numberFromTime / 24 * RadianValuesInCircle.DoubleCircle
        
        return timeInRadians
    }
    
    private struct RadianValuesInCircle {
        static let Quarter = M_PI / 2
        static let Half = M_PI
        static let ThreeQuarters = 3 * M_PI / 2
        static let FullCircle = 2 * M_PI
        static let DoubleCircle = 4 * M_PI
    }

    // MARK: - Initializers
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.contentMode = UIViewContentMode.Redraw
    }
    
    // MARK: - Time
    
    func setTimeWithHours(h: Int, andMinutes m: Int) {
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.hour = Int(h)
        components.minute = Int(m)
        if let date = cal?.dateFromComponents(components) {
            time = date
        }
    }
    
    func getTimeInHoursFromAngle(a: Double) -> Double {
        return a / (RadianValuesInCircle.FullCircle / 12)
    }
    
    // MARK: - Touch handlers
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        isTracking = true
        return true
    }
    
    var canHandleMoveLeft = true
    var canHandleMoveRight = true
    var stoppedLeft = false {
        didSet {
            if stoppedLeft {
                setTimeWithHours(0, andMinutes: 0)
            }
        }
    }
    var stoppedRight = false {
        didSet {
            if stoppedRight {
                setTimeWithHours(23, andMinutes: 59)
            }
        }
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let angle = getAngleFromPoint(touch.locationInView(self))
        let previousAngle = getAngleFromPoint(touch.previousLocationInView(self))
        if angle > RadianValuesInCircle.ThreeQuarters && previousAngle < RadianValuesInCircle.Quarter  {
            if isSecondCircle {
                if !stoppedRight {
                    self.isSecondCircle = false
                }
            } else {
                canHandleMoveLeft = false
                stoppedLeft = true
            }
            if stoppedRight {
                stoppedRight = false
            }
        } else if angle < RadianValuesInCircle.Quarter && previousAngle > RadianValuesInCircle.ThreeQuarters  {
            if isSecondCircle {
                canHandleMoveRight = false
                stoppedRight = true
            } else {
                if !stoppedLeft {
                    isSecondCircle = true
                }
            }
            if stoppedLeft {
                stoppedLeft = false
            }
        } else if (canHandleMoveRight && canHandleMoveLeft) ||
        (!canHandleMoveLeft && angle - previousAngle > 0.0 && angle < RadianValuesInCircle.Quarter) ||
        (!canHandleMoveRight && angle - previousAngle < 0.0 && angle > RadianValuesInCircle.ThreeQuarters) {
            var timeInHours =  getTimeInHoursFromAngle(angle)
            if isSecondCircle {
                timeInHours += 12
            }
            let hours = floor(timeInHours)
            let minutes = (timeInHours - hours) * 60
            setTimeWithHours(Int(hours), andMinutes: Int(minutes))
            
            canHandleMoveLeft = true
            canHandleMoveRight = true
        }
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        isTracking = false
        canHandleMoveLeft = true
        canHandleMoveRight = true
        stoppedLeft = false
        stoppedRight = false
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func getAngleFromPoint(p: CGPoint) -> Double {
        let deltaY = p.y - self.frame.size.height/2
        let deltaX = p.x - self.frame.size.width/2
        let angleEndPoint = Double(atan2(deltaY, deltaX) - radianOffset)
        if angleEndPoint < 0 {
            return angleEndPoint + RadianValuesInCircle.FullCircle
        }
        return angleEndPoint
    }
    
    // MARK: - Draw UI
    
    private let radianOffset = -CGFloat(RadianValuesInCircle.Quarter)

    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)/2 - max(primaryCircleStrokeSize, shadowCircleStrokeSize)/2 - primaryCircleHandleRadius
        
        // Shadow circle
        shadowCircleColor.set()
        let shadowCircleOffset = primaryCircleHandleRadius*2
        let shadowCircleRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2)
        let shadowCirclePath = UIBezierPath(ovalInRect: shadowCircleRect)
        shadowCirclePath.lineWidth = shadowCircleStrokeSize
        shadowCirclePath.stroke()
        
        // Primary circle
        primaryCircleColor.set()
        let primaryCircleRounedBeginningRect = CGRect(
            x: center.x - primaryCircleStrokeSize/2,
            y: center.y - radius - primaryCircleStrokeSize/2,
            width: primaryCircleStrokeSize,
            height: primaryCircleStrokeSize)
        let primaryCircleRounedBeginningPath = UIBezierPath(ovalInRect:primaryCircleRounedBeginningRect)
        primaryCircleRounedBeginningPath.lineWidth = 0
        primaryCircleRounedBeginningPath.fill()
        primaryCircleRounedBeginningPath.stroke()
        
        
        let startAngle = 0 + radianOffset
        let endAngle = CGFloat(timeInRadians) + radianOffset
        
        let primaryCircleForTimePath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        primaryCircleForTimePath.lineWidth = primaryCircleStrokeSize
        primaryCircleForTimePath.stroke()
        
        // Primary circle handle
        let endAngleForPoint: CGFloat = endAngle - startAngle + radianOffset
        let xYOffset = -primaryCircleHandleRadius
        let endAnglePoint: CGPoint = CGPoint(
            x: bounds.width/2 + cos(endAngleForPoint) * radius + xYOffset,
            y: bounds.height/2 + sin(endAngleForPoint) * radius + xYOffset)
        
        let primaryCircleHandleRect = CGRect(
            x: endAnglePoint.x - xYOffset/2,
            y: endAnglePoint.y - xYOffset/2,
            width: primaryCircleHandleRadius,
            height: primaryCircleHandleRadius)
        let primaryCircleHandlePath = UIBezierPath(ovalInRect: primaryCircleHandleRect)
        primaryCircleHandlePath.fill()
        primaryCircleHandlePath.stroke()
        
        // Second circle background
        if isSecondCircle {
            primaryCircleColor.colorWithAlphaComponent(0.1).set()
            let secondCirclePath = UIBezierPath(ovalInRect: shadowCircleRect)
            secondCirclePath.lineWidth = 0
            secondCirclePath.fill()
            secondCirclePath.stroke()
        }
        
        // Primary circle handle background
        if isTracking {
            primaryCircleColor.colorWithAlphaComponent(0.2).set()
            let primaryCircleHandleBackgroundRect = CGRect(
                origin: endAnglePoint,
                size: CGSizeMake(primaryCircleHandleRadius*2, primaryCircleHandleRadius*2))
            let primaryCircleHandleBackgroundPath = UIBezierPath(ovalInRect: primaryCircleHandleBackgroundRect)
            primaryCircleHandleBackgroundPath.lineWidth = 0
            primaryCircleHandleBackgroundPath.fill()
            primaryCircleHandleBackgroundPath.stroke()
        }
    }
    
}
