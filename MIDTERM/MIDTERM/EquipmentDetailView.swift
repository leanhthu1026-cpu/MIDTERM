import SwiftUI

struct EquipmentDetailView: View {
    @ObservedObject var equipment: Equipment
    @ObservedObject var controller: LibraryEquipmentController
    
    @State private var showingEditSheet = false
    @State private var showingBorrowSheet = false
    @State private var borrowerName = ""
    @State private var expectedReturn = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Background D3
            Image("D3")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.3)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Thông tin chung
                    VStack(alignment: .leading, spacing: 10) {
                        Text("General Information")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        detailRow(title: "ID Code", value: equipment.id)
                        detailRow(title: "Name", value: equipment.name)
                        detailRow(title: "Manufacturer", value: equipment.manufacturer)
                        detailRow(title: "Purchase Year", value: "\(equipment.purchaseYear)")
                        detailRow(title: "Status", value: equipment.status.rawValue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Thông số kỹ thuật theo từng loại (Polymorphism / Downcasting)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Technical Specifications (\(equipment.equipmentType.rawValue))")
                            .font(.headline)
                            .foregroundColor(.indigo)
                        
                        if let laptop = equipment as? Laptop {
                            detailRow(title: "Processor", value: laptop.processor)
                            detailRow(title: "RAM", value: "\(laptop.ramGB) GB")
                            detailRow(title: "Storage", value: "\(laptop.storageGB) GB")
                        } else if let tablet = equipment as? Tablet {
                            detailRow(title: "Screen Size", value: String(format: "%.1f inches", tablet.screenSizeInches))
                            detailRow(title: "Battery", value: "\(tablet.batteryCapacityMAh) mAh")
                            detailRow(title: "Pen Support", value: tablet.supportsPen ? "Yes" : "No")
                        } else if let camera = equipment as? DigitalCamera {
                            detailRow(title: "Resolution", value: String(format: "%.1f MP", camera.resolutionMP))
                            detailRow(title: "Optical Zoom", value: camera.opticalZoom)
                            detailRow(title: "Video Resolution", value: camera.videoResolution)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Chi tiết giao dịch đang mượn (nếu có)
                    if equipment.status == .borrowed, let tx = controller.getActiveTransaction(for: equipment.id) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Active Loan Details")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Text("Borrower: \(tx.borrowerName)")
                            Text("Due Date: \(tx.expectedReturnDate.formatted(date: .abbreviated, time: .omitted))")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    }
                    
                    // Nút thao tác
                    HStack(spacing: 12) {
                        if equipment.status == .available {
                            Button {
                                showingBorrowSheet = true
                            } label: {
                                Label("Borrow", systemImage: "arrow.up.right.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                let result = controller.returnEquipment(equipment: equipment)
                                alertMessage = result.message
                                showAlert = true
                            } label: {
                                Label("Return", systemImage: "arrow.down.left.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationTitle(equipment.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Equipment Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingBorrowSheet) {
            NavigationStack {
                Form {
                    Section("Borrower Information") {
                        TextField("Student / Lecturer Name", text: $borrowerName)
                        DatePicker("Expected Return Date", selection: $expectedReturn, in: Date()..., displayedComponents: .date)
                    }
                    Button("Confirm Borrow") {
                        let res = controller.borrowEquipment(equipment: equipment, borrowerName: borrowerName, expectedReturn: expectedReturn)
                        alertMessage = res.message
                        showingBorrowSheet = false
                        showAlert = true
                    }
                    .disabled(borrowerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .navigationTitle("Borrow Equipment")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingEditSheet) {
            EquipmentManagementView(controller: controller, mode: .edit(equipment))
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
        .font(.subheadline)
    }
}
