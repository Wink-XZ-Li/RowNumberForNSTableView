//
//  LineNumberRulerView.swift
//  RowNumberForTableView
//
//  Created by Wink on 2021/4/1.
//  Copyright © 2021 Wink. All rights reserved.
//
import Cocoa
import ObjectiveC

var LineNumberViewAssocObjKey: UInt8 = 0


extension NSTableView {
    var lineNumverView: LineNumberRulerView {
        get {
            return objc_getAssociatedObject(self, &LineNumberViewAssocObjKey) as! LineNumberRulerView
        }
        set {
            objc_setAssociatedObject(self, &LineNumberViewAssocObjKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setUpLineNumberView() {
        
        if let scrollView = enclosingScrollView {
            lineNumverView = LineNumberRulerView(tableView: self)

            scrollView.verticalRulerView = lineNumverView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(redrawRowNumber), name: NSNotification.Name.init(rawValue: "tableViewNumberOfRowDidChanged"), object: self)
    }
    
    @objc func redrawRowNumber(notice: Notification) {
        self.lineNumverView.needsDisplay = true
    }
}

class LineNumberRulerView: NSRulerView {
    
    var font: NSFont! {
        didSet {
            self.needsLayout = true
        }
    }
    
    weak var headerMaskView: NSView?
    
    init(tableView: NSTableView) {
        super.init(scrollView: tableView.enclosingScrollView, orientation: .verticalRuler)
        self.font = tableView.font
        self.clientView = tableView
        //厚度
        let digitOfTableRowNumber: Int = String(tableView.numberOfRows).count
        self.ruleThickness = 10+(6.8*CGFloat(digitOfTableRowNumber))
        let maskView = NSView()
        self.subviews.append(maskView)
        headerMaskView = maskView
        headerMaskView?.wantsLayer = true
        headerMaskView?.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let tableView = self.clientView as? NSTableView
            else {return}
        //table row 行高
        let tableRowHeight: CGFloat = 19
        
        //原点
        let relativePoint = self.convert(NSZeroPoint, to: tableView)
        
        //厚度
        let digitOfTableRowNumber: Int = String(tableView.numberOfRows).count
        self.ruleThickness = 10+(6.8*CGFloat(digitOfTableRowNumber))
        let lineNumberAttributes = [NSAttributedString.Key.font: NSFont(name: "Menlo", size: 11) as Any, NSAttributedString.Key.foregroundColor: NSColor.gray] as [NSAttributedString.Key : Any]
        
        //画一个行号的闭包
        let drawLineNumber = { (lineNumberString:String, y:CGFloat) -> Void in
            let attributedString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
            let x = self.ruleThickness - 5 - attributedString.size().width
            attributedString.draw(at: NSPoint(x: x, y: -(relativePoint.y)+y+2))
        }
        
        headerMaskView?.frame = NSRect(x: 0, y: 0, width: self.ruleThickness, height: 27)
        headerMaskView?.autoresizingMask = [.minXMargin, .minYMargin]
  
        //画行号
        for num in 0...tableView.numberOfRows where num != tableView.numberOfRows {
            drawLineNumber("\(num+1)",CGFloat(num)*tableRowHeight)
        }
    }
    
}
