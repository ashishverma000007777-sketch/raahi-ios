import SwiftUI

public struct VehicleSetupView: View {
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var variant: String = ""
    @State private var modelYear: String = "2022"
    @State private var fuelType: String = "PETROL"
    @State private var registrationNumber: String = ""
    @State private var odometerKm: String = "25000"
    
    // Optional maintenance dates
    @State private var showOptionalDetails: Bool = false
    @State private var lastServiceDate: String = ""
    @State private var lastServiceOdometerKm: String = ""
    @State private var insuranceExpiry: String = ""
    @State private var pucExpiry: String = ""
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public let existingVehicle: VehicleDto?
    public var onSaved: ((VehicleDto) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    public init(existingVehicle: VehicleDto? = nil, onSaved: ((VehicleDto) -> Void)? = nil) {
        self.existingVehicle = existingVehicle
        self.onSaved = onSaved
        
        if let v = existingVehicle {
            _brand = State(initialValue: v.brand)
            _model = State(initialValue: v.model)
            _variant = State(initialValue: v.variant ?? "")
            _modelYear = State(initialValue: "\(v.modelYear)")
            _fuelType = State(initialValue: v.fuelType)
            _registrationNumber = State(initialValue: v.registrationNumber)
            _odometerKm = State(initialValue: "\(v.odometerKm)")
            _lastServiceDate = State(initialValue: v.lastServiceDate ?? "")
            _lastServiceOdometerKm = State(initialValue: v.lastServiceOdometerKm != nil ? "\(v.lastServiceOdometerKm!)" : "")
            _insuranceExpiry = State(initialValue: v.insuranceExpiry ?? "")
            _pucExpiry = State(initialValue: v.pucExpiry ?? "")
        }
    }
    
    private let fuelTypes = ["PETROL", "DIESEL", "CNG", "ELECTRIC", "HYBRID"]
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(existingVehicle != nil ? "Edit Vehicle" : "Set Up Your Car")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Vehicle Details")
                            .font(RaahiTypography.title)
                            .foregroundColor(.white)
                        
                        Text("Accurate vehicle details help us compute real Car Health scores and provide exact roadside help.")
                            .font(RaahiTypography.body)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        RaahiTextField(placeholder: "Make / Brand (e.g. Hyundai)", icon: "car.fill", text: $brand)
                        RaahiTextField(placeholder: "Model (e.g. Grand i10)", icon: "car.side.fill", text: $model)
                        RaahiTextField(placeholder: "Variant (e.g. Magna 1.2)", icon: "tag.fill", text: $variant)
                        RaahiTextField(placeholder: "Registration (e.g. DL 03 AX 1234)", icon: "number", text: $registrationNumber)
                        
                        HStack(spacing: 12) {
                            RaahiTextField(placeholder: "Year (e.g. 2022)", icon: "calendar", text: $modelYear, keyboardType: .numberPad)
                            RaahiTextField(placeholder: "Odometer (km)", icon: "speedometer", text: $odometerKm, keyboardType: .numberPad)
                        }
                        
                        // Fuel Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fuel Type")
                                .font(RaahiTypography.subheadline)
                                .foregroundColor(Color.raahiTextSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(fuelTypes, id: \.self) { ft in
                                        Button(action: { fuelType = ft }) {
                                            Text(ft)
                                                .font(RaahiTypography.captionBold)
                                                .foregroundColor(fuelType == ft ? .white : Color.raahiTextSecondary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(fuelType == ft ? Color.raahiOrange : Color.raahiSurface)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(fuelType == ft ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Optional Details Accordion
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: { withAnimation { showOptionalDetails.toggle() } }) {
                            HStack {
                                Text(showOptionalDetails ? "Hide Optional Service Details" : "+ Add Service & Compliance Details")
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(Color.raahiOrange)
                                Spacer()
                                Image(systemName: showOptionalDetails ? "chevron.up" : "chevron.down")
                                    .foregroundColor(Color.raahiOrange)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if showOptionalDetails {
                            VStack(spacing: 14) {
                                RaahiTextField(placeholder: "Last Service Date (YYYY-MM-DD)", icon: "wrench.fill", text: $lastServiceDate)
                                RaahiTextField(placeholder: "Last Service Odometer (km)", icon: "speedometer", text: $lastServiceOdometerKm, keyboardType: .numberPad)
                                RaahiTextField(placeholder: "Insurance Expiry Date (YYYY-MM-DD)", icon: "shield.fill", text: $insuranceExpiry)
                                RaahiTextField(placeholder: "PUC Expiry Date (YYYY-MM-DD)", icon: "doc.text.fill", text: $pucExpiry)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if let error = errorMessage {
                        ErrorBannerView(message: error)
                            .padding(.horizontal, 20)
                    }
                    
                    RaahiButton(
                        title: "Save Vehicle",
                        icon: "checkmark",
                        style: .primary,
                        isLoading: isLoading
                    ) {
                        saveVehicle()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                }
            }
        }
    }
    
    private func saveVehicle() {
        guard !brand.isEmpty, !model.isEmpty, !registrationNumber.isEmpty else {
            errorMessage = "Brand, model, and registration number are required."
            return
        }
        
        guard let year = Int(modelYear), let odo = Int(odometerKm) else {
            errorMessage = "Please enter valid numeric year and odometer reading."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let req = UpsertVehicleRequest(
            brand: brand.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            variant: variant.isEmpty ? nil : variant.trimmingCharacters(in: .whitespaces),
            modelYear: year,
            fuelType: fuelType,
            registrationNumber: registrationNumber.trimmingCharacters(in: .whitespaces).uppercased(),
            odometerKm: odo,
            lastServiceDate: lastServiceDate.isEmpty ? nil : lastServiceDate,
            lastServiceOdometerKm: Int(lastServiceOdometerKm),
            insuranceExpiry: insuranceExpiry.isEmpty ? nil : insuranceExpiry,
            pucExpiry: pucExpiry.isEmpty ? nil : pucExpiry
        )
        
        Task {
            do {
                let saved: VehicleDto = try await APIClient.shared.request(.upsertVehicle(req: req))
                isLoading = false
                onSaved?(saved)
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
