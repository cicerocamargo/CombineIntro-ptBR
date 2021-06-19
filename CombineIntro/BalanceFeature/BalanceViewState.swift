import Foundation
import UIKit

struct BalanceViewState {
    var lastResponse: BalanceResponse?
    var didFail = false
    var isRefreshing = false
    var isRedacted = false
}

extension BalanceViewState {
    static let valuePlaceholder = "--"
    static let regularInfoColor = UIColor.systemGray
    static let failureInfoColor = UIColor.systemRed

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .init(identifier: "en_US")
        return formatter
    }()

    static let relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var formattedBalance: String {
        lastResponse
            .map(\.balance)
            .flatMap {
                Self.currencyFormatter.string(from: NSNumber(value: $0))
            }
            ?? Self.valuePlaceholder
    }

    func infoText(formatDate: (Date) -> String) -> String {
        var infoTexts: [String] = []

        if didFail {
            infoTexts.append("Failed to update.")
        } else if isRefreshing {
            infoTexts.append("Loading...")
        }

        if let response = lastResponse {
            infoTexts.append("Last update: \(formatDate(response.date)).")
        }

        return infoTexts.joined(separator: " ")
    }

    var infoColor: UIColor {
        didFail ? Self.failureInfoColor : Self.regularInfoColor
    }
}
