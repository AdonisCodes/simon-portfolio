import JavaScriptKit
import SwiftVan

// MARK: - Routing

func currentPath() -> String {
    JSObject.global.location.pathname.string ?? "/"
}

// MARK: - Models

struct Project {
    let name: String
    let description: String
    let image: String
    let github: String?
    let website: String?
}

struct Social {
    let name: String
    let url: String
}

// MARK: - State

nonisolated(unsafe) let projects = State([
    Project(
        name: "GetAutoma",
        description:
            "Automation-first platform and tooling focused on reducing friction in real workflows.",
        image: "/assets/getautoma.png",
        github: "https://github.com/GetAutomaApp",
        website: "https://getautoma.app",
    ),
    Project(
        name: "SwiftVan",
        description:
            "A Swift-first UI-style DSL for building websites that compile to WebAssembly.",
        image: "/assets/swiftvan.png",
        github: "https://github.com/GetAutomaApp/SwiftVan",
        website: nil,
    ),
    Project(
        name: "Coming Soon...",
        description:
            "I'm working on some more impressive projects at the moment, can't wait to share@",
        image: "/assets/ellipsis.png",
        github: nil,
        website: nil,
    ),
])

nonisolated(unsafe) let socials = State([
    Social(name: "GitHub", url: "https://github.com/adoniscodes"),
    Social(name: "YouTube", url: "https://youtube.com/@adoniscodes"),
    Social(name: "Instagram", url: "https://instagram.com/adoniscodes_"),
    Social(name: "Strava", url: "https://www.strava.com/athletes/196078897"),
    Social(name: "Printables", url: "https://www.printables.com/@adoniscodes_3658566"),
])

// MARK: - Navigation

final class NavBar {
    let showStatsLink: Bool

    init(showStatsLink: Bool = true) {
        self.showStatsLink = showStatsLink
    }

    func render() -> AnyElement {
        Div(attributes: { ["className": "nav"] }) {
            HyperLink(attributes: { ["href": "/", "className": "social-link"] }) {
                Text({ "Home" })
            }

            If(
                { self.showStatsLink },
                states: [],
                If: {
                    HyperLink(attributes: { ["href": "/travel", "className": "social-link"] }) {
                        Text({ "Travel" })
                    }
                },
            )
        }
    }
}

// MARK: - Header

final class Header {
    func render() -> AnyElement {
        Div(attributes: { ["className": "section header"] }) {

            Div(attributes: { ["className": "title"] }) {
                Text({ "Simon Ferns" })
            }

            Div(attributes: { ["className": "subtitle"] }) {
                Text({
                    "I dabble in software engineering, recreational programming, 3D printing, travelling, running, and working out."
                })
            }
        }
    }
}

// MARK: - Projects

final class ProjectCard {
    func render(_ project: Project) -> AnyElement {
        Div(attributes: { ["className": "project-card"] }) {

            Image(attributes: {
                [
                    "src": project.image,
                    "className": "project-image",
                ]
            })

            Div(attributes: { ["className": "project-body"] }) {

                Div(attributes: { ["className": "project-title"] }) {
                    Text({ project.name })
                }

                Div(attributes: { ["className": "project-desc"] }) {
                    Text({ project.description })
                }

                Div(attributes: { ["className": "project-links"] }) {
                    If(
                        { project.github != nil },
                        states: [],
                        If: {
                            HyperLink(
                                attributes: {
                                    [
                                        "href": project.github!,
                                        "target": "_blank",
                                        "className": "button",
                                    ]
                                }
                            ) {
                                Text({ "GitHub" })
                            }
                        }
                    )

                    If(
                        { project.website != nil },
                        states: [],
                        If: {
                            HyperLink(
                                attributes: {
                                    [
                                        "href": project.website!,
                                        "target": "_blank",
                                        "className": "button secondary",
                                    ]
                                }
                            ) {
                                Text({ "Website" })
                            }
                        },
                    )
                }
            }
        }
    }
}

final class ProjectsSection {
    func render() -> AnyElement {
        Div(attributes: { ["className": "section"] }) {

            Div(attributes: { ["className": "section-title"] }) {
                Text({ "Projects" })
            }

            ForEach(items: projects) { project in
                ProjectCard().render(project)
            }
        }
    }
}

// MARK: - Socials

final class SocialsSection {
    func render() -> AnyElement {
        Div(attributes: { ["className": "section"] }) {

            Div(attributes: { ["className": "section-title"] }) {
                Text({ "Socials" })
            }

            Div(attributes: { ["className": "socials"] }) {
                ForEach(items: socials) { social in
                    HyperLink(
                        attributes: {
                            [
                                "href": social.url,
                                "target": "_blank",
                                "className": "social-link",
                            ]
                        }
                    ) {
                        Text({ social.name })
                    }
                }
            }
        }
    }
}

// MARK: - Contact

final class ContactSection {
    func render() -> AnyElement {
        Div(attributes: { ["className": "section contact"] }) {

            Div(attributes: { ["className": "section-title"] }) {
                Text({ "Contact" })
            }

            Div(attributes: { ["className": "contact-muted"] }) {
                Text({
                    "Not looking for employment. Open to collaboration and serious conversations."
                })
            }

            Div(attributes: { ["className": "contact-email"] }) {
                HyperLink(
                    attributes: {
                        [
                            "href": "mailto:simon@simonferns.com",
                            "className": "email-link",
                        ]
                    }
                ) {
                    Text({ "simon@simonferns.com" })
                }
            }
        }
    }
}

// MARK: - Stats

final class StatsPage {
    func renderActivityDetail(_ event: TravelEvent) -> AnyElement {
        Div(
            attributes: {
                [
                    "className": "activity-detail",
                    "id": "activity-detail-\(event.id)",
                ]
            },
        ) {
            Div(attributes: { ["className": "travel-event-card"] }) {
                Div(attributes: { ["className": "travel-event-type"] }) {
                    Text({ event.type.uppercased() })
                }

                Div(attributes: { ["className": "travel-event-title"] }) {
                    Text({ event.title })
                }

                Div(attributes: { ["className": "travel-event-meta"] }) {
                    Text({ "\(formatDisplayDate(event.date)) · \(event.location)" })
                }

                Div(attributes: { ["className": "travel-event-desc"] }) {
                    Text({ event.description })
                }

                Div(attributes: { ["className": "travel-event-stats"] }) {
                    Text({ event.stats })
                }

                Div(attributes: { ["className": "travel-links"] }) {
                    If(
                        { !event.stravaUrl.isEmpty },
                        states: [],
                        If: {
                            HyperLink(
                                attributes: {
                                    [
                                        "href": event.stravaUrl,
                                        "target": "_blank",
                                        "className": "button secondary",
                                    ]
                                },
                            ) {
                                Text({ "Strava" })
                            }
                        },
                    )

                    If(
                        { !event.youtubeUrl.isEmpty },
                        states: [],
                        If: {
                            HyperLink(
                                attributes: {
                                    [
                                        "href": event.youtubeUrl,
                                        "target": "_blank",
                                        "className": "button secondary",
                                    ]
                                },
                            ) {
                                Text({ "YouTube" })
                            }
                        },
                    )

                    If(
                        { !event.itineraryUrl.isEmpty },
                        states: [],
                        If: {
                            HyperLink(
                                attributes: {
                                    [
                                        "href": event.itineraryUrl,
                                        "target": "_blank",
                                        "className": "button secondary",
                                    ]
                                },
                            ) {
                                Text({ "Itinerary" })
                            }
                        },
                    )
                }

                If(
                    { !event.youtubeTitle.isEmpty },
                    states: [],
                    If: {
                        Div(attributes: { ["className": "travel-youtube-note"] }) {
                            Text({ event.youtubeTitle })
                        }
                    },
                )
            }

            If(
                { !event.flights.isEmpty },
                states: [],
                If: {
                    Div(attributes: { ["className": "drawer-section"] }) {
                        Div(attributes: { ["className": "drawer-section-title"] }) {
                            Text({ "Flights" })
                        }

                        Div(attributes: { ["className": "travel-flight-note"] }) {
                            Text({ event.flightNote })
                        }

                        ForEach(items: State(event.flights)) { flight in
                            Div(attributes: { ["className": "travel-flight-card"] }) {
                                Div(attributes: { ["className": "travel-flight-direction"] }) {
                                    Text({ "\(flight.direction) · \(formatDisplayDate(flight.date))" })
                                }

                                Div(attributes: { ["className": "travel-flight-route"] }) {
                                    Text({ "\(flight.flightNumber) · \(flight.fromCode) → \(flight.toCode)" })
                                }

                                Div(attributes: { ["className": "travel-flight-times"] }) {
                                    Text({ "\(flight.depart) → \(flight.arrive) · \(flight.duration)" })
                                }

                                Div(attributes: { ["className": "travel-flight-meta"] }) {
                                    Text({ "\(flight.layover) · \(flight.cost)" })
                                }

                                HyperLink(
                                    attributes: {
                                        [
                                            "href": flight.flightradarUrl,
                                            "target": "_blank",
                                            "className": "button secondary travel-flight-link",
                                        ]
                                    },
                                ) {
                                    Text({ "Flightradar24" })
                                }
                            }
                        }

                        Div(attributes: { ["className": "travel-flight-total"] }) {
                            Text({ flightTotalLabel(for: event.flights) })
                        }

                        Div(attributes: { ["className": "travel-trip-cost-breakdown"] }) {
                            Text({ tripCostBreakdown(for: event) })
                        }

                        Div(attributes: { ["className": "travel-trip-total"] }) {
                            Text({ tripTotalLabel(for: event) })
                        }
                    }
                },
            )
        }
    }

    func render() -> AnyElement {
        Div(attributes: { ["className": "stats-layout"] }) {
            Div(attributes: { ["className": "stats-map-pane"] }) {
                Div(attributes: { ["id": "run-map", "className": "run-map"] }) {}
            }

            Div(attributes: { ["className": "stats-drawer"] }) {
                Div(attributes: { ["className": "stats-drawer-header"] }) {
                    HyperLink(attributes: { ["href": "/", "className": "social-link"] }) {
                        Text({ "Home" })
                    }

                    Div(attributes: { ["className": "stats-drawer-title"] }) {
                        Text({ "Travel" })
                    }

                    Div(attributes: { ["className": "activity-list"] }) {
                        ForEach(items: State(travelEvents)) { event in
                            Button(
                                {
                                    [
                                        "className": "activity-item",
                                        "id": "activity-item-\(event.id)",
                                    ]
                                },
                                onclick: {
                                    _ = JSObject.global.eval.function!(
                                        JSValue.string(
                                            "window.__openActivity && window.__openActivity('\(event.id)', true)",
                                        ),
                                    )
                                },
                            ) {
                                Div(attributes: { ["className": "activity-item-type"] }) {
                                    Text({ event.type.uppercased() })
                                }

                                Div(attributes: { ["className": "activity-item-title"] }) {
                                    Text({ event.title })
                                }

                                Div(attributes: { ["className": "activity-item-meta"] }) {
                                    Text({ "\(formatDisplayDate(event.date)) · \(event.location)" })
                                }
                            }
                        }
                    }
                }

                Div(attributes: { ["className": "stats-drawer-body"] }) {
                    Div(attributes: { ["className": "activity-detail-view"] }) {
                        Div(attributes: { ["className": "activity-detail-toolbar"] }) {
                            Button(
                                { ["className": "activity-detail-close", "aria-label": "Close activity"] },
                                onclick: {
                                    _ = JSObject.global.eval.function!(
                                        JSValue.string("window.__closeActivity && window.__closeActivity()"),
                                    )
                                },
                            ) {
                                Text({ "×" })
                            }
                        }

                        ForEach(items: State(travelEvents)) { event in
                            self.renderActivityDetail(event)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - App Root

final class HomePage {
    func render() -> AnyElement {
        Div(attributes: { ["className": "container"] }) {
            NavBar().render()
            Header().render()
            SocialsSection().render()
            ProjectsSection().render()
            ContactSection().render()
        }
    }
}

final class App {
    let path: String

    init(path: String = currentPath()) {
        self.path = path
    }

    func render() -> AnyElement {
        if path == "/travel" {
            return StatsPage().render()
        }

        if path == "/w" || path.hasPrefix("/w/") {
            return WorkoutPage().render()
        }

        return HomePage().render()
    }
}

// MARK: - Mount

let appPath = currentPath()
let renderer = DomRenderer(root: App(path: appPath).render())
renderer.mount()

if appPath == "/travel" {
    mountRunMap()
}
