import Foundation

class Laptop: Equipment {
    private(set) var processor: String
    private(set) var ramGB: Int
    private(set) var storageGB: Int
    
    init?(id: String, name: String, manufacturer: String, purchaseYear: Int, processor: String, ramGB: Int, storageGB: Int) {
        let trimmedProc = processor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ramGB > 0, storageGB > 0, !trimmedProc.isEmpty else {
            return nil
        }
        self.processor = trimmedProc
        self.ramGB = ramGB
        self.storageGB = storageGB
        
        super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }
    
    func updateSpecs(processor: String, ramGB: Int, storageGB: Int) -> Bool {
        let trimmedProc = processor.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ramGB > 0, storageGB > 0, !trimmedProc.isEmpty else { return false }
        self.processor = trimmedProc
        self.ramGB = ramGB
        self.storageGB = storageGB
        return true
    }
    
    override var equipmentType: EquipmentType { .laptop }
}
