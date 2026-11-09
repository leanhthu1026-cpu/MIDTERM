import Foundation
import Combine

class Equipment: Identifiable, ObservableObject {
    // Thuộc tính bất biến (Encapsulation)
    let id: String
    let purchaseYear: Int
    
    // Thuộc tính có thể cập nhật nhưng kiểm soát quyền ghi
    @Published private(set) var name: String
    @Published private(set) var manufacturer: String
    @Published private(set) var status: AvailabilityStatus
    
    init?(id: String, name: String, manufacturer: String, purchaseYear: Int) {
        let trimmedId = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Ràng buộc dữ liệu
        guard !trimmedId.isEmpty, !trimmedName.isEmpty, purchaseYear > 1990 && purchaseYear <= currentYear else {
            return nil
        }
        
        self.id = trimmedId
        self.name = trimmedName
        self.manufacturer = manufacturer.trimmingCharacters(in: .whitespacesAndNewlines)
        self.purchaseYear = purchaseYear
        self.status = .available
    }
    
    func updateDetails(name: String, manufacturer: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        self.name = trimmedName
        self.manufacturer = manufacturer.trimmingCharacters(in: .whitespacesAndNewlines)
        return true
    }
    
    func markAsBorrowed() -> Bool {
        guard status == .available else { return false }
        status = .borrowed
        return true
    }
    
    func markAsReturned() -> Bool {
        guard status == .borrowed else { return false }
        status = .available
        return true
    }
    
    var equipmentType: EquipmentType {
        return .laptop
    }
}
