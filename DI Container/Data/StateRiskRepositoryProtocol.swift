
import Foundation

protocol StateRiskRepositoryProtocol: AnyObject {
    func fetchAll() -> [StateRisk]
    func fetchCurrent() -> StateRisk?
    func saveCurrent(_ state: StateRisk)
}
