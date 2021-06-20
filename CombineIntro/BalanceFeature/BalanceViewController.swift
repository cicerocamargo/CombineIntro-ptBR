import Combine
import Foundation
import UIKit

@dynamicMemberLookup
class BalanceViewController: UIViewController {
    private let rootView = BalanceView()
    private let viewModel: BalanceViewModel
    private let formatDate: (Date) -> String
    private var cancellables = Set<AnyCancellable>()

    init(
        service: BalanceService,
        formatDate: @escaping (Date) -> String = BalanceViewState.relativeDateFormatter.string(from:)
    ) {
        self.viewModel = .init(service: service)
        self.formatDate = formatDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$state
            .sink { [weak self] in self?.updateView(state: $0) }
            .store(in: &cancellables)

        rootView.refreshButton.touchUpInsidePublisher
            .map { _ in BalanceViewEvent.refreshButtonWasTapped }
            .subscribe(viewModel.eventSubject)
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.receiveEvent(.viewDidAppear)
    }

    private func updateView(state: BalanceViewState) {
        rootView.refreshButton.isHidden = state.isRefreshing
        if state.isRefreshing {
            rootView.activityIndicator.startAnimating()
        } else {
            rootView.activityIndicator.stopAnimating()
        }
        rootView.valueLabel.text = state.formattedBalance
        rootView.valueLabel.alpha = state.isRedacted
            ? BalanceView.alphaForRedactedValueLabel
            : 1
        rootView.infoLabel.text = state.infoText(formatDate: formatDate)
        rootView.infoLabel.textColor = state.infoColor
        rootView.redactedOverlay.isHidden = !state.isRedacted

        view.setNeedsLayout()
    }
}

#if DEBUG
import SwiftUI

struct BalanceViewController_Previews: PreviewProvider {
    static private func makePreview() -> some View {
        BalanceViewController(service: FakeBalanceService())
            .staticRepresentable
    }

    static var previews: some View {
        Group {
            makePreview()
                .preferredColorScheme(.dark)
            
            makePreview()
                .preferredColorScheme(.light)
        }
    }
}

// To help with tests
extension BalanceViewController {
    subscript<T>(dynamicMember keyPath: KeyPath<BalanceView, T>) -> T {
        rootView[keyPath: keyPath]
    }
}
#endif
