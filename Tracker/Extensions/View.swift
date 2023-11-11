import UIKit

extension UIViewController {

    func handTapHiddenKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func hiddenKeyboard() {
        view.endEditing(true)
    }
}
