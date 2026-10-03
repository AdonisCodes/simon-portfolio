import JavaScriptKit
import SwiftVan

// MARK: - Workout Link Data

struct WorkoutSegmentSummary {
    let title: String
    let detail: String
}

struct WorkoutLinkData {
    let rawD: String?
    let decoded: Bool
    let name: String?
    let durationText: String?
    let segments: [WorkoutSegmentSummary]

    var appLink: String {
        guard let rawD, !rawD.isEmpty else { return "autozone://workout" }
        return "autozone://workout?d=\(rawD)"
    }
}

func formatWorkoutDuration(_ seconds: Double) -> String {
    let total = Int(seconds.rounded())
    guard total > 0 else { return "0 sec" }

    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let secs = total % 60
    var parts: [String] = []

    if hours > 0 { parts.append("\(hours) hr") }
    if minutes > 0 { parts.append("\(minutes) min") }
    if secs > 0, hours == 0 { parts.append("\(secs) sec") }

    return parts.joined(separator: " ")
}

private func firstString(in object: JSObject, keys: [String]) -> String? {
    for key in keys {
        if let value = object[key].string, !value.isEmpty {
            return value
        }
    }
    return nil
}

private func firstNumber(in object: JSObject, keys: [String]) -> Double? {
    for key in keys {
        if let value = object[key].number {
            return value
        }
    }
    return nil
}

private func segmentSummary(_ segment: JSObject, index: Int) -> WorkoutSegmentSummary {
    let title = firstString(in: segment, keys: ["name", "title", "label", "type"])
        ?? "Segment \(index + 1)"

    var details: [String] = []
    if let zone = firstNumber(in: segment, keys: ["zone", "targetZone"]) {
        details.append("Zone \(Int(zone))")
    }
    if let duration = firstNumber(in: segment, keys: ["duration", "durationSeconds", "seconds", "time"]) {
        details.append(formatWorkoutDuration(duration))
    }

    return WorkoutSegmentSummary(title: title, detail: details.joined(separator: " · "))
}

/// Reads the `d` query parameter (base64url-encoded JSON workout payload) and
/// decodes it defensively. Any malformed input results in `decoded == false`
/// so the page can fall back to a generic message.
func loadWorkoutLinkData() -> WorkoutLinkData {
    let script = """
    (function() {
      var result = { rawD: null, ok: false, payload: null };
      try {
        var match = (window.location.search || '').match(/[?&]d=([^&]*)/);
        if (!match || !match[1]) { return result; }
        result.rawD = match[1];
        var b64 = decodeURIComponent(match[1]).replace(/-/g, '+').replace(/_/g, '/');
        if (b64.length % 4 === 1) { return result; }
        while (b64.length % 4 !== 0) { b64 += '='; }
        var bin = atob(b64);
        var bytes = new Uint8Array(bin.length);
        for (var i = 0; i < bin.length; i += 1) { bytes[i] = bin.charCodeAt(i); }
        var text = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
        var payload = JSON.parse(text);
        if (payload && typeof payload === 'object') {
          result.payload = payload;
          result.ok = true;
        }
      } catch (error) {
        result.ok = false;
      }
      return result;
    })()
    """

    let value = JSObject.global.eval.function!(JSValue.string(script))
    guard let result = value.object else {
        return WorkoutLinkData(rawD: nil, decoded: false, name: nil, durationText: nil, segments: [])
    }

    let rawD = result.rawD.string
    guard result.ok.boolean == true, let payload = result.payload.object else {
        return WorkoutLinkData(rawD: rawD, decoded: false, name: nil, durationText: nil, segments: [])
    }

    let name = firstString(in: payload, keys: ["name", "title", "workoutName"])

    var durationText: String?
    if let duration = firstNumber(
        in: payload,
        keys: ["totalDuration", "duration", "totalSeconds", "durationSeconds"],
    ) {
        durationText = formatWorkoutDuration(duration)
    }

    var segments: [WorkoutSegmentSummary] = []
    if let segmentList = payload.segments.object,
       let count = segmentList.length.number {
        for index in 0 ..< Int(count) {
            guard let segment = segmentList[index].object else { continue }
            segments.append(segmentSummary(segment, index: index))
        }
    }

    return WorkoutLinkData(
        rawD: rawD,
        decoded: true,
        name: name,
        durationText: durationText,
        segments: segments,
    )
}

// MARK: - Workout Page

final class WorkoutPage {
    let data: WorkoutLinkData

    init(data: WorkoutLinkData = loadWorkoutLinkData()) {
        self.data = data
    }

    func render() -> AnyElement {
        Div(attributes: { ["className": "container workout-container"] }) {
            NavBar(showStatsLink: false).render()

            Div(attributes: { ["className": "section workout-card"] }) {
                Div(attributes: { ["className": "workout-kicker"] }) {
                    Text({ "AutoZone Workout" })
                }

                Div(attributes: { ["className": "title workout-title"] }) {
                    Text({ self.data.name ?? "Shared Workout" })
                }

                If(
                    { self.data.durationText != nil },
                    states: [],
                    If: {
                        Div(attributes: { ["className": "workout-duration"] }) {
                            Text({ self.data.durationText! })
                        }
                    },
                )

                If(
                    { !self.data.decoded },
                    states: [],
                    If: {
                        Div(attributes: { ["className": "workout-muted"] }) {
                            Text({
                                "This link doesn't include readable workout details, but you can still open it in the app."
                            })
                        }
                    },
                )

                If(
                    { !self.data.segments.isEmpty },
                    states: [],
                    If: {
                        Div(attributes: { ["className": "workout-segments"] }) {
                            ForEach(items: State(self.data.segments)) { segment in
                                Div(attributes: { ["className": "workout-segment"] }) {
                                    Div(attributes: { ["className": "workout-segment-title"] }) {
                                        Text({ segment.title })
                                    }

                                    If(
                                        { !segment.detail.isEmpty },
                                        states: [],
                                        If: {
                                            Div(attributes: { ["className": "workout-segment-detail"] }) {
                                                Text({ segment.detail })
                                            }
                                        },
                                    )
                                }
                            }
                        }
                    },
                )

                HyperLink(
                    attributes: {
                        [
                            "href": self.data.appLink,
                            "className": "button workout-open-button",
                        ]
                    }
                ) {
                    Text({ "Open in AutoZone" })
                }

                Div(attributes: { ["className": "workout-muted workout-hint"] }) {
                    Text({
                        "If nothing happens, install AutoZone on your iPhone and open this link again."
                    })
                }
            }
        }
    }
}
