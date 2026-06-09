// AddHotelView.swift
import SwiftUI
import PhotosUI

struct AddHotelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFilePicker = false
    @State private var form = HotelForm()
    @State private var selectedItems: [PhotosPickerItem] = []

    @State private var isSaving = false
    @State private var saveError: String? = nil
    @State private var saveSuccess = false

    var onSaved: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.52, green: 0.76, blue: 0.96),
                        Color(red: 0.85, green: 0.93, blue: 1.00),
                        Color(red: 0.93, green: 0.96, blue: 1.00)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        sectionCard(title: "hotel_info", icon: "building.2") {
                            formField("hotelName", icon: "text.justify", text: $form.title)
                            formField("owner_name", icon: "person.fill", text: $form.ownerName)
                            formField("description_hotel", icon: "text.bubble", text: $form.description, multiline: true)
                        }

                        sectionCard(title: "hotel_adress", icon: "map.fill") {
                            formField("enter_adress", icon: "house.fill", text: $form.address)
                            HStack(spacing: 12) {
                                formField("hotel_city", icon: "building.columns", text: $form.city)
                                formField("hotel_city", icon: "mappin", text: $form.district)
                            }
                            HStack(spacing: 12) {
                                formField("hotel_longtitude", icon: "location.north", text: $form.latitude, keyboard: .decimalPad)
                                formField("hotel_latitude", icon: "location", text: $form.longitude, keyboard: .decimalPad)
                            }
                        }

                        sectionCard(title: "room_type_price", icon: "tag.fill") {
                            ForEach($form.priceEntries) { $entry in
                                priceEntryRow(entry: $entry)
                            }
                            Button {
                                withAnimation { form.priceEntries.append(PriceEntry()) }
                            } label: {
                                Label("add_room_type", systemImage: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.08))
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.25), lineWidth: 1))
                                    )
                            }
                        }

                        sectionCard(title: "rate", icon: "star.fill") {
                            HStack(spacing: 12) {
                                formField("Rating (0-5)", icon: "star", text: $form.rating, keyboard: .decimalPad)
                                HStack(spacing: 3) {
                                    ForEach(0..<5) { i in
                                        Image(systemName: Double(form.rating) ?? 0 > Double(i) ? "star.fill" : "star")
                                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.1))
                                            .font(.system(size: 16))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.7)))
                            }
                        }

                        sectionCard(title: "amenties", icon: "checklist") {
                            amenitiesGrid
                        }

                        sectionCard(title: "hotel_pics", icon: "photo.stack.fill") {
                            imagePickerSection
                        }

                        if let err = saveError {
                            Label(err, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                                .padding(.horizontal, 20)
                        }

                        saveButton

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("add_hotel_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("can_cel") { dismiss() }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("add_hotel_success", isPresented: $saveSuccess) {
                Button("OK") {
                    onSaved?()
                    dismiss()
                }
            } message: {
                Text("add_hotel_success_message \(form.title)")
            }
        }
    }

    private var imagePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 10) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 6,
                    matching: .images
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 16))
                        Text("photo_library")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.09))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.3), lineWidth: 1.2))
                    )
                }
                .onChange(of: selectedItems) { newItems in
                    Task {
                        var images: [UIImage] = []
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                images.append(img)
                            }
                        }
                        let combined = form.selectedImages + images
                        form.selectedImages = Array(combined.prefix(6))
                    }
                }

                Button {
                    showFilePicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "folder")
                            .font(.system(size: 16))
                        Text("Files")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.3, green: 0.65, blue: 0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.3, green: 0.65, blue: 0.3).opacity(0.09))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color(red: 0.3, green: 0.65, blue: 0.3).opacity(0.3), lineWidth: 1.2))
                    )
                }
            }

            if !form.selectedImages.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(Array(form.selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Button {
                                withAnimation {
                                    form.selectedImages.remove(at: index)
                                    if index < selectedItems.count {
                                        selectedItems.remove(at: index)
                                    }
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding(4)
                            }
                        }
                    }
                }
            }

            Text("photos_selected \(form.selectedImages.count)")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(Color(white: 0.5))
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                var images: [UIImage] = []
                for url in urls {
                    let accessed = url.startAccessingSecurityScopedResource()
                    do {
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(url.lastPathComponent)
                        if FileManager.default.fileExists(atPath: tempURL.path) {
                            try FileManager.default.removeItem(at: tempURL)
                        }
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        if accessed { url.stopAccessingSecurityScopedResource() }

                        if let data = try? Data(contentsOf: tempURL),
                           let img = UIImage(data: data) {
                            images.append(img.normalizedImage())
                            print("[FilePicker] OK:", url.lastPathComponent, "size:", data.count)
                        }
                    } catch {
                        if accessed { url.stopAccessingSecurityScopedResource() }
                        print("[FilePicker] Copy error:", error.localizedDescription)
                    }
                }
                let combined = form.selectedImages + images
                form.selectedImages = Array(combined.prefix(6))
            case .failure(let error):
                print("[FilePicker] error:", error.localizedDescription)
            }
        }
    }
    private var amenitiesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(ListingAmenities.allCases, id: \.self) { amenity in
                let isSelected = form.amenities.contains(amenity)
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if isSelected { form.amenities.removeAll { $0 == amenity } }
                        else          { form.amenities.append(amenity) }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: amenity.iconName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSelected
                                             ? Color(red: 0.2, green: 0.45, blue: 0.95)
                                             : Color(white: 0.55))
                            .frame(width: 20)

                        Text(amenity.displayTitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(isSelected ? Color(red: 0.1, green: 0.1, blue: 0.25) : Color(white: 0.4))
                            .lineLimit(1)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected
                                  ? Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.10)
                                  : Color.white.opacity(0.5))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    isSelected
                                        ? Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.35)
                                        : Color.white.opacity(0.3),
                                    lineWidth: 1
                                ))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func priceEntryRow(entry: Binding<PriceEntry>) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("room_type_field", text: entry.roomType)
                    .font(.system(size: 14, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.75)))

                TextField("price_vnd_field", text: entry.price)
                    .font(.system(size: 14, design: .rounded))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.75)))
                    .frame(maxWidth: 120)

                if form.priceEntries.count > 1 {
                    Button {
                        withAnimation {
                            form.priceEntries.removeAll { $0.id == entry.wrappedValue.id }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.9, green: 0.25, blue: 0.25).opacity(0.8))
                    }
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "number.square")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.95))
                TextField("number_of_rooms", text: entry.quantity)
                    .font(.system(size: 14, design: .rounded))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.75)))
            }
        }
    }
    private var saveButton: some View {
        Button {
            Task {
                guard validate() else { return }
                isSaving = true
                saveError = nil
                do {
                    try await AdminHotelManager.shared.addHotel(
                        form: form,
                        images: form.selectedImages
                    )
                    isSaving = false
                    saveSuccess = true
                } catch {
                    isSaving = false
                    saveError = String(localized: "save_error_prefix \(error.localizedDescription)")
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.15, green: 0.40, blue: 0.90),
                                 Color(red: 0.30, green: 0.58, blue: 1.0)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 56)
                    .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.9).opacity(0.4), radius: 14, x: 0, y: 7)

                if isSaving {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("add_hotel_btn")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .disabled(isSaving)
    }

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: LocalizedStringKey,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(white: 0.15))
            }

            content()
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.30))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.8)
            }
        )
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private func formField(
        _ placeholder: LocalizedStringKey,
        icon: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        multiline: Bool = false
    ) -> some View {
        HStack(alignment: multiline ? .top : .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.95))
                .frame(width: 20)
                .padding(.top, multiline ? 14 : 0)

            if multiline {
                TextEditor(text: text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color(white: 0.15))
                    .frame(minHeight: 72)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color(white: 0.15))
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, multiline ? 10 : 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(white: 0.88), lineWidth: 0.8))
        )
    }

    private func validate() -> Bool {
        if form.title.isEmpty {
            saveError = String(localized: "validation_hotel_name")
            return false
        }
        if form.city.isEmpty {
            saveError = String(localized: "validation_city")
            return false
        }
        if form.priceEntries.filter({ !$0.roomType.isEmpty }).isEmpty {
            saveError = String(localized: "validation_room_type")
            return false
        }
        if form.selectedImages.isEmpty {
            saveError = String(localized: "validation_photos")
            return false
        }
        return true
    }
}

extension ListingFeatures: CaseIterable {
    static var allCases: [ListingFeatures] {
        return [.selfCheckIn, .superHost]
    }

    var iconName: String {
        switch self {
        case .selfCheckIn:
            return "door.right.hand.open"
        case .superHost:
            return "star.fill"
    
        }
    }

    var displayTitle: String {
        switch self {
        case .selfCheckIn:
            return String(localized: "feature_auto_checkin")
        case .superHost:
            return String(localized: "feature_intl_standard")
        }
    }
}

 
extension ListingAmenities: CaseIterable {
    static var allCases: [ListingAmenities] {
        return [.wifi, .airConditioning, .pool, .breakfast, .parking, .tivi]
    }

    var iconName: String {
        switch self {
        case .wifi:
            return "wifi"
        case .airConditioning:
            return "air.conditioner.horizontal"
        case .pool:
            return "figure.pool.swim"
        case .breakfast:
            return "fork.knife"
        case .parking:
            return "car.fill"
        case .tivi:
            return "rectangle.portrait"
        }
    }

    var displayTitle: LocalizedStringKey {
        switch self {
        case .wifi:
            return "wi_fi"
        case .airConditioning:
            return "air_conditioner"
        case .pool:
            return "swimming_pool"
        case .breakfast:
            return "break_fast"
        case .parking:
            return "park_ing"
        case .tivi:
            return "t_v"
        }
    }
}

#Preview {
    AddHotelView()
}
