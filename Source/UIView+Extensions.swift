import UIKit

extension UIView {
  var safeYCoordinate: CGFloat {
    let y: CGFloat
    if #available(iOS 11.0, *) {
      y = safeAreaInsets.top
    } else {
      y = 0
    }

    return y
  }
<<<<<<< HEAD
=======

  var isiPhoneX: Bool {
    return safeYCoordinate > 20
  }
>>>>>>> upstream/master
}
