import Foundation
import JavaScriptKit

// MARK: - Model

struct RunEntry {
    let date: String
    let avgSpeedPerKm: String
    let runHrAverage: Int
}

// MARK: - Data

let runEntries: [RunEntry] = [
    RunEntry(date: "2026-08-12", avgSpeedPerKm: "10:01", runHrAverage: 145),
    RunEntry(date: "2026-08-13", avgSpeedPerKm: "10:30", runHrAverage: 148),
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

// MARK: - Chart Layout

struct ChartLayout {
    let entries: [RunEntry]
    let width: Double
    let height: Double
    let padLeft: Double
    let padRight: Double
    let padTop: Double
    let padBottom: Double

    let speeds: [Double]
    let heartRates: [Double]
    let minSpeed: Double
    let maxSpeed: Double
    let minHR: Double
    let maxHR: Double

    var plotWidth: Double { width - padLeft - padRight }
    var plotHeight: Double { height - padTop - padBottom }
    var speedRange: Double { max(maxSpeed - minSpeed, 0.01) }
    var hrRange: Double { max(maxHR - minHR, 1) }

    init(entries: [RunEntry], width: Double, height: Double, padLeft: Double = 44, padRight: Double = 44, padTop: Double = 28, padBottom: Double = 36) {
        self.entries = entries
        self.width = width
        self.height = height
        self.padLeft = padLeft
        self.padRight = padRight
        self.padTop = padTop
        self.padBottom = padBottom

        speeds = entries.map { paceToKmh($0.avgSpeedPerKm) }
        heartRates = entries.map { Double($0.runHrAverage) }

        minSpeed = (speeds.min() ?? 0) * 0.96
        maxSpeed = (speeds.max() ?? 1) * 1.04
        minHR = (heartRates.min() ?? 0) - 4
        maxHR = (heartRates.max() ?? 1) + 4
    }

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
}

// MARK: - SVG Builders

func buildRunChartContent(layout: ChartLayout) -> String {
    guard !layout.entries.isEmpty else { return "" }

    var content = """
    <rect x="0" y="0" width="\(Int(layout.width))" height="\(Int(layout.height))" fill="transparent"/>
    """

    let gridLines = 4
    for index in 0 ... gridLines {
        let y = layout.padTop + (Double(index) / Double(gridLines)) * layout.plotHeight
        content += """
        <line x1="\(layout.padLeft)" y1="\(y)" x2="\(layout.width - layout.padRight)" y2="\(y)" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>
        """
    }

    var speedPolyline = ""
    var hrPolyline = ""
    for (index, _) in layout.entries.enumerated() {
        let x = layout.xPosition(index)
        speedPolyline += "\(x),\(layout.ySpeed(layout.speeds[index])) "
        hrPolyline += "\(x),\(layout.yHeartRate(layout.heartRates[index])) "
    }

    content += """
    <polyline points="\(speedPolyline.trimmingCharacters(in: .whitespaces))" fill="none" stroke="#4fa760" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>
    <polyline points="\(hrPolyline.trimmingCharacters(in: .whitespaces))" fill="none" stroke="#ffffff" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round" opacity="0.85"/>
    """

    let labelCount = min(8, layout.entries.count)
    let labelStep = max((layout.entries.count - 1) / max(labelCount - 1, 1), 1)
    var labelIndex = 0
    while labelIndex < layout.entries.count {
        let x = layout.xPosition(labelIndex)
        let label = formatShortDate(layout.entries[labelIndex].date)
        content += """
        <line x1="\(x)" y1="\(layout.padTop + layout.plotHeight)" x2="\(x)" y2="\(layout.padTop + layout.plotHeight + 4)" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
        <text x="\(x)" y="\(layout.height - 10)" fill="#9a9a9a" font-size="11" text-anchor="middle">\(label)</text>
        """
        labelIndex += labelStep
    }

    for index in 0 ... gridLines {
        let speedValue = layout.maxSpeed - (Double(index) / Double(gridLines)) * layout.speedRange
        let hrValue = layout.maxHR - (Double(index) / Double(gridLines)) * layout.hrRange
        let y = layout.padTop + (Double(index) / Double(gridLines)) * layout.plotHeight

        content += """
        <text x="\(layout.padLeft - 8)" y="\(y + 4)" fill="#4fa760" font-size="10" text-anchor="end">\(formatKmh(speedValue))</text>
        <text x="\(layout.width - layout.padRight + 8)" y="\(y + 4)" fill="#ffffff" font-size="10" text-anchor="start">\(Int(hrValue))</text>
        """
    }

    return content
}

func buildRunChartSVG(layout: ChartLayout) -> String {
    guard !layout.entries.isEmpty else { return "" }

    return """
    <svg viewBox="0 0 \(Int(layout.width)) \(Int(layout.height))" class="run-chart-svg" preserveAspectRatio="xMidYMid meet" aria-hidden="true">
    \(buildRunChartContent(layout: layout))
    </svg>
    """
}

func buildShareChartSVG(entries: [RunEntry], size: Int = 1000) -> String {
    let layout = ChartLayout(
        entries: entries,
        width: 812,
        height: 320,
        padLeft: 48,
        padRight: 48,
        padTop: 28,
        padBottom: 36,
    )

    let canvas = Double(size)
    let sideMargin = 48.0
    let headerHeight = 168.0
    let bottomMargin = 48.0

    let maxChartWidth = canvas - (sideMargin * 2)
    let maxChartHeight = canvas - headerHeight - bottomMargin
    let chartAspect = layout.width / layout.height

    var chartWidth = maxChartWidth
    var chartHeight = chartWidth / chartAspect
    if chartHeight > maxChartHeight {
        chartHeight = maxChartHeight
        chartWidth = chartHeight * chartAspect
    }

    let chartX = (canvas - chartWidth) / 2
    let chartY = headerHeight + ((maxChartHeight - chartHeight) / 2)

    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="\(size)" height="\(size)" viewBox="0 0 \(size) \(size)">
    <rect width="\(size)" height="\(size)" fill="#000000"/>
    <text x="\(sideMargin)" y="72" fill="#ffffff" font-size="42" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif" font-weight="700">Run Stats</text>
    <text x="\(sideMargin)" y="108" fill="#9a9a9a" font-size="22" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif">simonferns.com</text>
    <circle cx="\(sideMargin)" cy="142" r="7" fill="#4fa760"/>
    <text x="\(sideMargin + 18)" y="148" fill="#bdbdbd" font-size="20" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif">Pace (km/h)</text>
    <circle cx="\(sideMargin + 200)" cy="142" r="7" fill="#ffffff"/>
    <text x="\(sideMargin + 218)" y="148" fill="#bdbdbd" font-size="20" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif">Avg HR</text>
    <svg x="\(chartX)" y="\(chartY)" width="\(chartWidth)" height="\(chartHeight)" viewBox="0 0 \(Int(layout.width)) \(Int(layout.height))" preserveAspectRatio="xMidYMid meet">
    \(buildRunChartContent(layout: layout))
    </svg>
    </svg>
    """
}

// MARK: - Mount

nonisolated(unsafe) private var shareLoadClosure: JSClosure?
nonisolated(unsafe) private var shareBlobClosure: JSClosure?

func mountRunChart() {
    let document = JSObject.global.document
    guard let container = document.getElementById("run-chart-container").object else { return }

    let layout = ChartLayout(entries: runEntries, width: 812, height: 320)
    container.innerHTML = JSValue.string(buildRunChartSVG(layout: layout))
}

// MARK: - Share

func shareRunChart() {
    let svg = buildShareChartSVG(entries: runEntries, size: 1000)
    let document = JSObject.global.document
    guard let image = document.createElement("img").object else { return }

    let encoded = JSObject.global.encodeURIComponent.function!(JSValue.string(svg)).string ?? ""
    let dataUrl = "data:image/svg+xml;charset=utf-8,\(encoded)"

    shareBlobClosure = JSClosure { args in
        guard let blob = args.first?.object else { return .undefined }
        let blobUrl = JSObject.global.URL.createObjectURL(JSValue.object(blob)).string ?? ""
        guard !blobUrl.isEmpty else { return .undefined }

        guard let link = document.createElement("a").object else { return .undefined }
        link["href"] = JSValue.string(blobUrl)
        link["download"] = JSValue.string("run-stats.png")
        _ = link.click!()
        _ = JSObject.global.URL.revokeObjectURL(JSValue.string(blobUrl))

        return .undefined
    }

    shareLoadClosure = JSClosure { _ in
        guard let canvas = document.createElement("canvas").object,
              let context = canvas.getContext!("2d").object
        else { return .undefined }

        canvas["width"] = JSValue.number(1000)
        canvas["height"] = JSValue.number(1000)
        context["fillStyle"] = JSValue.string("#000000")
        _ = context.fillRect!(JSValue.number(0), JSValue.number(0), JSValue.number(1000), JSValue.number(1000))
        _ = context.drawImage!(
            JSValue.object(image),
            JSValue.number(0),
            JSValue.number(0),
            JSValue.number(1000),
            JSValue.number(1000),
        )

        guard let blobClosure = shareBlobClosure else { return .undefined }
        _ = canvas.toBlob!(JSValue.object(blobClosure), JSValue.string("image/png"))

        return .undefined
    }

    if let loadClosure = shareLoadClosure {
        image["onload"] = JSValue.object(loadClosure)
    }
    image["src"] = JSValue.string(dataUrl)
    _ = shareBlobClosure
}
