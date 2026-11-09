import Foundation

class DigitalCamera: Equipment {
    private(set) var resolutionMP: Double
    private(set) var opticalZoom: String
    private(set) var videoResolution: String
    
    init?(id: String, name: String, manufacturer: String, purchaseYear: Int, resolutionMP: Double, opticalZoom: String, videoResolution: String) {
        guard resolutionMP > 0 else { return nil }
        
        self.resolutionMP = resolutionMP
        self.opticalZoom = opticalZoom.trimmingCharacters(in: .whitespacesAndNewlines)
        self.videoResolution = videoResolution.trimmingCharacters(in: .whitespacesAndNewlines)
        
        super.init(id: id, name: name, manufacturer: manufacturer, purchaseYear: purchaseYear)
    }
    
    func updateSpecs(resolutionMP: Double, opticalZoom: String, videoResolution: String) -> Bool {
        guard resolutionMP > 0 else { return false }
        self.resolutionMP = resolutionMP
        self.opticalZoom = opticalZoom.trimmingCharacters(in: .whitespacesAndNewlines)
        self.videoResolution = videoResolution.trimmingCharacters(in: .whitespacesAndNewlines)
        return true
    }
    
    override var equipmentType: EquipmentType { .camera }
}
