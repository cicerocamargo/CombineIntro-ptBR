import UIKit
import SwiftUI

extension UIViewController {
    private struct SwiftUIViewControllerWrapper: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Self.Context) -> UIViewController {
            viewController
        }
        
        func updateUIViewController(
            _ uiViewController: UIViewController,
            context: Self.Context
        ) {}
    }
    
    var staticRepresentable: some View {
        SwiftUIViewControllerWrapper(viewController: self)
    }
}
