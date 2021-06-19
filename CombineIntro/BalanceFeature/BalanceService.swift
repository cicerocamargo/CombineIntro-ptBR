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
