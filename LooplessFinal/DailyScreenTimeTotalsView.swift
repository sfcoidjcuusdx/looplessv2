//
//  DailyScreenTimeTotalsView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/11/25.
//


import SwiftUI

struct DailyScreenTimeTotalsView: View {
    private let daysToShow = 7
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "E" // e.g., Mon, Tue
        return df
    }()
    
    private var screenTimeData: [(day: String, seconds: TimeInterval, formatted: String)] {
        (0..<daysToShow).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let formattedDay = dateFormatter.string(from: date)
            let data = DailyScreenTimeLogger.loadScreenTime(for: date)
            return (day: formattedDay, seconds: data.seconds, formatted: data.formatted)
        }.reversed() // So most recent is on the right
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Week Screen Time")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)

            HStack(alignment: .bottom, spacing: 14) {
                ForEach(screenTimeData, id: \.day) { data in
                    VStack {
                        Text(data.formatted)
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.7))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .top,
                                endPoint: .bottom)
                            )
                            .frame(width: 20, height: barHeight(for: data.seconds))

                        Text(data.day)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        )
        .padding()
    }

    private func barHeight(for seconds: TimeInterval) -> CGFloat {
        // Max height = 120 pts for 4 hours (adjust as needed)
        let maxHeight: CGFloat = 120
        let maxSeconds: TimeInterval = 4 * 3600
        let ratio = min(seconds / maxSeconds, 1.0)
        return maxHeight * CGFloat(ratio)
    }
}
