import SwiftVan

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

// MARK: - App Root

final class App {
    func render() -> AnyElement {
        Div(attributes: { ["className": "container"] }) {
            Header().render()
            SocialsSection().render()
            ProjectsSection().render()
            ContactSection().render()
        }
    }
}

// MARK: - Mount

let renderer = DomRenderer(root: App().render())
renderer.mount()
