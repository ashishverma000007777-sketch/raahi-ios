import SwiftUI
import MapKit

public struct MechanicDetailView: View {
    public let mechanic: MechanicDto
    public var onRequestHelp: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    public init(mechanic: MechanicDto, onRequestHelp: (() -> Void)? = nil) {
        self.mechanic = mechanic
        self.onRequestHelp = onRequestHelp
    }
    
    public var body: some View {
        ZStack {
            Color.raahiSurface.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Drag handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                
                // Header & Info
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.raahiCardSecondary)
                            .frame(width: 58, height: 58)
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.raahiOrange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(mechanic.shopName ?? mechanic.name ?? "Verified Mechanic")
                                .font(RaahiTypography.headline)
                                .foregroundColor(.white)
                            
                            StatusBadge(
                                text: mechanic.isAvailable ? "Available" : "Busy",
                                color: mechanic.isAvailable ? Color.raahiGreen : Color.raahiYellow
                            )
                        }
                        
                        if let name = mechanic.name, mechanic.shopName != nil {
                            Text(name)
                                .font(RaahiTypography.subheadline)
                                .foregroundColor(Color.raahiTextSecondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.raahiYellow)
                                .font(.system(size: 13))
                            Text(String(format: "%.1f", mechanic.ratingAvg))
                                .font(RaahiTypography.captionBold)
                                .foregroundColor(.white)
                            Text("•")
                                .foregroundColor(Color.raahiTextMuted)
                            Text(String(format: "%.1f km away", mechanic.distanceKm))
                                .font(RaahiTypography.caption)
                                .foregroundColor(Color.raahiTextSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Specializations
                if let specs = mechanic.specializations, !specs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SERVICES & SPECIALIZATIONS")
                            .font(RaahiTypography.captionBold)
                            .foregroundColor(Color.raahiTextSecondary)
                        
                        let items = specs.components(separatedBy: ",")
                        FlowLayout(spacing: 6) {
                            ForEach(items, id: \.self) { item in
                                Text(item.trimmingCharacters(in: .whitespaces))
                                    .font(RaahiTypography.captionBold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.raahiCard)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                }
                
                // Actions (Call & Directions)
                HStack(spacing: 12) {
                    if let phone = mechanic.phone, !phone.isEmpty {
                        Button(action: {
                            if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                Text("Call Mechanic")
                            }
                            .font(RaahiTypography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.raahiGreen)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        openMapsDirections()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            Text("Directions")
                        }
                        .font(RaahiTypography.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.raahiCardSecondary)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.raahiBorder, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .background(Color.raahiBorder)
                    .padding(.horizontal, 20)
                
                // Cross-flow Request Help CTA
                VStack(spacing: 8) {
                    Text("Need immediate assistance on the road?")
                        .font(RaahiTypography.caption)
                        .foregroundColor(Color.raahiTextSecondary)
                    
                    RaahiButton(
                        title: "Post Roadside Help Request",
                        icon: "car.side.fill",
                        style: .primary
                    ) {
                        dismiss()
                        onRequestHelp?()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    private func openMapsDirections() {
        guard let lat = mechanic.lat, let lng = mechanic.lng else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = mechanic.shopName ?? mechanic.name ?? "Mechanic"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// Simple Flow layout for specialization tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        height = currentY + lineHeight
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            view.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
