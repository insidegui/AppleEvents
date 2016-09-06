//
//  EVTWindow.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 02/04/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import AVFoundation

public class EVTWindow: NSWindow {
    
    @IBInspectable @objc public var hidesTitlebar = true
    
    // MARK: - Initialization
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        var effectiveStyle = style
        effectiveStyle.insert(.FullSizeContentView)
        
        super.init(contentRect: contentRect, styleMask: effectiveStyle, backing: bufferingType, defer: flag)
        
        applyCustomizations()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        applyCustomizations()
    }
    
    // MARK: - Custom appearance
    
    public override var effectiveAppearance: NSAppearance {
        return NSAppearance(named: NSAppearanceNameVibrantDark)!
    }
    
    private var titlebarWidgets: [NSButton]? {
        return titlebarView?.subviews.flatMap { subview in
            guard subview.isKindOfClass(NSClassFromString("_NSThemeWidget")!) else { return nil }
            return subview as? NSButton
        }
    }
    
    private func appearanceForWidgets() -> NSAppearance? {
        if allowsPiPMode {
            return NSAppearance(appearanceNamed: "PiPZoom", bundle: NSBundle(forClass: EVTWindow.self))
        } else {
            return NSAppearance(named: NSAppearanceNameAqua)
        }
    }
    
    private func applyAppearanceToWidgets() {
        let appearance = appearanceForWidgets()
        titlebarWidgets?.forEach { $0.appearance = appearance }
    }
    
    private var _storedTitlebarView: NSVisualEffectView?
    public var titlebarView: NSVisualEffectView? {
        guard _storedTitlebarView == nil else { return _storedTitlebarView }
        guard let containerClass = NSClassFromString("NSTitlebarContainerView") else { return nil }
        
        guard let containerView = contentView?.superview?.subviews.filter({ $0.isKindOfClass(containerClass) }).last else { return nil }
        
        guard let titlebar = containerView.subviews.filter({ $0.isKindOfClass(NSVisualEffectView.self) }).last as? NSVisualEffectView else { return nil }
        
        _storedTitlebarView = titlebar
        
        return _storedTitlebarView
    }
    
    private var titleTextField: NSTextField?
    private var titlebarSeparatorLayer: CALayer?
    private var titlebarGradientLayer: CAGradientLayer?
    
    private var fullscreenObserver: NSObjectProtocol?
    
    private func applyCustomizations(note: NSNotification? = nil) {
        titleVisibility = .Hidden
        movableByWindowBackground = true
        
        titlebarView?.material = .UltraDark
        titlebarView?.state = .Active
        
        installTitlebarGradientIfNeeded()
        installTitlebarSeparatorIfNeeded()
        installTitleTextFieldIfNeeded()
        
        installFullscreenObserverIfNeeded()
        
        applyAppearanceToWidgets()
    }
    
    private func installTitleTextFieldIfNeeded() {
        guard titleTextField == nil && titlebarView != nil else { return }
        
        titleTextField = NSTextField(frame: titlebarView!.bounds)
        titleTextField!.editable = false
        titleTextField!.selectable = false
        titleTextField!.drawsBackground = false
        titleTextField!.bezeled = false
        titleTextField!.bordered = false
        titleTextField!.stringValue = title
        titleTextField!.font = NSFont.titleBarFontOfSize(13.0)
        titleTextField!.textColor = NSColor(calibratedWhite: 0.9, alpha: 0.8)
        titleTextField!.alignment = .Center
        titleTextField!.translatesAutoresizingMaskIntoConstraints = false
        titleTextField!.lineBreakMode = .ByTruncatingMiddle
        titleTextField!.sizeToFit()
        
        titlebarView!.addSubview(titleTextField!)
        titleTextField!.centerYAnchor.constraintEqualToAnchor(titlebarView!.centerYAnchor).active = true
        titleTextField!.centerXAnchor.constraintEqualToAnchor(titlebarView!.centerXAnchor).active = true
        titleTextField!.leadingAnchor.constraintGreaterThanOrEqualToAnchor(titlebarView!.leadingAnchor, constant: 67.0).active = true
        titleTextField!.setContentCompressionResistancePriority(0.1, forOrientation: .Horizontal)
        
        titleTextField!.layer?.compositingFilter = "lightenBlendMode"
    }
    
    private func installTitlebarGradientIfNeeded() {
        guard titlebarGradientLayer == nil && titlebarView != nil else { return }
        
        titlebarGradientLayer = CAGradientLayer()
        titlebarGradientLayer!.colors = [NSColor(calibratedWhite: 0.0, alpha: 0.4).CGColor, NSColor.clearColor().CGColor]
        titlebarGradientLayer!.frame = titlebarView!.bounds
        titlebarGradientLayer!.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        titlebarGradientLayer!.compositingFilter = "overlayBlendMode"
        titlebarView?.layer?.insertSublayer(titlebarGradientLayer!, atIndex: 0)
    }
    
    private func installTitlebarSeparatorIfNeeded() {
        guard titlebarSeparatorLayer == nil && titlebarView != nil else { return }
        
        titlebarSeparatorLayer = CALayer()
        titlebarSeparatorLayer!.backgroundColor = NSColor(calibratedWhite: 0.0, alpha: 0.9).CGColor
        titlebarSeparatorLayer!.frame = CGRect(x: 0.0, y: 0.0, width: titlebarView!.bounds.width, height: 1.0)
        titlebarSeparatorLayer!.autoresizingMask = [.LayerWidthSizable, .LayerMinYMargin]
        titlebarView?.layer?.addSublayer(titlebarSeparatorLayer!)
    }
    
    private func installFullscreenObserverIfNeeded() {
        guard fullscreenObserver == nil else { return }
        
        let nc = NSNotificationCenter.defaultCenter()
        
        // the customizations (especially the title text field ones) have to be reapplied when entering and exiting fullscreen
        nc.addObserverForName(NSWindowDidEnterFullScreenNotification, object: self, queue: nil, usingBlock: applyCustomizations)
        nc.addObserverForName(NSWindowDidExitFullScreenNotification, object: self, queue: nil, usingBlock: applyCustomizations)
    }
    
    public override func makeKeyAndOrderFront(sender: AnyObject?) {
        super.makeKeyAndOrderFront(sender)
        
        applyCustomizations()
    }
    
    // MARK: - Titlebar management
    
    func hideTitlebar(animated: Bool = true) {
        setTitlebarOpacity(0.0, animated: animated)
    }
    
    func showTitlebar(animated: Bool = true) {
        setTitlebarOpacity(1.0, animated: animated)
    }
    
    private func setTitlebarOpacity(opacity: CGFloat, animated: Bool) {
        guard hidesTitlebar else { return }
        
        // when the window is in full screen, the titlebar view is in another window (the "toolbar window")
        guard titlebarView?.window == self else { return }
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = animated ? 0.4 : 0.0
            self.titlebarView?.animator().alphaValue = opacity
            }, completionHandler: nil)
    }
    
    // MARK: - Content management
    
    public override var title: String {
        didSet {
            titleTextField?.stringValue = title
        }
    }
    
    public override var contentView: NSView? {
        set {
            let darkContentView = EVTWindowContentView(frame: newValue?.frame ?? NSZeroRect)
            if let newContentView = newValue {
                newContentView.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
                darkContentView.addSubview(newContentView)
            }
            super.contentView = darkContentView
        }
        get {
            return super.contentView
        }
    }
    
    // MARK: - PiP Mode
    
    public var allowsPiPMode = false {
        didSet {
            applyAppearanceToWidgets()
            if isInPiPMode {
                exitPiPMode()
            }
        }
    }
    
    @objc public var isInPiPMode = false
    
    public override func toggleFullScreen(sender: AnyObject?) {
        if canEnterPiPMode || isInPiPMode {
            togglePiPMode(sender)
        } else {
            self.reallyDoToggleFullScreenImNotEvenKiddingItsRealThisTimeISwear(sender)
        }
    }
    
    @IBAction public func reallyDoToggleFullScreenImNotEvenKiddingItsRealThisTimeISwear(sender: AnyObject?) {
        super.toggleFullScreen(sender)
    }
    
    private var canEnterPiPMode: Bool {
        return allowsPiPMode && !isInPiPMode && !styleMask.contains(.FullScreen) && screen != nil
    }
    
    private var levelBeforePiPMode: Int = 0
    private var collectionBehaviorBeforePiPMode: NSWindowCollectionBehavior = []
    private var frameBeforePiPMode: NSRect = NSZeroRect
    
    @IBAction public func togglePiPMode(sender: AnyObject?) {
        if isInPiPMode {
            exitPiPMode()
        } else {
            enterPiPMode()
        }
    }
    
    private func enterPiPMode() {
        guard canEnterPiPMode else { return }
        guard !isInPiPMode else { return }
        
        willChangeValueForKey("isInPiPMode")
        
        hideTitlebar()
        isInPiPMode = true
        
        frameBeforePiPMode = frame
        levelBeforePiPMode = level
        collectionBehaviorBeforePiPMode = collectionBehavior
        
        collectionBehavior = [.CanJoinAllSpaces, .Stationary, .FullScreenPrimary]
        level = Int(CGWindowLevelForKey(CGWindowLevelKey.MaximumWindowLevelKey))
        setFrame(frameForPiPMode, display: true, animate: true)
        
        didChangeValueForKey("isInPiPMode")
    }
    
    private func exitPiPMode() {
        guard isInPiPMode else { return }
        
        willChangeValueForKey("isInPiPMode")
        isInPiPMode = false
        
        let aspectBeforePiP = aspectRatio
        resizeIncrements = NSSize(width: 1.0, height: 1.0)
        setFrame(frameBeforePiPMode, display: true, animate: true)
        aspectRatio = aspectBeforePiP
        
        collectionBehavior = collectionBehaviorBeforePiPMode
        level = levelBeforePiPMode
        didChangeValueForKey("isInPiPMode")
    }
    
    private var frameForPiPMode: NSRect {
        guard let screen = screen else { return frame }
        
        struct PiPConstants {
            static let width = CGFloat(320.0)
            static let height = CGFloat(134.0)
        }
        
        let baseRect = NSRect(
            x: 0,
            y: 0,
            width: PiPConstants.width,
            height: PiPConstants.height
        )
        
        var effectiveAspectRatio = aspectRatio
        if (effectiveAspectRatio == .zero) {
            effectiveAspectRatio = NSSize(width: 960.0, height: 400.0)
        }
        
        var effectiveRect = AVMakeRectWithAspectRatioInsideRect(effectiveAspectRatio, baseRect)
        
        effectiveRect.origin.x = screen.frame.width - effectiveRect.width - 40.0
        effectiveRect.origin.y = 40.0
        
        return effectiveRect
    }
    
}

private class EVTWindowContentView: NSView {
    
    private var overlayView: EVTWindowOverlayView?
    
    private func installOverlayView() {
        overlayView = EVTWindowOverlayView(frame: bounds)
        overlayView!.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
        addSubview(overlayView!, positioned: .Above, relativeTo: subviews.last)
    }
    
    private func moveOverlayViewToTop() {
        if overlayView == nil {
            installOverlayView()
        } else {
            overlayView!.removeFromSuperview()
            addSubview(overlayView!, positioned: .Above, relativeTo: subviews.last)
        }
    }
    
    private override func drawRect(dirtyRect: NSRect) {
        NSColor.blackColor().setFill()
        NSRectFill(dirtyRect)
    }
    
    private override func addSubview(aView: NSView) {
        super.addSubview(aView)
        
        if aView != overlayView {
            moveOverlayViewToTop()
        }
    }
    
}

private class EVTWindowOverlayView: NSView {
    
    private var evtWindow: EVTWindow? {
        return window as? EVTWindow
    }
    
    private var mouseTrackingArea: NSTrackingArea!
    
    private override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if mouseTrackingArea != nil {
            removeTrackingArea(mouseTrackingArea)
        }
        
        mouseTrackingArea = NSTrackingArea(rect: bounds, options: [.InVisibleRect, .MouseEnteredAndExited, .MouseMoved, .ActiveAlways], owner: self, userInfo: nil)
        addTrackingArea(mouseTrackingArea)
    }
    
    private var mouseIdleTimer: NSTimer!
    
    private func resetMouseIdleTimer() {
        if mouseIdleTimer != nil {
            mouseIdleTimer.invalidate()
            mouseIdleTimer = nil
        }
        
        mouseIdleTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(mouseIdleTimerAction(_:)), userInfo: nil, repeats: false)
    }
    
    @objc private func mouseIdleTimerAction(sender: NSTimer) {
        evtWindow?.hideTitlebar()
    }
    
    private override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(windowWillExitFullscreen), name: NSWindowWillExitFullScreenNotification, object: window)
        resetMouseIdleTimer()
    }
    
    @objc private func windowWillExitFullscreen() {
        resetMouseIdleTimer()
    }
    
    private override func mouseEntered(theEvent: NSEvent) {
        resetMouseIdleTimer()
        evtWindow?.showTitlebar()
    }
    
    private override func mouseExited(theEvent: NSEvent) {
        evtWindow?.hideTitlebar()
    }
    
    private override func mouseMoved(theEvent: NSEvent) {
        resetMouseIdleTimer()
        evtWindow?.showTitlebar()
    }
    
    private override func drawRect(dirtyRect: NSRect) {
        return
    }
    
    private override func mouseUp(event: NSEvent) {
        super.mouseUp(event)
        
        if event.clickCount == 2 {
            self.evtWindow?.reallyDoToggleFullScreenImNotEvenKiddingItsRealThisTimeISwear(self)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        mouseIdleTimer.invalidate()
        mouseIdleTimer = nil
    }
    
}
