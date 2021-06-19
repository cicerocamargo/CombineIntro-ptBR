import Combine
import UIKit

final class PublisherButton: UIButton {
    private lazy var touchUpInsideSubject: PassthroughSubject<Void, Never> = {
        let subject = PassthroughSubject<Void, Never>()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return subject
    }()

    @objc private func handleTap() {
        touchUpInsideSubject.send()
    }

    var touchUpInsidePublisher: AnyPublisher<Void, Never> {
        touchUpInsideSubject.eraseToAnyPublisher()
    }
}
