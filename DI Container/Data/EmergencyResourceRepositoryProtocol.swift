

import Foundation

protocol EmergencyResourceRepositoryProtocol: AnyObject {
    func fetchAll() -> [EmergencyResource]
    func fetch(byType type: EmergencyResource.ResourceType) -> [EmergencyResource]
}
