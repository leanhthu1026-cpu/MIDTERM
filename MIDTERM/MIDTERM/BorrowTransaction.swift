import Foundation

struct BorrowTransaction: Identifiable {
    let id = UUID()
    let equipmentID: String
    let borrowerName: String
    let borrowDate: Date
    let expectedReturnDate: Date
    var actualReturnDate: Date? = nil
    
    var isActive: Bool { actualReturnDate == nil }
}
