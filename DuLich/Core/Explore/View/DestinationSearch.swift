//
//  DestinationSearch.swift
//  DuLich
//

import SwiftUI
import Combine

enum DestinationSearchState {
    case location
    case dateGo
    case quantity
}

struct DestinationSearch: View {
    @Binding var show: Bool
    var onSearch: (String) -> Void
    var listings: [Listing] = []

    @State private var destination: String = ""
    @State private var selectedOption: DestinationSearchState = .location
    @State private var startDate  = Date()
    @State private var endDate    = Date()
    @State private var numPeople  = 0

    private var suggestions: [Listing] {
        guard !destination.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = destination.lowercased()
        return listings.filter {
            $0.title.lowercased().contains(query) ||
            $0.city.lowercased().contains(query) ||
            $0.address.lowercased().contains(query) ||
            $0.district.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
                
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.80, blue: 0.98),
                        Color(red: 0.75, green: 0.90, blue: 1.00)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Button {
                            withAnimation(.snappy) { show.toggle() }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle().strokeBorder(Color.white.opacity(0.60), lineWidth: 0.8)
                                    )
                                    .frame(width: 36, height: 36)
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(white: 0.25))
                            }
                        }
                        
                        Spacer()
                        
                        Text("Tìm kiếm")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.15))
                        
                        Spacer()
                        
                        if !destination.isEmpty {
                            Button("Xoá") {
                                destination = ""
                                onSearch("")
                            }
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.90))
                            .frame(width: 36)
                        } else {
                            Spacer().frame(width: 36)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            
                            GlassSearchCard(
                                isExpanded: selectedOption == .location,
                                accentColor: Color(red: 0.15, green: 0.50, blue: 0.95),
                                icon: "mappin.and.ellipse"
                            ) {
                                withAnimation(.snappy) { selectedOption = .location }
                            } collapsedContent: {
                                ExtractedView(title: "loca_tion", description: destination.isEmpty ? "add_location" : LocalizedStringKey(destination))
                            } expandedContent: {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Địa điểm cần tìm")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(white: 0.10))

                                    HStack(spacing: 10) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(white: 0.45))

                                        TextField("Tìm kiếm điểm đến…", text: $destination)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(Color(white: 0.12))
                                            .onSubmit {
                                                onSearch(destination)
                                                show = false
                                            }

                                        if !destination.isEmpty {
                                            Button {
                                                destination = ""
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(Color(white: 0.55))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: 42)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.55))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(Color.white.opacity(0.80), lineWidth: 0.8)
                                            )
                                    )

                                    // ✅ Bọc trong Group để fix lỗi type inference
                                    Group {
                                        if !suggestions.isEmpty {
                                            VStack(spacing: 0) {
                                                ForEach(Array(suggestions.prefix(5).enumerated()), id: \.element.id) { idx, listing in
                                                    Button {
                                                        destination = listing.city
                                                        onSearch(listing.city)
                                                        show = false
                                                    } label: {
                                                        HStack(spacing: 10) {
                                                            Image(systemName: "mappin.circle.fill")
                                                                .font(.system(size: 16))
                                                                .foregroundColor(Color(red: 0.15, green: 0.50, blue: 0.95))
                                                                .frame(width: 24)

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(listing.title)
                                                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                                    .foregroundColor(Color(white: 0.12))
                                                                    .lineLimit(1)
                                                                Text("\(listing.district.isEmpty ? "" : listing.district + ", ")\(listing.city)")
                                                                    .font(.system(size: 11, design: .rounded))
                                                                    .foregroundColor(Color(white: 0.45))
                                                                    .lineLimit(1)
                                                            }
                                                            Spacer()
                                                            Image(systemName: "arrow.up.left")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(Color(white: 0.55))
                                                        }
                                                        .padding(.horizontal, 14)
                                                        .padding(.vertical, 11)
                                                        .background(Color.white.opacity(idx % 2 == 0 ? 0.30 : 0.15))
                                                    }
                                                    .buttonStyle(.plain)

                                                    if idx < min(suggestions.count, 5) - 1 {
                                                        Divider()
                                                            .background(Color.white.opacity(0.40))
                                                            .padding(.horizontal, 14)
                                                    }
                                                }
                                            }
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white.opacity(0.20))
                                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(Color.white.opacity(0.60), lineWidth: 0.8))
                                            )
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            .animation(.snappy, value: suggestions.count)
                                        }
                                    }
                                }
                            }
                            GlassSearchCard(
                                isExpanded: selectedOption == .dateGo,
                                accentColor: Color(red: 0.05, green: 0.65, blue: 0.75),
                                icon: "calendar"
                            ) {
                                withAnimation(.snappy) { selectedOption = .dateGo }
                            } collapsedContent: {
                                ExtractedView(title: "departure_day", description: "add_day")
                            } expandedContent: {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("select_day")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(white: 0.10))
                                    
                                    DatePickerRow(label: "departure_day", selection: $startDate)
                                    Divider().background(Color.white.opacity(0.50))
                                    DatePickerRow(label: "return_day", selection: $endDate)
                                }
                            }
                            
                            GlassSearchCard(
                                isExpanded: selectedOption == .quantity,
                                accentColor: Color(red: 0.85, green: 0.55, blue: 0.10),
                                icon: "person.2"
                            ) {
                                withAnimation(.snappy) { selectedOption = .quantity }
                            } collapsedContent: {
                                ExtractedView(
                                    title: "people_quantity",
                                    description: numPeople == 0 ? "add_number" : "\(numPeople) people"
                                )
                            } expandedContent: {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("number_of_people")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(white: 0.10))
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(numPeople) adults")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(white: 0.15))
                                            Text("Miễn phí cho trẻ em dưới 5 tuổi")
                                                .font(.system(size: 11, design: .rounded))
                                                .foregroundColor(Color(white: 0.45))
                                        }
                                        Spacer()
                                        
                                        
                                        HStack(spacing: 0) {
                                            Button {
                                                if numPeople > 0 { numPeople -= 1 }
                                            } label: {
                                                Image(systemName: "minus")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(numPeople == 0 ? Color(white: 0.70) : Color(white: 0.20))
                                                    .frame(width: 36, height: 36)
                                                    .background(
                                                        Circle().fill(Color.white.opacity(0.60))
                                                            .overlay(Circle().strokeBorder(Color.white.opacity(0.80), lineWidth: 0.8))
                                                    )
                                            }
                                            .disabled(numPeople == 0)
                                            
                                            Text("\(numPeople)")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(white: 0.12))
                                                .frame(width: 36)
                                            
                                            Button {
                                                numPeople += 1
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(Color(white: 0.20))
                                                    .frame(width: 36, height: 36)
                                                    .background(
                                                        Circle().fill(Color.white.opacity(0.60))
                                                            .overlay(Circle().strokeBorder(Color.white.opacity(0.80), lineWidth: 0.8))
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 24)
                            
                            Button {
                                onSearch(destination)
                                show = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Tìm kiếm")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.15, green: 0.50, blue: 0.95),
                                                    Color(red: 0.08, green: 0.35, blue: 0.80)
                                                ],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.8)
                                        )
                                        .shadow(color: Color(red: 0.15, green: 0.50, blue: 0.95).opacity(0.35), radius: 8, x: 0, y: 4)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    struct GlassSearchCard<Collapsed: View, Expanded: View>: View {
        let isExpanded: Bool
        let accentColor: Color
        let icon: String
        let onTap: () -> Void
        @ViewBuilder let collapsedContent: () -> Collapsed
        @ViewBuilder let expandedContent: () -> Expanded
        
        var body: some View {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        // Accent icon badge
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(accentColor.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(accentColor.opacity(0.30), lineWidth: 0.8)
                                )
                                .frame(width: 36, height: 36)
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(accentColor)
                        }
                        
                        if isExpanded {
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(white: 0.55))
                        } else {
                            collapsedContent()
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(white: 0.55))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    
                    if isExpanded {
                        Divider()
                            .background(Color.white.opacity(0.50))
                            .padding(.horizontal, 16)
                        
                        expandedContent()
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 18)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(isExpanded ? 0.35 : 0.25))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.80),
                                            isExpanded ? accentColor.opacity(0.35) : Color.white.opacity(0.30)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isExpanded ? 1.2 : 0.8
                                )
                        )
                        .shadow(color: Color.black.opacity(isExpanded ? 0.10 : 0.06), radius: isExpanded ? 14 : 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
            .animation(.snappy, value: isExpanded)
        }
    }
    
    struct DatePickerRow: View {
        let label: LocalizedStringKey
        @Binding var selection: Date
        
        var body: some View {
            DatePicker(label, selection: $selection, displayedComponents: .date)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(white: 0.25))
                .tint(Color(red: 0.15, green: 0.50, blue: 0.95))
        }
    }
    
    struct ExtractedView: View {
        let title: LocalizedStringKey
        let description: LocalizedStringKey
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.50))
                    .textCase(.uppercase)
                    .tracking(0.5)
                Text(description)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(white: 0.18))
                    .lineLimit(1)
            }
        }
    }
    
    #Preview {
        DestinationSearch(show: .constant(true), onSearch: { _ in })
    }

