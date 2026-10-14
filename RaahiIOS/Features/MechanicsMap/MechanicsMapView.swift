import SwiftUI
import MapKit

public struct MechanicsMapView: View {
    @StateObject private var viewModel = MechanicsMapViewModel()
    
    public var onRequestHelp: (() -> Void)?
    
    public init(onRequestHelp: (() -> Void)? = nil) {
        self.onRequestHelp = onRequestHelp
    }
    
    public var body: some View {
        ZStack {
            Color.raahiBackground.ignoresSafeArea()
            
            // Map
            Map(coordinateRegion: $viewModel.region, annotationItems: mapAnnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    if item.isUser {
                        ZStack {
                            Circle()
                                .fill(Color.raahiBlue.opacity(0.25))
                                .frame(width: 32, height: 32)
                            Circle()
                                .fill(Color.raahiBlue)
                                .frame(width: 14, height: 14)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 14, height: 14)
                        }
                    } else if let mechanic = item.mechanic {
                        Button(action: {
                            viewModel.selectMechanic(mechanic)
                        }) {
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle()
                                        .fill(mechanic.isAvailable ? Color.raahiGreen : Color.raahiYellow)
                                        .frame(width: 36, height: 36)
                                        .shadow(radius: 4)
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 15))
                                }
                                
                                Text(mechanic.shopName ?? mechanic.name ?? "Mechanic")
                                    .font(RaahiTypography.micro)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.raahiCard.opacity(0.9))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Overlays: Filters, Refresh, Recenter
            VStack {
                // Top Filter Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Nearby Verified Mechanics")
                            .font(RaahiTypography.headline)
                            .foregroundColor(.white)
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.raahiOrange))
                        } else {
                            Button(action: {
                                Task { await viewModel.loadNearbyMechanics() }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.raahiOrange)
                                    .padding(8)
                                    .background(Color.raahiCard.opacity(0.85))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.filters, id: \.self) { filter in
                                let isSelected = viewModel.selectedFilter == filter
                                Button(action: {
                                    viewModel.selectFilter(filter)
                                }) {
                                    Text(filter)
                                        .font(RaahiTypography.captionBold)
                                        .foregroundColor(isSelected ? .white : Color.raahiTextSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(isSelected ? Color.raahiOrange : Color.raahiCard.opacity(0.9))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(isSelected ? Color.raahiOrange : Color.raahiBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                .background(
                    LinearGradient(
                        colors: [Color.raahiBackground.opacity(0.95), Color.raahiBackground.opacity(0.7), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Recenter Button
                HStack {
                    Spacer()
                    Button(action: { viewModel.recenter() }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.raahiBlue)
                            .padding(14)
                            .background(Color.raahiCard.opacity(0.95))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.raahiBorder, lineWidth: 1))
                            .shadow(radius: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 12)
                }
                
                // Bottom Preview Card if empty
                if !viewModel.isLoading && viewModel.filteredMechanics.isEmpty {
                    GlassCard(cornerRadius: 16, padding: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color.raahiYellow)
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("No Verified Mechanics Found")
                                    .font(RaahiTypography.bodyBold)
                                    .foregroundColor(.white)
                                Text("Try expanding your search or post a roadside help request.")
                                    .font(RaahiTypography.caption)
                                    .foregroundColor(Color.raahiTextSecondary)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .task {
            await viewModel.loadNearbyMechanics()
        }
        .sheet(item: $viewModel.selectedMechanic) { mechanic in
            MechanicDetailView(mechanic: mechanic, onRequestHelp: onRequestHelp)
        }
    }
    
    private var mapAnnotations: [MapPinItem] {
        var items: [MapPinItem] = [
            MapPinItem(id: "user", coordinate: viewModel.userCoordinate, isUser: true, mechanic: nil)
        ]
        for m in viewModel.filteredMechanics {
            if let lat = m.lat, let lng = m.lng {
                items.append(MapPinItem(id: m.userId, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), isUser: false, mechanic: m))
            }
        }
        return items
    }
    
    struct MapPinItem: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let isUser: Bool
        let mechanic: MechanicDto?
    }
}
