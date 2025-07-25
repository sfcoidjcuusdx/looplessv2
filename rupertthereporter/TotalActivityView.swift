import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Today's Screen Time")
                .font(.headline)
                .foregroundColor(.primary)

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
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
        )
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
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)

            Text(unit)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    TotalActivityView(totalActivity: "1h 23m 44s")
}

