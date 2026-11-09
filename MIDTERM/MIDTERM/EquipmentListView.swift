import SwiftUI

// MARK: - MÀN HÌNH CHÍNH CÓ 3 TAB: EQUIPMENT, BORROWINGS, SETTINGS
struct EquipmentListView: View {
    @StateObject private var controller = LibraryEquipmentController()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: EQUIPMENT
            EquipmentHomeView(controller: controller)
                .tabItem {
                    Label("Equipment", systemImage: "laptopcomputer.and.ipad")
                }
                .tag(0)
            
            // TAB 2: BORROWINGS
            BorrowingsHistoryView(controller: controller)
                .tabItem {
                    Label("Borrowings", systemImage: "list.clipboard.fill")
                }
                .tag(1)
            
            // TAB 3: SETTINGS
            LibrarySettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
    }
}

// MARK: - TAB 1: DANH SÁCH THIẾT BỊ (ĐÃ SỬA LỖI ĐÈ CHỮ & BACKGROUND D2)
struct EquipmentHomeView: View {
    @ObservedObject var controller: LibraryEquipmentController
    @State private var showingAddSheet = false
    @State private var filterType: EquipmentType? = nil
    
    var filteredItems: [Equipment] {
        if let filter = filterType {
            return controller.inventory.filter { $0.equipmentType == filter }
        }
        return controller.inventory
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background D2
                Image("D2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.35)
                
                VStack(spacing: 0) {
                    // Header tùy chỉnh chống đè chữ
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Library Equipment")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.pink)
                            Text("Manage & track borrowing status")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.primary)
                                .background(Circle().fill(Color.white.opacity(0.9)))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    
                    // Segmented Filter Bar với nền mờ chống lóa
                    Picker("Filter", selection: $filterType) {
                        Text("All").tag(EquipmentType?.none)
                        ForEach(EquipmentType.allCases) { type in
                            Text(type.rawValue).tag(EquipmentType?.some(type))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // Danh sách thiết bị dạng Card bo góc
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: EquipmentDetailView(equipment: item, controller: controller)) {
                                HStack(alignment: .center, spacing: 14) {
                                    Image(systemName: iconFor(item.equipmentType))
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.12))
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("[\(item.id)] • \(item.equipmentType.rawValue)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.status.rawValue)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(item.status == .available ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                        .foregroundColor(item.status == .available ? .green : .orange)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.88))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarHidden(true) // Ẩn navigation bar mặc định để tiêu đề không bị trùng
            .sheet(isPresented: $showingAddSheet) {
                EquipmentManagementView(controller: controller, mode: .register)
            }
        }
    }
    
    private func iconFor(_ type: EquipmentType) -> String {
        switch type {
        case .laptop: return "laptopcomputer"
        case .tablet: return "ipad"
        case .camera: return "camera.fill"
        }
    }
}

// MARK: - TAB 2: LỊCH SỬ MƯỢN TRẢ (BORROWINGS)
struct BorrowingsHistoryView: View {
    @ObservedObject var controller: LibraryEquipmentController
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background D2
                Image("D2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.35)
                
                VStack(spacing: 0) {
                    // Header tùy chỉnh chống chèn chữ
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Borrowings")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.pink)
                            Text("Active and past loan records")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    
                    if controller.transactions.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No borrowing records found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        List(controller.transactions) { tx in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("ID: \(tx.equipmentID)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(tx.isActive ? "Active Loan" : "Returned")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(tx.isActive ? Color.orange.opacity(0.18) : Color.blue.opacity(0.18))
                                        .foregroundColor(tx.isActive ? .orange : .blue)
                                        .cornerRadius(6)
                                }
                                Text("Borrower: \(tx.borrowerName)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("Date: \(tx.borrowDate.formatted(date: .abbreviated, time: .omitted)) → Due: \(tx.expectedReturnDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.white.opacity(0.88))
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true) // Ẩn nav bar mặc định để không bị đè tiêu đề
        }
    }
}

// MARK: - TAB 3: CÀI ĐẶT (SETTINGS)
struct LibrarySettingsView: View {
    @State private var notificationsEnabled = true
    @State private var libraryBranch = "Central Academic Library"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background D2 cho Settings
                Image("D2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.35)
                
                VStack(spacing: 0) {
                    // Header tùy chỉnh
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Settings")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.pink)
                            Text("System preferences & information")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    Form {
                        Section("System Information") {
                            HStack {
                                Text("Application")
                                Spacer()
                                Text("University Library Manager")
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Branch")
                                Spacer()
                                Text(libraryBranch)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.88))
                        
                        Section("Preferences") {
                            Toggle("Due Date Reminders", isOn: $notificationsEnabled)
                        }
                        .listRowBackground(Color.white.opacity(0.88))
                    }
                    .scrollContentBackground(.hidden) // Ẩn nền trắng xám mặc định của Form để thấy ảnh nền
                }
            }
            .navigationBarHidden(true)
        }
    }
}
