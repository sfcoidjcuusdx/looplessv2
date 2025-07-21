import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(spacing: 4) {
            Text("Today's Screen Time")
                .font(.custom("AvenirNext-Medium", size: 18))
                .foregroundColor(.white.opacity(0.85))

            HStack(spacing: 12) {
                if let (val, unit) = extract(component: "h") {
                    activitySegment(value: val, unit: unit)
                }
                if let (val, unit) = extract(component: "m") {
                    activitySegment(value: val, unit: unit)
                }
                if let (val, unit) = extract(component: "s") {
                    activitySegment(value: val, unit: unit)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func extract(component: String) -> (String, String)? {
        guard let range = totalActivity.range(of: component),
              let number = totalActivity[..<range.lowerBound].split(separator: " ").last else { return nil }
        return (String(number), component)
    }

    private func activitySegment(value: String, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(value)
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text(unit)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray.opacity(0.7))
        }
    }
}

#Preview {
    TotalActivityView(totalActivity: "1h 23m 44s")
}

