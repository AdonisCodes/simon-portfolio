import Foundation

struct FlightPhoto {
    let t: Double
    let imageUrl: String
    let caption: String
}

struct MapPhoto {
    let lat: Double
    let lng: Double
    let imageUrl: String
    let caption: String
}

struct TravelFlight {
    let date: String
    let direction: String
    let flightNumber: String
    let fromName: String
    let fromCode: String
    let fromLat: Double
    let fromLng: Double
    let toName: String
    let toCode: String
    let toLat: Double
    let toLng: Double
    let depart: String
    let arrive: String
    let duration: String
    let layover: String
    let cost: String
    let flightradarUrl: String
    let photos: [FlightPhoto]
}

struct TravelEvent {
    let id: String
    let type: String
    let title: String
    let date: String
    let location: String
    let description: String
    let stravaUrl: String
    let youtubeUrl: String
    let youtubeTitle: String
    let itineraryUrl: String
    let stats: String
    let flightNote: String
    let tripExtrasCost: String
    let region: [(lat: Double, lng: Double)]
    let route: [(lat: Double, lng: Double)]
    let spots: [MapPhoto]
    let flights: [TravelFlight]
}

private let jnbLat = -26.1392
private let jnbLng = 28.2460

let amsterdamMarathon2027 = TravelEvent(
    id: "amsterdam-marathon-2027",
    type: "marathon",
    title: "Amsterdam Marathon 2027",
    date: "2027-10-18",
    location: "Amsterdam, NL",
    description: "42.2 km through the canals, parks, and streets of Amsterdam.",
    stravaUrl: "https://www.strava.com/activities/mock-amsterdam-2027",
    youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    youtubeTitle: "Amsterdam Marathon 2027 — full race vlog (4:32:18)",
    itineraryUrl: "https://simonferns.com/amsterdam-2027",
    stats: "42.2 km · 4:32:18 · 142 avg HR",
    flightNote: "In AMS Oct 15 → Oct 29, 2027",
    tripExtrasCost: "$2,480",
    region: [
        (52.425, 4.735),
        (52.430, 4.820),
        (52.415, 4.920),
        (52.395, 5.010),
        (52.355, 4.995),
        (52.325, 4.920),
        (52.318, 4.850),
        (52.325, 4.780),
        (52.355, 4.730),
        (52.395, 4.728),
        (52.425, 4.735),
    ],
    route: [
        (52.3442, 4.8542),
        (52.3588, 4.8688),
        (52.3641, 4.8812),
        (52.3675, 4.9041),
        (52.3731, 4.8953),
        (52.3788, 4.8820),
        (52.3820, 4.8640),
        (52.3765, 4.8480),
        (52.3680, 4.8350),
        (52.3590, 4.8280),
        (52.3510, 4.8360),
        (52.3442, 4.8542),
    ],
    spots: [
        MapPhoto(
            lat: 52.3814,
            lng: 4.6401,
            imageUrl: "https://picsum.photos/seed/ams-haarlem/240/240",
            caption: "Haarlem day trip · Oct 19, 2027",
        ),
        MapPhoto(
            lat: 52.4742,
            lng: 4.8176,
            imageUrl: "https://picsum.photos/seed/ams-windmills/240/240",
            caption: "Zaanse Schans windmills · Oct 20, 2027",
        ),
        MapPhoto(
            lat: 52.3567,
            lng: 4.9045,
            imageUrl: "https://picsum.photos/seed/ams-expo/240/240",
            caption: "Marathon expo · Oct 16, 2027",
        ),
    ],
    flights: [
        TravelFlight(
            date: "2027-10-15",
            direction: "Outbound",
            flightNumber: "KL591",
            fromName: "Johannesburg OR Tambo",
            fromCode: "JNB",
            fromLat: jnbLat,
            fromLng: jnbLng,
            toName: "Amsterdam Schiphol",
            toCode: "AMS",
            toLat: 52.3105,
            toLng: 4.7683,
            depart: "20:45",
            arrive: "06:15+1",
            duration: "10h 30m",
            layover: "Direct",
            cost: "$968",
            flightradarUrl: "https://www.flightradar24.com/data/flights/kl591",
            photos: [
                FlightPhoto(
                    t: 0.32,
                    imageUrl: "https://picsum.photos/seed/kl591-dinner/240/240",
                    caption: "Dinner service over the Sahara",
                ),
                FlightPhoto(
                    t: 0.68,
                    imageUrl: "https://picsum.photos/seed/kl591-sunrise/240/240",
                    caption: "Sunrise approach into Amsterdam",
                ),
            ],
        ),
        TravelFlight(
            date: "2027-10-29",
            direction: "Return",
            flightNumber: "KL592",
            fromName: "Amsterdam Schiphol",
            fromCode: "AMS",
            fromLat: 52.3105,
            fromLng: 4.7683,
            toName: "Johannesburg OR Tambo",
            toCode: "JNB",
            toLat: jnbLat,
            toLng: jnbLng,
            depart: "11:20",
            arrive: "23:05",
            duration: "10h 45m",
            layover: "Direct",
            cost: "$968",
            flightradarUrl: "https://www.flightradar24.com/data/flights/kl592",
            photos: [
                FlightPhoto(
                    t: 0.45,
                    imageUrl: "https://picsum.photos/seed/kl592-clouds/240/240",
                    caption: "Clouds over the equator",
                ),
            ],
        ),
    ],
)

let capePointHike2028 = TravelEvent(
    id: "cape-point-hike-2028",
    type: "hike",
    title: "Cape Point Trail",
    date: "2028-03-12",
    location: "Cape Town, ZA",
    description: "Two-day coastal hike around the Cape Peninsula.",
    stravaUrl: "https://www.strava.com/activities/mock-cape-point-2028",
    youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    youtubeTitle: "Cape Point Trail 2028 — coastal hike vlog (planned)",
    itineraryUrl: "",
    stats: "Planned · 38 km",
    flightNote: "In Cape Town Mar 10 → Mar 14, 2028",
    tripExtrasCost: "$380",
    region: [
        (-34.055, 18.420),
        (-34.050, 18.520),
        (-34.080, 18.550),
        (-34.150, 18.520),
        (-34.250, 18.480),
        (-34.350, 18.420),
        (-34.380, 18.360),
        (-34.340, 18.320),
        (-34.250, 18.340),
        (-34.150, 18.380),
        (-34.055, 18.420),
    ],
    route: [],
    spots: [
        MapPhoto(
            lat: -34.3570,
            lng: 18.4920,
            imageUrl: "https://picsum.photos/seed/cape-point/240/240",
            caption: "Cape Point lookout · Mar 12, 2028",
        ),
        MapPhoto(
            lat: -34.0210,
            lng: 18.3560,
            imageUrl: "https://picsum.photos/seed/boulders-beach/240/240",
            caption: "Boulders Beach penguins · Mar 11, 2028",
        ),
    ],
    flights: [
        TravelFlight(
            date: "2028-03-10",
            direction: "Outbound",
            flightNumber: "FA200",
            fromName: "Johannesburg OR Tambo",
            fromCode: "JNB",
            fromLat: jnbLat,
            fromLng: jnbLng,
            toName: "Cape Town International",
            toCode: "CPT",
            toLat: -33.9648,
            toLng: 18.6017,
            depart: "06:15",
            arrive: "08:25",
            duration: "2h 10m",
            layover: "Direct",
            cost: "$142",
            flightradarUrl: "https://www.flightradar24.com/data/flights/fa200",
            photos: [
                FlightPhoto(
                    t: 0.5,
                    imageUrl: "https://picsum.photos/seed/fa200-descent/240/240",
                    caption: "Descent into Cape Town",
                ),
            ],
        ),
        TravelFlight(
            date: "2028-03-14",
            direction: "Return",
            flightNumber: "FA201",
            fromName: "Cape Town International",
            fromCode: "CPT",
            fromLat: -33.9648,
            fromLng: 18.6017,
            toName: "Johannesburg OR Tambo",
            toCode: "JNB",
            toLat: jnbLat,
            toLng: jnbLng,
            depart: "18:40",
            arrive: "20:45",
            duration: "2h 05m",
            layover: "Direct",
            cost: "$142",
            flightradarUrl: "https://www.flightradar24.com/data/flights/fa201",
            photos: [],
        ),
    ],
)

let ironmanSouthAfrica2029 = TravelEvent(
    id: "ironman-south-africa-2029",
    type: "ironman",
    title: "Ironman South Africa",
    date: "2029-04-07",
    location: "Gqeberha, ZA",
    description: "140.6 miles — swim, bike, run along the Eastern Cape.",
    stravaUrl: "https://www.strava.com/activities/mock-ironman-sa-2029",
    youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    youtubeTitle: "Ironman South Africa 2029 — race day vlog (planned)",
    itineraryUrl: "",
    stats: "Planned · 140.6 mi",
    flightNote: "In Gqeberha Apr 4 → Apr 9, 2029",
    tripExtrasCost: "$520",
    region: [
        (-33.890, 25.530),
        (-33.885, 25.620),
        (-33.900, 25.710),
        (-33.960, 25.720),
        (-34.010, 25.680),
        (-34.015, 25.590),
        (-33.980, 25.530),
        (-33.920, 25.525),
        (-33.890, 25.530),
    ],
    route: [],
    spots: [
        MapPhoto(
            lat: -33.9840,
            lng: 25.6550,
            imageUrl: "https://picsum.photos/seed/im-swim-start/240/240",
            caption: "Swim start · King's Beach",
        ),
    ],
    flights: [
        TravelFlight(
            date: "2029-04-04",
            direction: "Outbound",
            flightNumber: "FA310",
            fromName: "Johannesburg OR Tambo",
            fromCode: "JNB",
            fromLat: jnbLat,
            fromLng: jnbLng,
            toName: "Chief Dawid Stuurman International",
            toCode: "PLZ",
            toLat: -33.9849,
            toLng: 25.6173,
            depart: "07:05",
            arrive: "08:50",
            duration: "1h 45m",
            layover: "Direct",
            cost: "$128",
            flightradarUrl: "https://www.flightradar24.com/data/flights/fa310",
            photos: [
                FlightPhoto(
                    t: 0.55,
                    imageUrl: "https://picsum.photos/seed/fa310-coast/240/240",
                    caption: "Coastal approach to Gqeberha",
                ),
            ],
        ),
        TravelFlight(
            date: "2029-04-09",
            direction: "Return",
            flightNumber: "FA311",
            fromName: "Chief Dawid Stuurman International",
            fromCode: "PLZ",
            fromLat: -33.9849,
            fromLng: 25.6173,
            toName: "Johannesburg OR Tambo",
            toCode: "JNB",
            toLat: jnbLat,
            toLng: jnbLng,
            depart: "16:20",
            arrive: "18:00",
            duration: "1h 40m",
            layover: "Direct",
            cost: "$128",
            flightradarUrl: "https://www.flightradar24.com/data/flights/fa311",
            photos: [],
        ),
    ],
)

let worldPhotos: [MapPhoto] = [
    MapPhoto(
        lat: 35.6762,
        lng: 139.6503,
        imageUrl: "https://picsum.photos/seed/world-tokyo/240/240",
        caption: "Layover ramen · Tokyo",
    ),
    MapPhoto(
        lat: 40.7128,
        lng: -74.0060,
        imageUrl: "https://picsum.photos/seed/world-nyc/240/240",
        caption: "Midnight taxi · New York",
    ),
    MapPhoto(
        lat: -22.9068,
        lng: -43.1729,
        imageUrl: "https://picsum.photos/seed/world-rio/240/240",
        caption: "Copacabana run · Rio",
    ),
    MapPhoto(
        lat: 48.8566,
        lng: 2.3522,
        imageUrl: "https://picsum.photos/seed/world-paris/240/240",
        caption: "Metro sprint · Paris",
    ),
    MapPhoto(
        lat: 1.3521,
        lng: 103.8198,
        imageUrl: "https://picsum.photos/seed/world-sg/240/240",
        caption: "Airport nap · Singapore",
    ),
]

let travelEvents: [TravelEvent] = [
    amsterdamMarathon2027,
    capePointHike2028,
    ironmanSouthAfrica2029,
]

func parseCost(_ value: String) -> Double {
    let digits = value.filter { $0.isNumber || $0 == "." }
    return Double(digits) ?? 0
}

func formatCost(_ amount: Double) -> String {
    if amount == floor(amount) {
        return "$\(Int(amount))"
    }
    return "$\(String(format: "%.0f", amount))"
}

func tripTotalLabel(for event: TravelEvent) -> String {
    let flightTotal = event.flights.reduce(0.0) { $0 + parseCost($1.cost) }
    let extras = parseCost(event.tripExtrasCost)
    let total = flightTotal + extras
    return "Total trip cost · \(formatCost(total))"
}

func tripCostBreakdown(for event: TravelEvent) -> String {
    let flightTotal = event.flights.reduce(0.0) { $0 + parseCost($1.cost) }
    return "Flights \(formatCost(flightTotal)) · Extras \(event.tripExtrasCost)"
}

func flightTotalLabel(for flights: [TravelFlight]) -> String {
    let total = flights.reduce(0.0) { $0 + parseCost($1.cost) }
    return "Flights · \(formatCost(total))"
}

func regionBounds(_ region: [(lat: Double, lng: Double)]) -> (south: Double, west: Double, north: Double, east: Double) {
    let lats = region.map(\.lat)
    let lngs = region.map(\.lng)
    return (lats.min() ?? 0, lngs.min() ?? 0, lats.max() ?? 0, lngs.max() ?? 0)
}

func jsonEscape(_ value: String) -> String {
    value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
}

func travelMapJSON() -> String {
    let activitiesJSON = travelEvents.map { event in
        let routeCoords = event.route.map { "[\($0.lat), \($0.lng)]" }.joined(separator: ", ")
        let regionCoords = event.region.map { "[\($0.lat), \($0.lng)]" }.joined(separator: ", ")
        let pinLat = event.route.first?.lat ?? event.region.first?.lat ?? 0
        let pinLng = event.route.first?.lng ?? event.region.first?.lng ?? 0
        let bounds = regionBounds(event.region)
        let spotsJSON = event.spots.map { spot in
            """
            {"lat":\(spot.lat),"lng":\(spot.lng),"imageUrl":"\(jsonEscape(spot.imageUrl))","caption":"\(jsonEscape(spot.caption))"}
            """
        }.joined(separator: ",")
        let flightsJSON = event.flights.map { flight in
            let photosJSON = flight.photos.map { photo in
                """
                {"t":\(photo.t),"imageUrl":"\(jsonEscape(photo.imageUrl))","caption":"\(jsonEscape(photo.caption))"}
                """
            }.joined(separator: ",")
            return """
            {"date":"\(flight.date)","direction":"\(flight.direction)","flightNumber":"\(flight.flightNumber)","fromCode":"\(flight.fromCode)","fromLat":\(flight.fromLat),"fromLng":\(flight.fromLng),"toCode":"\(flight.toCode)","toLat":\(flight.toLat),"toLng":\(flight.toLng),"depart":"\(flight.depart)","arrive":"\(flight.arrive)","duration":"\(flight.duration)","layover":"\(flight.layover)","cost":"\(flight.cost)","flightradarUrl":"\(flight.flightradarUrl)","photos":[\(photosJSON)]}
            """
        }.joined(separator: ",")
        return """
        {"id":"\(event.id)","type":"\(event.type)","title":"\(event.title)","bounds":[[\(bounds.south),\(bounds.west)],[\(bounds.north),\(bounds.east)]],"region":[\(regionCoords)],"route":[\(routeCoords)],"pin":[\(pinLat),\(pinLng)],"spots":[\(spotsJSON)],"flights":[\(flightsJSON)]}
        """
    }.joined(separator: ",")

    let worldPhotosJSON = worldPhotos.map { photo in
        """
        {"lat":\(photo.lat),"lng":\(photo.lng),"imageUrl":"\(jsonEscape(photo.imageUrl))","caption":"\(jsonEscape(photo.caption))"}
        """
    }.joined(separator: ",")

    return """
    {"activities":[\(activitiesJSON)],"worldPhotos":[\(worldPhotosJSON)]}
    """
}

func formatDisplayDate(_ iso: String) -> String {
    let parts = iso.split(separator: "-")
    guard parts.count == 3 else { return iso }
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let monthIndex = (Int(parts[1]) ?? 1) - 1
    let month = months[max(0, min(monthIndex, 11))]
    return "\(month) \(parts[2]), \(parts[0])"
}
