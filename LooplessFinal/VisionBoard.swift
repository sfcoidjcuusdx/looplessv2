//
//  VisionBoard.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


//
//  FutureSelfVisionActivity.swift
//  loopless
//
//  Created by Ning Ding on 7/10/25.
//

import SwiftUICore
import SwiftUI

struct VisionBoard: Codable, Identifiable {
    var id = UUID()
    var values: [String]
    var description: String
    var currentHabits: [String]
    var idealHabits: [String]
    var creationDate = Date()
    var title: String = "My Vision Board"
}

struct FutureSelfVisionActivity: View {
    @State private var selectedValues: [String] = []
    @State private var futureSelfDescription = ""
    @State private var currentTechHabits: [String] = []
    @State private var idealTechHabits: [String] = []
    @State private var showVisionBoard = false
    @State private var existingBoard: VisionBoard? = nil
    @State private var isEditing = false
    @State private var shareImage: UIImage? = nil
    @State private var showShareSheet = false

    
    let coreValues = [
        "Integrity", "Presence", "Growth", "Connection",
        "Creativity", "Health", "Learning", "Balance"
    ]
    
    // Load saved board when view appears
    private func loadSavedBoard() {
        if let data = UserDefaults.standard.data(forKey: "savedVisionBoard"),
           let board = try? JSONDecoder().decode(VisionBoard.self, from: data) {
            existingBoard = board
        }
    }
    
    
    
    // Save board to UserDefaults
    private func saveBoard() {
        if let board = existingBoard,
           let data = try? JSONEncoder().encode(board) {
            UserDefaults.standard.set(data, forKey: "savedVisionBoard")
        }
    }
    
    // Create or update the board
    private func saveCurrentBoard() {
        let board = VisionBoard(
            id: existingBoard?.id ?? UUID(),
            values: selectedValues,
            description: futureSelfDescription,
            currentHabits: currentTechHabits,
            idealHabits: idealTechHabits
        )
        
        existingBoard = board
        saveBoard()
        isEditing = false
    }
    
    // Load board for editing
    private func loadBoardForEditing() {
        guard let board = existingBoard else { return }
        selectedValues = board.values
        futureSelfDescription = board.description
        currentTechHabits = board.currentHabits
        idealTechHabits = board.idealHabits
        isEditing = true
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                Text("Future Self Vision Board")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .padding(.bottom, 5)
                
                Text("Design the relationship with technology that aligns with your highest self")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Show existing board or creation form
                if let board = existingBoard, !isEditing {
                    VStack(alignment: .leading) {
                        // Board Preview
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Your Vision Board")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                                Spacer()
                                
                                Button(action: {
                                    showVisionBoard = true
                                }) {
                                    Text("View Full")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            Text(board.description.prefix(150) + (board.description.count > 150 ? "..." : ""))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.vertical, 8)
                            
                            HStack {
                                ForEach(board.values.prefix(3), id: \.self) { value in
                                    Text(value)
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(5)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Edit Button
                        Button(action: {
                            loadBoardForEditing()
                        }) {
                            Text("Edit Vision Board")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.3))
                                .cornerRadius(15)
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                } else {
                    // Creation/Editing Form
                    VStack(spacing: 25) {
                        // Section 1: Core Values Selection
                        VStack(alignment: .leading) {
                            SectionHeader(title: "1. Choose Your Core Values", icon: "leaf")
                            
                            Text("Select 3-5 values that define who you want to become")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.bottom, 10)
                            
                            FlexibleGrid(
                                items: coreValues,
                                selectedItems: $selectedValues,
                                maxSelections: 5,
                                minSelections: 3
                            )
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Section 2: Future Self Description
                        VStack(alignment: .leading) {
                            SectionHeader(title: "2. Describe Your Future Self", icon: "person.fill")
                            
                            DisclosureGroup("Need inspiration? Tap for guiding questions") {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("• What does your ideal morning routine look like?")
                                    Text("• How do you spend your focused work time?")
                                    Text("• What kind of breaks do you take?")
                                    Text("• How do you unwind in the evenings?")
                                    Text("• What's your relationship with your devices?")
                                    Text("• How do you maintain meaningful connections?")
                                    Text("• What personal growth activities do you do?")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 10)
                            }
                            .accentColor(.yellow)
                            .padding(.bottom, 10)
                            
                            // Text Editor with Placeholder
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $futureSelfDescription)
                                    .frame(height: 180)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                                
                                if futureSelfDescription.isEmpty {
                                    Text("Describe your future self in detail...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 24)
                                        .padding(.leading, 21)
                                }
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 10) {
                                                        ForEach([
                                                            "My morning routine...",
                                                            "I handle notifications by...",
                                                            "My ideal work focus...",
                                                            "My device usage...",
                                                            "My connection habits..."
                                                        ], id: \.self) { prompt in
                                                            Button(action: {
                                                                if !futureSelfDescription.isEmpty {
                                                                    futureSelfDescription += "\n\n" + prompt
                                                                } else {
                                                                    futureSelfDescription = prompt
                                                                }
                                                            }) {
                                                                Text(prompt)
                                                                    .font(.caption)
                                                                    .padding(8)
                                                                    .background(Color.yellow.opacity(0.2))
                                                                    .cornerRadius(8)
                                                                    .foregroundColor(.yellow)
                                                            }
                                                        }
                                                    }
                                                    .padding(.vertical, 5)
                                                }
                                              
                                            
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Section 3: Tech Habit Transformation
                        VStack(alignment: .leading) {
                            SectionHeader(title: "3. Tech Habit Transformation", icon: "arrow.triangle.2.circlepath")
                            
                            HStack {
                                VStack {
                                    Text("Current Habits")
                                        .font(.headline)
                                    DynamicTextFieldList(items: $currentTechHabits, placeholder: "Add current habit")
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.yellow)
                                
                                VStack {
                                    Text("Ideal Habits")
                                        .font(.headline)
                                    DynamicTextFieldList(items: $idealTechHabits, placeholder: "Add better alternative")
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Save Button
                        if selectedValues.count >= 3 && !futureSelfDescription.isEmpty {
                            Button(action: {
                                saveCurrentBoard()
                            }) {
                                Text(isEditing ? "Update Vision Board" : "Create Vision Board")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .cornerRadius(15)
                                    .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 4)
                            }
                            .padding(.top)
                        }
                    }
                }
            }
            .padding()
        }
        .background(LinearGradient(
            colors: [.black, .orange.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea())
        .sheet(isPresented: $showVisionBoard) {
            if let board = existingBoard {
                VisionBoardView(
                    values: board.values,
                    description: board.description,
                    currentHabits: board.currentHabits,
                    idealHabits: board.idealHabits
                )
            }
        }
        .onAppear {
            loadSavedBoard()
            if existingBoard == nil {
                isEditing = true
            }
        }
    }
}


// MARK: - Components

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            Text(title)
                .font(.title3.weight(.semibold))
        }
        .padding(.bottom, 5)
    }
}

struct FlexibleGrid: View {
    let items: [String]
    @Binding var selectedItems: [String]
    let maxSelections: Int
    let minSelections: Int
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { value in
                ValuePill(
                    value: value,
                    isSelected: selectedItems.contains(value),
                    onTap: {
                        if selectedItems.contains(value) {
                            selectedItems.removeAll { $0 == value }
                        } else if selectedItems.count < maxSelections {
                            selectedItems.append(value)
                        }
                    }
                )
            }
        }
    }
}

struct ValuePill: View {
    let value: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(value)
            .font(.subheadline.weight(.medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(isSelected ? Color.yellow : Color.white.opacity(0.1))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.orange : Color.gray, lineWidth: 1)
            )
            .onTapGesture(perform: onTap)
    }
}

struct DynamicTextFieldList: View {
    @Binding var items: [String]
    let placeholder: String
    @State private var newItem = ""
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Text("• \(items[index])")
                    Spacer()
                    Button {
                        items.remove(at: index)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
            
            HStack {
                TextField(placeholder, text: $newItem)
                Button {
                    if !newItem.isEmpty {
                        items.append(newItem)
                        newItem = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding(8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Vision Board View

struct VisionBoardView: View {
    let values: [String]
    let description: String
    let currentHabits: [String]
    let idealHabits: [String]
   
    @State private var isExporting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Vision Board Canvas
                ZStack {
                    // Background Texture
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.82, blue: 0.38),
                                                Color(red: 0.90, green: 0.60, blue: 0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "sparkles")
                                .foregroundColor(.white.opacity(0.05))
                                .font(.system(size: 300))
                                .rotationEffect(.degrees(-15))
                        )
                    
                    // Content arranged in creative layout
                    VStack(spacing: 20) {
                        // Header with decorative elements
                        // Header with decorative elements
                        ZStack {
                            Text("My Future Self Vision")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 30)

                        
                        // Values displayed as constellation
                        VStack {
                          
                            
                            ZStack {
                                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                                    let angle = Double(index) * (360.0 / Double(values.count))
                                    let radius = 120.0 // Increased from 100 to 120
                                    
                                    Text(value)
                                        .font(.system(size: 14, weight: .bold, design: .rounded)) // Smaller font
                                        .minimumScaleFactor(0.7) // Allows text to shrink if needed
                                        .lineLimit(1) // Keep text on one line
                                        .padding(15) // Increased padding
                                        .frame(width: 90) // Fixed width for consistency
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.9))
                                                .shadow(color: .black.opacity(0.2), radius: 9, x: 2, y: 2)
                                                .frame(width: 90, height: 90) // Explicit circle size
                                        )
                                        .foregroundColor(Color.orange)
                                        .offset(
                                            x: radius * cos(angle * .pi / 180),
                                            y: radius * sin(angle * .pi / 180)
                                        )
                                }
                                
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                                    .frame(width: 240, height: 240) // Increased from 200 to 240
                                
                                Image(systemName: "heart")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .frame(height: 260)
                            .padding(.bottom, 40)

                        }
                        .padding(.horizontal, 20)
                        
                        // Future Self Description in decorative card
                        // Future Self Description in decorative card
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.85))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)

                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "quote.opening")
                                        .foregroundColor(.orange.opacity(0.7))
                                    Text("Future Self Portrait")
                                        .font(.system(.headline, design: .rounded))
                                        .bold()
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Image(systemName: "quote.closing")
                                        .foregroundColor(.orange.opacity(0.7))
                                }

                                Text(description)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.top, 5)
                            }
                            .padding(20)
                        }
                        .padding(.top, 30) // ✅ Add this line
                        .padding(.horizontal, 25)

                        
                        // Habit Transformation as journey path
                        VStack {
                            Text("Digital Habit Transformation")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            VStack(spacing: 15) {
                                ForEach(Array(zip(currentHabits, idealHabits)), id: \.0) { current, ideal in
                                    HStack(spacing: 10) {
                                        Text(current)
                                            .font(.system(.subheadline, design: .rounded))
                                            .strikethrough()
                                            .padding(10)
                                            .background(Color.black.opacity(0.2))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.white)
                                        
                                        Text(ideal)
                                            .font(.system(.subheadline, design: .rounded))
                                            .bold()
                                            .padding(10)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(10)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        
                        // Decorative footer
                        HStack {
                            ForEach(0..<3, id: \.self) { _ in
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.bottom, 25)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // Export Options
                VStack(spacing: 15) {
                    Text("Save Your Vision")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        Button(action: { exportAsImage() }) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.title)
                                Text("Image")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                        }
                        
                        Button(action: { shareContent() }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                Text("Share")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.1, blue: 0.05), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private func exportAsImage() {
        isExporting = true
        // Implementation would capture the view as image
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isExporting = false
        }
    }
    
    private func shareContent() {
        // Implementation would share the vision board
    }
}

// MARK: - Flow Layout (for dynamic grids)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width + spacing > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = 0
                lineHeight = 0
            }
            
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = bounds.origin
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > bounds.maxX {
                point.x = bounds.origin.x
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: point, proposal: .unspecified)
            point.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
