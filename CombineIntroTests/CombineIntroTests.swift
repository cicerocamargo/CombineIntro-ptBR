@testable import CombineIntro
import XCTest

class BalanceViewControllerTests: XCTestCase {

    // MARK: - Bindings

    func test_whenViewAppears_balanceIsRefreshed() {
        let (_, service) = makeSUT()
        XCTAssertEqual(service.refreshCount, 1)
    }

    func test_whenRefreshButtonIsTapped_balanceIsRefreshed() {
        let (sut, service) = makeSUT()

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(service.refreshCount, 2)
    }

    // MARK: - Refreshing

    func test_whileTheresNoBalanceToShow_valueLabelShowsAPlaceholder() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.valueLabel.text, BalanceViewState.valuePlaceholder)
    }

    func test_whenIsRefreshing_infoLabelShowsLoadingText() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.infoLabel.text, "Loading...")
    }

    func test_whenIsRefreshing_activityIndicatorIsAnimating() {
        let (sut, _) = makeSUT()
        XCTAssert(sut.activityIndicator.isAnimating)
    }

    func test_whenIsRefreshing_refreshButtonIsHidden() {
        let (sut, _) = makeSUT()
        XCTAssert(sut.refreshButton.isHidden)
    }

    // MARK: - Loaded from empty state

    func test_whenBalanceLoads_valueLabelShowsItFormattedAsCurrency() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        XCTAssertEqual(sut.valueLabel.text, "$1.23")
    }

    func test_whenBalanceLoads_infoLabelShowsLastUpdatedText() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        XCTAssertEqual(sut.infoLabel.text, "Last update: \(Self.formattedDate).")
    }

    func test_whenBalanceLoads_infoColorIsRegular() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        XCTAssertEqual(
            sut.infoLabel.textColor,
            BalanceViewState.regularInfoColor
        )
    }

    func test_whenBalanceLoads_activityIndicatorIsNotAnimating() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        XCTAssertFalse(sut.activityIndicator.isAnimating)
    }

    func test_whenBalanceLoads_refreshButtonIsVisible() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        XCTAssertFalse(sut.refreshButton.isHidden)
    }

    // MARK: - Failed from empty state

    func test_whenBalanceFailsToLoad_activityIndicatorIsNotAnimating() {
        let (sut, _) = makeSUT(serviceResult: .failure(ErrorStub()))
        XCTAssertFalse(sut.activityIndicator.isAnimating)
    }

    func test_whenBalanceFailsToLoad_refreshButtonIsVisible() {
        let (sut, _) = makeSUT(serviceResult: .failure(ErrorStub()))
        XCTAssertFalse(sut.refreshButton.isHidden)
    }

    func test_whenBalanceFailsToLoad_infoLabelShowsErrorText() {
        let (sut, _) = makeSUT(serviceResult: .failure(ErrorStub()))
        XCTAssertEqual(sut.infoLabel.text, "Failed to update.")
    }

    func test_whenBalanceFailsToLoad_infoColorFailure() {
        let (sut, _) = makeSUT(serviceResult: .failure(ErrorStub()))
        XCTAssertEqual(
            sut.infoLabel.textColor,
            BalanceViewState.failureInfoColor
        )
    }

    // MARK: - Refreshing after load

    func test_whenIsRefreshingAfterLoad_valueLabelShowsLastValue() {
        let (sut, service) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        service.result = nil

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(sut.valueLabel.text, "$1.23")
    }

    func test_whenIsRefreshingAfterLoad_infoLabelShowsLoadingAndLastUpdatedDate() {
        let (sut, service) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        service.result = nil

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(
            sut.infoLabel.text,
            "Loading... Last update: \(Self.formattedDate)."
        )
    }

    // MARK: - Refreshing after failure

    func test_whenIsRefreshingAfterFailure_infoColorIsRegular() {
        let (sut, service) = makeSUT(serviceResult: .failure(ErrorStub()))
        service.result = nil

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(
            sut.infoLabel.textColor,
            BalanceViewState.regularInfoColor
        )
    }

    // MARK: - Failure after load

    func test_whenItFailsAfterLoad_valueLabelShowsLastValue() {
        let (sut, service) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        service.result = .failure(ErrorStub())

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(sut.valueLabel.text, "$1.23")
    }

    func test_whenItFailsAfterLoad_infoLabelShowsFailedAndLastUpdatedDate() {
        let (sut, service) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )
        service.result = .failure(ErrorStub())

        sut.refreshButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(
            sut.infoLabel.text,
            "Failed to update. Last update: \(Self.formattedDate)."
        )
    }

    // MARK: - Redaction

    func test_whileAppIsInactive_balanceIsRedacted() {
        let (sut, _) = makeSUT(
            serviceResult: .success(.init(balance: 1.23456, date: .init()))
        )

        XCTAssertEqual(sut.valueLabel.alpha, 1)
        XCTAssert(sut.redactedOverlay.isHidden)

        NotificationCenter.default.post(
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        XCTAssertEqual(
            sut.valueLabel.alpha,
            BalanceView.alphaForRedactedValueLabel,
            accuracy: 0.001
        )
        XCTAssertFalse(sut.redactedOverlay.isHidden)

        NotificationCenter.default.post(
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        XCTAssertEqual(sut.valueLabel.alpha, 1)
        XCTAssert(sut.redactedOverlay.isHidden)
    }
}

private extension BalanceViewControllerTests {
    static let formattedDate = "00/00/0000 00:00:00 AM"

    struct ErrorStub: Error {}

    func makeSUT(
        serviceResult: Result<BalanceResponse, Error>? = nil
    ) -> (BalanceViewController, BalanceServiceStub) {
        let service = BalanceServiceStub()
        service.result = serviceResult
        let sut = BalanceViewController(
            service: service,
            formatDate: { _ in Self.formattedDate }
        )
        _ = sut.view
        sut.viewWillAppear(false)
        sut.viewDidAppear(false)
        return (sut, service)
    }

    class BalanceServiceStub: BalanceService {
        private(set) var refreshCount = 0
        var result: Result<BalanceResponse, Error>?

        func refreshBalance(
            completion: @escaping (Result<BalanceResponse, Error>) -> Void
        ) {
            refreshCount += 1
            if let result = result {
                completion(result)
            }
        }
    }
}
