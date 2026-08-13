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
        name: "WildLand",
        description:
            "Low-Poly toon-shaded Survival Game Built with SwiftWASM",
        image: "/assets/wildland.png",
        github: "https://github.com/wildland-game",
        website: nil,
    ),
    Project(
        name: "Personal Tool",
        description:
            "My own Closed-Source & Private Tool for Productivity & Fun!!!",
        image: "/assets/wildland.png",
        github: nil,
        website: "https://www.youtube.com/watch?v=nxIf2kuShtY",
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
                    HyperLink(attributes: { ["href": "/stats", "className": "social-link"] }) {
                        Text({ "Stats" })
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
    func render() -> AnyElement {
        Div(attributes: { ["className": "container"] }) {
            NavBar(showStatsLink: false).render()

            Div(attributes: { ["className": "section"] }) {
                Div(attributes: { ["className": "section-title"] }) {
                    Text({ "Run Stats" })
                }

                Div(attributes: { ["className": "stats-card"] }) {
                    Div(attributes: { ["className": "stats-card-header"] }) {
                        Div(attributes: { ["className": "stats-card-title"] }) {
                            Text({ "Pace & Heart Rate" })
                        }

                        Div(attributes: { ["className": "chart-legend"] }) {
                            Div(attributes: { ["className": "legend-item"] }) {
                                Span(attributes: { ["className": "legend-dot pace"] }) {}
                                Text({ "Pace (km/h)" })
                            }

                            Div(attributes: { ["className": "legend-item"] }) {
                                Span(attributes: { ["className": "legend-dot hr"] }) {}
                                Text({ "Avg HR" })
                            }
                        }
                    }

                    Div(attributes: { ["className": "chart-container"] }) {
                        Div(attributes: { ["id": "run-chart-container", "className": "run-chart"] }) {}
                    }

                    Div(attributes: { ["className": "stats-muted"] }) {
                        Text({
                            "Higher green line means faster pace. White line shows average heart rate over time."
                        })
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
        if path == "/stats" {
            return StatsPage().render()
        }

        return HomePage().render()
    }
}

// MARK: - Mount

let appPath = currentPath()
let renderer = DomRenderer(root: App(path: appPath).render())
renderer.mount()

if appPath == "/stats" {
    mountRunChart()
}
