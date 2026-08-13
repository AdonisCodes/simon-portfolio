import Foundation
import JavaScriptKit

// MARK: - Model

struct RunEntry {
    let date: String
    let avgSpeedPerKm: String
    let runHrAverage: Int
}

// MARK: - Data

nonisolated(unsafe) let runEntries: [RunEntry] = [
    RunEntry(date: "2026-01-06", avgSpeedPerKm: "11:42", runHrAverage: 132),
    RunEntry(date: "2026-01-13", avgSpeedPerKm: "11:28", runHrAverage: 134),
    RunEntry(date: "2026-01-20", avgSpeedPerKm: "11:15", runHrAverage: 136),
    RunEntry(date: "2026-02-03", avgSpeedPerKm: "11:05", runHrAverage: 137),
    RunEntry(date: "2026-02-17", avgSpeedPerKm: "10:58", runHrAverage: 138),
    RunEntry(date: "2026-03-02", avgSpeedPerKm: "10:50", runHrAverage: 139),
    RunEntry(date: "2026-03-16", avgSpeedPerKm: "10:45", runHrAverage: 140),
    RunEntry(date: "2026-04-01", avgSpeedPerKm: "10:38", runHrAverage: 141),
    RunEntry(date: "2026-04-15", avgSpeedPerKm: "10:32", runHrAverage: 141),
    RunEntry(date: "2026-05-06", avgSpeedPerKm: "10:28", runHrAverage: 142),
    RunEntry(date: "2026-05-20", avgSpeedPerKm: "10:24", runHrAverage: 142),
    RunEntry(date: "2026-06-10", avgSpeedPerKm: "10:22", runHrAverage: 143),
    RunEntry(date: "2026-07-01", avgSpeedPerKm: "10:20", runHrAverage: 143),
    RunEntry(date: "2026-08-13", avgSpeedPerKm: "10:19", runHrAverage: 143),
]

// MARK: - Helpers

func paceToKmh(_ pace: String) -> Double {
    let parts = pace.split(separator: ":")
    guard parts.count == 2,
          let minutes = Double(parts[0]),
          let seconds = Double(parts[1])
    else { return 0 }

    let totalMinutes = minutes + seconds / 60
    guard totalMinutes > 0 else { return 0 }
    return 60 / totalMinutes
}

func formatShortDate(_ isoDate: String) -> String {
    let parts = isoDate.split(separator: "-")
    guard parts.count == 3 else { return isoDate }

    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let monthIndex = (Int(parts[1]) ?? 1) - 1
    let month = months[max(0, min(monthIndex, 11))]
    return "\(month) \(parts[2])"
}

func formatKmh(_ value: Double) -> String {
    String(format: "%.1f", value)
}

// MARK: - Chart

func buildRunChartSVG(entries: [RunEntry]) -> String {
    guard !entries.isEmpty else { return "" }

    let width = 812.0
    let height = 320.0
    let padLeft = 44.0
    let padRight = 44.0
    let padTop = 28.0
    let padBottom = 36.0
    let plotWidth = width - padLeft - padRight
    let plotHeight = height - padTop - padBottom

    let speeds = entries.map { paceToKmh($0.avgSpeedPerKm) }
    let heartRates = entries.map { Double($0.runHrAverage) }

    let minSpeed = (speeds.min() ?? 0) * 0.96
    let maxSpeed = (speeds.max() ?? 1) * 1.04
    let minHR = (heartRates.min() ?? 0) - 4
    let maxHR = (heartRates.max() ?? 1) + 4

    let speedRange = max(maxSpeed - minSpeed, 0.01)
    let hrRange = max(maxHR - minHR, 1)

    func xPosition(_ index: Int) -> Double {
        let denominator = max(entries.count - 1, 1)
        return padLeft + (Double(index) / Double(denominator)) * plotWidth
    }

    func ySpeed(_ value: Double) -> Double {
        padTop + plotHeight - ((value - minSpeed) / speedRange) * plotHeight
    }

    func yHeartRate(_ value: Double) -> Double {
        padTop + plotHeight - ((value - minHR) / hrRange) * plotHeight
    }

    var svg = """
    <svg viewBox="0 0 \(Int(width)) \(Int(height))" class="run-chart-svg" preserveAspectRatio="none" aria-hidden="true">
    <rect x="0" y="0" width="\(Int(width))" height="\(Int(height))" fill="transparent"/>
    """

    let gridLines = 4
    for index in 0 ... gridLines {
        let y = padTop + (Double(index) / Double(gridLines)) * plotHeight
        svg += """
        <line x1="\(padLeft)" y1="\(y)" x2="\(width - padRight)" y2="\(y)" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>
        """
    }

    var speedPolyline = ""
    var hrPolyline = ""
    for (index, _) in entries.enumerated() {
        let x = xPosition(index)
        speedPolyline += "\(x),\(ySpeed(speeds[index])) "
        hrPolyline += "\(x),\(yHeartRate(heartRates[index])) "
    }

    svg += """
    <polyline points="\(speedPolyline.trimmingCharacters(in: .whitespaces))" fill="none" stroke="#4fa760" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>
    <polyline points="\(hrPolyline.trimmingCharacters(in: .whitespaces))" fill="none" stroke="#ffffff" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round" opacity="0.85"/>
    """

    let labelCount = min(8, entries.count)
    let labelStep = max((entries.count - 1) / max(labelCount - 1, 1), 1)
    var labelIndex = 0
    while labelIndex < entries.count {
        let x = xPosition(labelIndex)
        let label = formatShortDate(entries[labelIndex].date)
        svg += """
        <line x1="\(x)" y1="\(padTop + plotHeight)" x2="\(x)" y2="\(padTop + plotHeight + 4)" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
        <text x="\(x)" y="\(height - 10)" fill="#9a9a9a" font-size="11" text-anchor="middle">\(label)</text>
        """
        labelIndex += labelStep
    }

    for index in 0 ... gridLines {
        let speedValue = maxSpeed - (Double(index) / Double(gridLines)) * speedRange
        let hrValue = maxHR - (Double(index) / Double(gridLines)) * hrRange
        let y = padTop + (Double(index) / Double(gridLines)) * plotHeight

        svg += """
        <text x="\(padLeft - 8)" y="\(y + 4)" fill="#4fa760" font-size="10" text-anchor="end">\(formatKmh(speedValue))</text>
        <text x="\(width - padRight + 8)" y="\(y + 4)" fill="#ffffff" font-size="10" text-anchor="start">\(Int(hrValue))</text>
        """
    }

    svg += "</svg>"
    return svg
}

func mountRunChart() {
    let document = JSObject.global.document
    guard let container = document.getElementById("run-chart-container").object else { return }

    container.innerHTML = JSValue.string(buildRunChartSVG(entries: runEntries))
}
