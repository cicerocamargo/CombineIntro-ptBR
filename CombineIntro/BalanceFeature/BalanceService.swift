import Combine
import Foundation

struct BalanceResponse {
    let balance: Double
    let date: Date
}

protocol BalanceService {
    func refreshBalance(
        completion: @escaping (Result<BalanceResponse, Error>) -> Void
    )
}

extension BalanceService {
    func refreshBalance() -> AnyPublisher<BalanceResponse, Error> {
        Future { promise in
            self.refreshBalance(completion: promise)
        }
        .eraseToAnyPublisher()
    }
}

#if DEBUG
struct FakeBalanceService: BalanceService {
    func refreshBalance(
        completion: @escaping (Result<BalanceResponse, Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if Bool.random() {
                completion(
                    .success(BalanceResponse(balance: 100, date: Date()))
                )
            } else {
                completion(
                    .failure(NSError(domain: "", code: -1, userInfo: .none))
                )
            }
        }
    }
}
#endif
