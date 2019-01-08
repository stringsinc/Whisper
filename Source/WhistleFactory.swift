import UIKit

public enum WhistleAction {
  case present
  case show(TimeInterval)
}

let whistleFactory = WhistleFactory()

open class WhistleFactory: UIViewController {

  open lazy var whistleWindow: UIWindow = UIWindow()

  public struct Dimensions {

    static var notchHeight: CGFloat {
      if UIApplication.shared.statusBarFrame.height > 20 {
        return 32.0
      } else {
        return 0.0
      }
    }
  }

  open lazy var titleLabelHeight = CGFloat(20.0)

  open lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center

    return label
  }()
    
  open fileprivate(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
      let gesture = UITapGestureRecognizer()
      gesture.addTarget(self, action: #selector(WhistleFactory.handleTapGestureRecognizer))
        
      return gesture
  }()

  open fileprivate(set) var murmur: Murmur?
  open var viewController: UIViewController?
  open var hideTimer = Timer()

  private weak var previousKeyWindow: UIWindow?

  // MARK: - Initializers

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)

    setupWindow()
    view.clipsToBounds = true
    view.addSubview(titleLabel)
    
    view.addGestureRecognizer(tapGestureRecognizer)

    NotificationCenter.default.addObserver(self, selector: #selector(WhistleFactory.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }

  // MARK: - Configuration

  open func whistler(_ murmur: Murmur, action: WhistleAction) {
    self.murmur = murmur
    titleLabel.text = murmur.title
    titleLabel.font = murmur.font
    titleLabel.textColor = murmur.titleColor
    view.backgroundColor = murmur.backgroundColor
    whistleWindow.backgroundColor = murmur.backgroundColor

    moveWindowToFront()
    setupFrames()

    switch action {
    case .show(let duration):
      show(duration: duration)
    default:
      present()
    }
  }

  // MARK: - Setup

  open func setupWindow() {
    whistleWindow.addSubview(self.view)
    whistleWindow.clipsToBounds = true
    moveWindowToFront()
  }

  func moveWindowToFront() {
    whistleWindow.windowLevel = view.isiPhoneX ? UIWindowLevelNormal : UIWindowLevelStatusBar
    setNeedsStatusBarAppearanceUpdate()
  }

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIApplication.shared.statusBarStyle
  }

  open func setupFrames() {
    whistleWindow = UIWindow()

    setupWindow()

    let labelWidth = UIScreen.main.bounds.width
    let defaultHeight = CGFloat(20.0)   // stringsinc: Always default to 20px Whistles

    if let text = titleLabel.text {
      let neededDimensions =
        NSString(string: text).boundingRect(
          with: CGSize(width: labelWidth, height: CGFloat.infinity),
          options: NSStringDrawingOptions.usesLineFragmentOrigin,
          attributes: [NSAttributedStringKey.font: titleLabel.font],
          context: nil
        )
      titleLabelHeight = CGFloat(neededDimensions.size.height)
      titleLabel.numberOfLines = 0 // Allows unwrapping

      if titleLabelHeight < defaultHeight {
        titleLabelHeight = defaultHeight
      }
    } else {
      titleLabel.sizeToFit()
    }

<<<<<<< HEAD
    // stringsinc: Don't use safeYCoordinate here because that puts the view below the status bar on regular phones and intrudes on the nav bar on iPhone X.
    whistleWindow.frame = CGRect(x: 0, y: 0,
                                 width: labelWidth,
                                 height: titleLabelHeight)

    // stringsinc: For iPhone X, expand the window height from the top of the screen to below the notch. The title label will be positioned just below the notch.
    let iPhoneXThreshold = CGFloat(20) // This assumes anything greater than 20 must be iPhone X. 20 is the standard safe area for the status bar. The iPhone X usually has a safe area that is 44.
    if #available(iOS 11.0, *) {
        let topInset = view.safeAreaInsets.top
        if topInset > iPhoneXThreshold {
            whistleWindow.frame.size.height += topInset - 16 // reduced some because we know the notch doesn't take up the whole safe area.
        }
    }

    view.frame = whistleWindow.bounds
    titleLabel.frame = view.bounds

    // stringsinc: For iPhone X, place the title label just below the notch. The window has been expanded already to accommodate the label.
    if #available(iOS 11.0, *) {
        let topInset = view.safeAreaInsets.top
        if topInset > iPhoneXThreshold {
            titleLabel.frame.origin.y += titleLabel.frame.size.height - titleLabelHeight
            titleLabel.frame.size.height = titleLabelHeight
        }
    }
=======
    whistleWindow.frame = CGRect(x: 0, y: 0,
                                 width: labelWidth,
                                 height: titleLabelHeight + Dimensions.notchHeight)
    view.frame = whistleWindow.bounds

    titleLabel.frame = CGRect(
        x: 0.0,
        y: Dimensions.notchHeight,
        width: view.bounds.width,
        height: titleLabelHeight
    )
>>>>>>> upstream/master
  }

  // MARK: - Movement methods

  public func show(duration: TimeInterval) {
    present()
    calm(after: duration)
  }

  public func present() {
    hideTimer.invalidate()

    if UIApplication.shared.keyWindow != whistleWindow {
      previousKeyWindow = UIApplication.shared.keyWindow
    }

    let initialOrigin = whistleWindow.frame.origin.y
<<<<<<< HEAD
    whistleWindow.frame.origin.y = initialOrigin - titleLabelHeight
    whistleWindow.isHidden = false  // stringsinc: this makes it so showing the whistle does not also dismiss the keyboard (in lieu of makeKeyAndVisible())
=======
    whistleWindow.frame.origin.y = initialOrigin - titleLabelHeight - Dimensions.notchHeight
    whistleWindow.isHidden = false
>>>>>>> upstream/master
    UIView.animate(withDuration: 0.2, animations: {
      self.whistleWindow.frame.origin.y = initialOrigin
    })
  }

  public func hide() {
    let finalOrigin = view.frame.origin.y - titleLabelHeight - Dimensions.notchHeight
    UIView.animate(withDuration: 0.2, animations: {
      self.whistleWindow.frame.origin.y = finalOrigin
      }, completion: { _ in
        if let window = self.previousKeyWindow {
          window.isHidden = false
          self.whistleWindow.windowLevel = UIWindowLevelNormal - 1
          self.previousKeyWindow = nil
          window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    })
  }

  public func calm(after: TimeInterval) {
    hideTimer.invalidate()
    hideTimer = Timer.scheduledTimer(timeInterval: after, target: self, selector: #selector(WhistleFactory.timerDidFire), userInfo: nil, repeats: false)
  }

  // MARK: - Timer methods

    @objc public func timerDidFire() {
    hide()
  }

    @objc func orientationDidChange() {
    if whistleWindow.isKeyWindow {
      setupFrames()
      hide()
    }
  }
    
  // MARK: - Gesture methods
    
  @objc fileprivate func handleTapGestureRecognizer() {
      guard let murmur = murmur else { return }
      murmur.action?()
  }
}
