import Combine
import Foundation
import UIKit

final class BalanceViewModel {
    private let stateSubject = CurrentValueSubject<BalanceViewState, Never>(.init())
    
    var statePublisher: AnyPublisher<BalanceViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private(set) var state: BalanceViewState {
        get { stateSubject.value }
        set { stateSubject.send(newValue) }
    }

    private var cancellables = Set<AnyCancellable>()
    private let service: BalanceService

    init(service: BalanceService) {
        self.service = service

        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in self?.state.isRedacted = true }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.state.isRedacted = false }
            .store(in: &cancellables)
    }

    func refreshBalance() {
        state.didFail = false
        state.isRefreshing = true
        service.refreshBalance { [weak self] result in
            self?.handleResult(result)
        }
    }

    private func handleResult(_ result: Result<BalanceResponse, Error>) {
        state.isRefreshing = false
        do {
            state.lastResponse = try result.get()
        } catch {
            state.didFail = true
        }
    }
}
