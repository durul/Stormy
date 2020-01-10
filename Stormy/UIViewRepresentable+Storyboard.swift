//
//  ViewControllerRepresentable.swift
//  Stormy

#if canImport(SwiftUI) && DEBUG

import SwiftUI

extension UIViewRepresentable {

    func makeUIView(context: Context, storyboard: UIStoryboard, identifier: String) -> UIView {
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController.view
    }
}

#endif
