import Foundation
import Combine

class LibraryEquipmentController: ObservableObject {
    @Published var inventory: [Equipment] = []
    @Published var transactions: [BorrowTransaction] = []
    
    init() {
        seedSampleData()
    }
    
    private func seedSampleData() {
        if let mac = Laptop(id: "LP01", name: "MacBook Pro M2", manufacturer: "Apple", purchaseYear: 2023, processor: "Apple M2", ramGB: 16, storageGB: 512) {
            inventory.append(mac)
        }
        if let ipad = Tablet(id: "TB01", name: "iPad Pro 11", manufacturer: "Apple", purchaseYear: 2024, screenSize: 11.0, batteryCapacity: 7538, supportsPen: true) {
            inventory.append(ipad)
        }
        if let sony = DigitalCamera(id: "DC01", name: "Sony Alpha A7 IV", manufacturer: "Sony", purchaseYear: 2023, resolutionMP: 33.0, opticalZoom: "4x", videoResolution: "4K 60fps") {
            inventory.append(sony)
        }
    }
    
    // Quản lý thiết bị
    func registerEquipment(_ item: Equipment) -> (success: Bool, message: String) {
        if inventory.contains(where: { $0.id.caseInsensitiveCompare(item.id) == .orderedSame }) {
            return (false, "Error: Equipment with ID '\(item.id)' already exists.")
        }
        inventory.append(item)
        return (true, "Equipment '\(item.name)' registered successfully.")
    }
    
    // Mượn thiết bị
    func borrowEquipment(equipment: Equipment, borrowerName: String, expectedReturn: Date) -> (success: Bool, message: String) {
        let trimmedBorrower = borrowerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBorrower.isEmpty else {
            return (false, "Error: Borrower name cannot be empty.")
        }
        guard expectedReturn > Date() else {
            return (false, "Error: Expected return date must be in the future.")
        }
        guard equipment.status == .available else {
            return (false, "Error: Equipment is currently not available.")
        }
        
        if equipment.markAsBorrowed() {
            let tx = BorrowTransaction(equipmentID: equipment.id, borrowerName: trimmedBorrower, borrowDate: Date(), expectedReturnDate: expectedReturn)
            transactions.append(tx)
            objectWillChange.send()
            return (true, "Successfully borrowed '\(equipment.name)' for \(trimmedBorrower).")
        }
        return (false, "Transaction failed.")
    }
    
    // Trả thiết bị
    func returnEquipment(equipment: Equipment) -> (success: Bool, message: String) {
        guard equipment.status == .borrowed else {
            return (false, "Error: Cannot return item. It is not currently on loan.")
        }
        
        if let index = transactions.firstIndex(where: { $0.equipmentID == equipment.id && $0.isActive }) {
            transactions[index].actualReturnDate = Date()
        }
        
        if equipment.markAsReturned() {
            objectWillChange.send()
            return (true, "'\(equipment.name)' returned successfully.")
        }
        return (false, "Return process failed.")
    }
    
    func getActiveTransaction(for equipmentID: String) -> BorrowTransaction? {
        transactions.first(where: { $0.equipmentID == equipmentID && $0.isActive })
    }
}
