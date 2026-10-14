import SwiftUI

public struct ServiceHistoryView: View {
    @ObservedObject public var viewModel: ProfileViewModel
    @State private var showAddSheet = false
    @Environment(\.dismiss) private var dismiss
    
    // Add record state
    @State private var serviceDate = ""
    @State private var odometerKm = ""
    @State private var serviceType = "Regular Service"
    @State private var workshopName = ""
    @State private var cost = ""
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var addError: String? = nil
    
    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Service History")
                        .font(RaahiTypography.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.raahiOrange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // List of Records
                if viewModel.serviceRecords.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "wrench.and.screwdriver",
                        title: "No Service Records",
                        message: "Keep an immutable log of your workshop visits, oil changes, and parts replaced.",
                        actionTitle: "Add First Record"
                    ) {
                        showAddSheet = true
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.serviceRecords) { record in
                                GlassCard(cornerRadius: 14, padding: 14) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(record.serviceType)
                                                .font(RaahiTypography.bodyBold)
                                                .foregroundColor(.white)
                                            Spacer()
                                            if let cost = record.cost {
                                                Text("₹\(Int(cost))")
                                                    .font(RaahiTypography.headline)
                                                    .foregroundColor(Color.raahiGreen)
                                            }
                                        }
                                        
                                        HStack(spacing: 12) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "calendar")
                                                Text(record.serviceDate)
                                            }
                                            HStack(spacing: 4) {
                                                Image(systemName: "speedometer")
                                                Text("\(record.odometerKm) km")
                                            }
                                        }
                                        .font(RaahiTypography.caption)
                                        .foregroundColor(Color.raahiTextSecondary)
                                        
                                        if let workshop = record.workshopName, !workshop.isEmpty {
                                            Text("Workshop: \(workshop)")
                                                .font(RaahiTypography.caption)
                                                .foregroundColor(Color.raahiTextMuted)
                                        }
                                        
                                        if let notes = record.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(RaahiTypography.caption)
                                                .foregroundColor(Color.raahiTextSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddServiceRecordSheet(
                serviceDate: $serviceDate,
                odometerKm: $odometerKm,
                serviceType: $serviceType,
                workshopName: $workshopName,
                cost: $cost,
                notes: $notes,
                isSubmitting: $isSubmitting,
                addError: $addError
            ) {
                Task {
                    await submitNewRecord()
                }
            }
        }
    }
    
    private func submitNewRecord() async {
        guard !serviceDate.isEmpty, let odo = Int(odometerKm) else {
            addError = "Service date (YYYY-MM-DD) and numeric odometer reading are required."
            return
        }
        
        isSubmitting = true
        addError = nil
        
        let req = CreateServiceRecordRequest(
            serviceDate: serviceDate,
            odometerKm: odo,
            serviceType: serviceType,
            notes: notes.isEmpty ? nil : notes,
            cost: Double(cost),
            workshopName: workshopName.isEmpty ? nil : workshopName,
            partsReplaced: nil
        )
        
        do {
            _ = try await APIClient.shared.request(.addServiceRecord(req: req)) as ServiceRecordDto
            isSubmitting = false
            showAddSheet = false
            await viewModel.loadProfileData()
        } catch {
            isSubmitting = false
            addError = error.localizedDescription
        }
    }
}

private struct AddServiceRecordSheet: View {
    @Binding var serviceDate: String
    @Binding var odometerKm: String
    @Binding var serviceType: String
    @Binding var workshopName: String
    @Binding var cost: String
    @Binding var notes: String
    @Binding var isSubmitting: Bool
    @Binding var addError: String?
    let onSave: () -> Void
    
    private let types = ["General Service", "Oil Change", "Brake Pad Replacement", "Tyre Change", "Battery Change", "Other"]
    
    var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Add Service Record")
                        .font(RaahiTypography.title)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(spacing: 14) {
                        RaahiTextField(placeholder: "Service Date (YYYY-MM-DD)", icon: "calendar", text: $serviceDate)
                        RaahiTextField(placeholder: "Odometer Reading (km)", icon: "speedometer", text: $odometerKm, keyboardType: .numberPad)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Service Category")
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(Color.raahiTextSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(types, id: \.self) { t in
                                        Button(action: { serviceType = t }) {
                                            Text(t)
                                                .font(RaahiTypography.captionBold)
                                                .foregroundColor(serviceType == t ? .white : Color.raahiTextSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(serviceType == t ? Color.raahiOrange : Color.raahiCard)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        RaahiTextField(placeholder: "Workshop Name (Optional)", icon: "building.2.fill", text: $workshopName)
                        RaahiTextField(placeholder: "Total Cost in ₹ (Optional)", icon: "indianrupeesign", text: $cost, keyboardType: .numberPad)
                        RaahiTextField(placeholder: "Notes & parts replaced (Optional)", icon: "note.text", text: $notes)
                    }
                    .padding(.horizontal, 20)
                    
                    if let error = addError {
                        ErrorBannerView(message: error)
                            .padding(.horizontal, 20)
                    }
                    
                    RaahiButton(
                        title: "Save Service Record",
                        icon: "checkmark",
                        style: .primary,
                        isLoading: isSubmitting
                    ) {
                        onSave()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}
