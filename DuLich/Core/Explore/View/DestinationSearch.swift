import SwiftUI

enum DestinationSearchState {
    case location
    case dateGo
    case quantity
}

struct DestinationSearch: View {
    @Binding var show: Bool
    var onSearch: (String) -> Void   // callback
    
    @State private var destination: String = ""
    @State private var selectedOption: DestinationSearchState = .location
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var numPeople = 0

    var body: some View {
        VStack {
            HStack {
                Button { withAnimation(.snappy) { show.toggle() } } label: {
                    Image(systemName: "xmark.circle")
                        .imageScale(.large)
                        .foregroundStyle(.black)
                }
                Spacer()
                if !destination.isEmpty {
                    Button("Clear") {
                        destination = ""
                        onSearch("")   // reset danh sách
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
            }
            .padding()
            
            // Ô địa điểm
            VStack(alignment: .leading) {
                if selectedOption == .location {
                    Text("Địa điểm cần tìm")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.small)
                        TextField("Tìm kiếm", text: $destination)
                            .font(.subheadline)
                            .onSubmit {
                                onSearch(destination)
                                show = false
                            }
                    }
                    .frame(height: 44)
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(Color(.systemGray4))
                    )
                } else {
                    ExtractedView(title: "Chọn địa điểm", description: "Thêm địa điểm")
                }
            }
            .padding()
            .frame(height: selectedOption == .location ? 120 : 64)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .shadow(radius: 10)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .location }
            }
            
            // Date time
            VStack(alignment: .leading) {
                if selectedOption == .dateGo {
                    Text("Chọn ngày")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack {
                        DatePicker("Ngày đi", selection: $startDate, displayedComponents: .date)
                        Spacer()
                        DatePicker("Ngày về", selection: $endDate, displayedComponents: .date)
                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    Spacer()
                } else {
                    ExtractedView(title: "Ngày đi", description: "Thêm ngày")
                }
            }
            .padding()
            .frame(height: selectedOption == .dateGo ? 180 : 64)
            .background(.cyan)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .shadow(radius: 10)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .dateGo }
            }
            
            // Guest quantity
            VStack(alignment: .leading) {
                if selectedOption == .quantity {
                    Text("Số lượng người")
                        .font(.title)
                        .fontWeight(.semibold)
                    VStack {
                        Stepper {
                            Text("\(numPeople) người lớn")
                            Text("Miễn phí cho trẻ em dưới 5 tuổi")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } onIncrement: {
                            numPeople += 1
                        } onDecrement: {
                            guard numPeople > 0 else { return }
                            numPeople -= 1
                        }
                    }
                } else {
                    ExtractedView(title: "Lượng khách", description: "Thêm số lượng")
                }
            }
            .padding()
            .frame(height: selectedOption == .quantity ? 120 : 64)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            .shadow(radius: 10)
            .onTapGesture {
                withAnimation(.snappy) { selectedOption = .quantity }
            }
            
            Spacer()
        }
    }
}

#Preview {
    DestinationSearch(show: .constant(false), onSearch: { _ in })
}

struct ExtractedView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundStyle(.gray)
                Spacer()
                Text(description)
            }
            .fontWeight(.semibold)
            .font(.subheadline)
        }
    }
}
