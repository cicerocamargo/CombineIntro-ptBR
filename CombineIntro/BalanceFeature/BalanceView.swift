import UIKit

class BalanceView: UIView {
    static let alphaForRedactedValueLabel: CGFloat = 0.0001

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Your Balance"
        return label
    }()

    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()

    let redactedOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 5
        return view
    }()

    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()

    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

    let refreshButton: PublisherButton = {
        let button = PublisherButton(type: .system)
        button.setImage(.init(systemName: "arrow.clockwise"), for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground

        let mainStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                valueLabel,
                infoLabel,
                UIView()
            ]
        )
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)

        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(refreshButton)

        redactedOverlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(redactedOverlay)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(
                equalTo: readableContentGuide.topAnchor,
                constant: 8
            ),
            mainStack.bottomAnchor.constraint(
                equalTo: readableContentGuide.bottomAnchor,
                constant: 8
            ),
            mainStack.trailingAnchor.constraint(
                equalTo: readableContentGuide.trailingAnchor
            ),
            mainStack.leadingAnchor.constraint(
                equalTo: readableContentGuide.leadingAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: valueLabel.centerYAnchor
            ),
            activityIndicator.trailingAnchor.constraint(
                equalTo: readableContentGuide.trailingAnchor
            ),
            refreshButton.centerYAnchor.constraint(
                equalTo: valueLabel.centerYAnchor
            ),
            refreshButton.trailingAnchor.constraint(
                equalTo: readableContentGuide.trailingAnchor
            ),
            redactedOverlay.topAnchor.constraint(equalTo: valueLabel.topAnchor),
            redactedOverlay.rightAnchor.constraint(equalTo: valueLabel.rightAnchor),
            redactedOverlay.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor),
            redactedOverlay.leftAnchor.constraint(equalTo: valueLabel.leftAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
