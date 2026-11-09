import SwiftUI

enum ManagementMode {
    case register
    case edit(Equipment)
}

struct EquipmentManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var controller: LibraryEquipmentController
    let mode: ManagementMode
    
    // Core fields
    @State private var selectedType: EquipmentType = .laptop
    @State private var idCode: String = ""
    @State private var name: String = ""
    @State private var manufacturer: String = ""
    @State private var purchaseYear: String = "2024"
    
    // Laptop fields
    @State private var processor: String = ""
    @State private var ramGB: String = "8"
    @State private var storageGB: String = "256"
    
    // Tablet fields
    @State private var screenSize: String = "10.5"
    @State private var batteryCapacity: String = "7000"
    @State private var supportsPen: Bool = true
    
    // Camera fields
    @State private var resolutionMP: String = "24.0"
    @State private var opticalZoom: String = "3x"
    @State private var videoResolution: String = "4K"
    
    // Alert feedback
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background D4
                Image("D4")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                Form {
                    if !isEditMode {
                        Section("Equipment Category") {
                            Picker("Type", selection: $selectedType) {
                                ForEach(EquipmentType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                        }
                    }
                    
                    Section("Core Properties (Immutable)") {
                        TextField("ID Code", text: $idCode)
                            .disabled(isEditMode) // Khóa ID khi chỉnh sửa
                            .foregroundColor(isEditMode ? .secondary : .primary)
                        
                        TextField("Purchase Year", text: $purchaseYear)
                            .keyboardType(.numberPad)
                            .disabled(isEditMode) // Khóa năm mua khi chỉnh sửa
                            .foregroundColor(isEditMode ? .secondary : .primary)
                    }
                    
                    Section("Permitted Editable Fields") {
                        TextField("Equipment Name", text: $name)
                        TextField("Manufacturer", text: $manufacturer)
                    }
                    
                    Section("Category-Specific Details") {
                        switch selectedType {
                        case .laptop:
                            TextField("Processor (e.g. M2, Intel i7)", text: $processor)
                            TextField("RAM (GB)", text: $ramGB).keyboardType(.numberPad)
                            TextField("Storage (GB)", text: $storageGB).keyboardType(.numberPad)
                        case .tablet:
                            TextField("Screen Size (Inches)", text: $screenSize).keyboardType(.decimalPad)
                            TextField("Battery (mAh)", text: $batteryCapacity).keyboardType(.numberPad)
                            Toggle("Supports Digital Pen", isOn: $supportsPen)
                        case .camera:
                            TextField("Resolution (Megapixels)", text: $resolutionMP).keyboardType(.decimalPad)
                            TextField("Optical Zoom (e.g. 5x)", text: $opticalZoom)
                            TextField("Video Resolution (e.g. 4K 60fps)", text: $videoResolution)
                        }
                    }
                    
                    Section {
                        Button(action: saveChanges) {
                            Text(isEditMode ? "Save Changes" : "Register Equipment")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .bold()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditMode ? "Edit Equipment" : "New Registration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: populateDataIfEdit)
            .alert("Notice", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") || alertMessage.contains("Updated") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func populateDataIfEdit() {
        if case .edit(let item) = mode {
            idCode = item.id
            name = item.name
            manufacturer = item.manufacturer
            purchaseYear = "\(item.purchaseYear)"
            selectedType = item.equipmentType
            
            if let laptop = item as? Laptop {
                processor = laptop.processor
                ramGB = "\(laptop.ramGB)"
                storageGB = "\(laptop.storageGB)"
            } else if let tablet = item as? Tablet {
                screenSize = "\(tablet.screenSizeInches)"
                batteryCapacity = "\(tablet.batteryCapacityMAh)"
                supportsPen = tablet.supportsPen
            } else if let camera = item as? DigitalCamera {
                resolutionMP = "\(camera.resolutionMP)"
                opticalZoom = camera.opticalZoom
                videoResolution = camera.videoResolution
            }
        }
    }
    
    private func saveChanges() {
        if case .edit(let item) = mode {
            guard item.updateDetails(name: name, manufacturer: manufacturer) else {
                alertMessage = "Name cannot be empty."
                showAlert = true
                return
            }
            
            if let laptop = item as? Laptop {
                _ = laptop.updateSpecs(processor: processor, ramGB: Int(ramGB) ?? 0, storageGB: Int(storageGB) ?? 0)
            } else if let tablet = item as? Tablet {
                _ = tablet.updateSpecs(screenSize: Double(screenSize) ?? 0, batteryCapacity: Int(batteryCapacity) ?? 0, supportsPen: supportsPen)
            } else if let camera = item as? DigitalCamera {
                _ = camera.updateSpecs(resolutionMP: Double(resolutionMP) ?? 0, opticalZoom: opticalZoom, videoResolution: videoResolution)
            }
            
            alertMessage = "Updated successfully!"
            showAlert = true
        } else {
            guard let year = Int(purchaseYear) else {
                alertMessage = "Invalid purchase year."
                showAlert = true
                return
            }
            
            var newItem: Equipment?
            switch selectedType {
            case .laptop:
                newItem = Laptop(id: idCode, name: name, manufacturer: manufacturer, purchaseYear: year, processor: processor, ramGB: Int(ramGB) ?? 0, storageGB: Int(storageGB) ?? 0)
            case .tablet:
                newItem = Tablet(id: idCode, name: name, manufacturer: manufacturer, purchaseYear: year, screenSize: Double(screenSize) ?? 0, batteryCapacity: Int(batteryCapacity) ?? 0, supportsPen: supportsPen)
            case .camera:
                newItem = DigitalCamera(id: idCode, name: name, manufacturer: manufacturer, purchaseYear: year, resolutionMP: Double(resolutionMP) ?? 0, opticalZoom: opticalZoom, videoResolution: videoResolution)
            }
            
            guard let validItem = newItem else {
                alertMessage = "Invalid input values. Please ensure all text fields are filled and numbers are greater than 0."
                showAlert = true
                return
            }
            
            let res = controller.registerEquipment(validItem)
            alertMessage = res.message
            showAlert = true
        }
    }
}
