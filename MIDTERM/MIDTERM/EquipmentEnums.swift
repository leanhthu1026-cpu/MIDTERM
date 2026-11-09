import Foundation

enum EquipmentType: String, CaseIterable, Identifiable {
    case laptop = "Laptop"
    case tablet = "Tablet"
    case camera = "Digital Camera"
    
    var id: String { rawValue }
}

enum AvailabilityStatus: String {
    case available = "Available"
    case borrowed = "On Loan"
}
