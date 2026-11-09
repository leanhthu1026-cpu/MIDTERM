import Foundation

class Tablet: Equipment {
    private(set) var screenSizeInches: Double
    private(set) var batteryCapacityMAh: Int
    private(set) var supportsPen: Bool
    
    init?(id: String, name: String, manufacturer: String, purchaseYear: Int, screenSize: Double, batteryCapacity: Int, supportsPen: Bool) {
        guard screenSize > 0, batteryCapacity > 0 else { return nil }
        self.screenSizeInches = screenSize
        self.batteryCapacityMAh = batteryCapacity
        self.supportsPen = supportsPen
        
        super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }
    
    func updateSpecs(screenSize: Double, batteryCapacity: Int, supportsPen: Bool) -> Bool {
        guard screenSize > 0, batteryCapacity > 0 else { return false }
        self.screenSizeInches = screenSize
        self.batteryCapacityMAh = batteryCapacity
        self.supportsPen = supportsPen
        return true
    }
    
    override var equipmentType: EquipmentType { .tablet }
}
