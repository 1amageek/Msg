//
//  UIScrollView+Scroll.swift
//  Msg
//
//  Created by 1amageek on 2018/01/19.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit

extension UIScrollView {

    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        if let viewController: UIViewController = self.delegate as? UIViewController {
            viewController.viewSafeAreaInsetsDidChange()
        }
    }

    var offsetToBottom: CGPoint {
        let visibleHeight: CGFloat = self.bounds.height - self.safeAreaInsets.top - self.contentInset.bottom - self.safeAreaInsets.bottom
        let offsetY: CGFloat = max(self.contentSize.height + self.safeAreaInsets.top - visibleHeight, 0)
        return CGPoint(x: 0, y: offsetY)
    }

    func scrollsToBottom(_ animated: Bool) {
        let visibleHeight: CGFloat = self.bounds.height - self.safeAreaInsets.top - self.contentInset.bottom - self.safeAreaInsets.bottom
        if self.contentSize.height > visibleHeight {
            self.setContentOffset(offsetToBottom, animated: animated)
        }
    }
}
