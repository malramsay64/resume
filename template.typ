#import "utils.typ"
#import "@preview/fontawesome:0.4.0" as fa

/* Styles */

#let accentColor = luma(80)

#let headerInfoStyle(str) = {text(
    size: 10pt,
    fill: accentColor,
    str
)}

#let headerQuoteStyle(str) = {text(
    size: 10pt,
    weight: "medium",
    style: "italic",
    fill: accentColor,
    str
)}

#let sectionTitleStyle(str, color:black) = {text(
    size: 16pt, 
    weight: "bold", 
    fill: color,
    str
)}

#let entryA1Style(str) = {text(
    size: 10pt,
    weight: "bold",
    str
)}


#let entryA2Style(str) = {text(
    weight: "medium",
    // fill: accentColor,
    style: "oblique",
    str
)}

#let entryB1Style(str) = {text(
    // size: 10pt,
    fill: accentColor,
    weight: "medium",
    str
)}

#let entryB2Style(str) = {text(
    size: 9pt,
    weight: "medium",
    fill: luma(80),
    style: "oblique",
    str
)}

// set rules
#let setrules(uservars, doc) = {
    set text(
        font: uservars.bodyfont,
        weight: "regular",
        size: uservars.fontsize,
    )

    set align(left)

    set page(
        paper: "a4",
        margin: (
          left: 1.8cm,
          right: 1.8cm,
          top: 1.5cm,
          bottom: 1.8cm,
        ),
    )    

    set list(
        spacing: uservars.linespacing
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

// show rules
#let showrules(uservars, doc) = {
    show heading.where(level: 1): set text(font: uservars.headingfont, size: 32pt)
    show heading.where(level: 2): title => pad(bottom: 0.2em, grid(
        columns: 2,
        gutter: 1%,
        sectionTitleStyle()[#title],
        line(
            start: (0pt, 0.95em),
            length: 100%,
            stroke: (paint: accentColor, thickness: 0.05em),
        ),
    ))

    doc
}

// set page layout
#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)

    doc
}

// address
// TODO
#let addresstext(info, uservars) = {
    if uservars.showAddress {
        block(width: 100%)[
            #info.personal.location.at("city", default: ""), 
            #info.personal.location.at("region", default: ""), 
            #info.personal.location.country #info.personal.location.at("postalCode", default: "")
            #v(-4pt)
        ]
    } else {none}
}

#let contacttext(info, uservars) = block(width: 100%)[
    #let contact_display(icon, url, display: none) = {
        let l = if display == none {
            link(url)
        } else {
            link(url)[#display]
        }
        box([#icon #sym.zws #l])
    }
    #let profiles = (
        contact_display(fa.fa-envelope(solid: true), "mailto:" + info.personal.email), 
    )
    #if uservars.showNumber {
        profiles.push(contact_display(fa.fa-phone(), "tel:" + info.personal.phone))
    }
    #if "url" in info.personal {
        profiles.push(contact_display(fa.fa-home(), info.personal.url, display: info.personal.url.trim("https://", at: start)))
    }

    #if info.personal.profiles.len() > 0 {
        for profile in info.personal.profiles {
            let icon = if lower(profile.network) == "linkedin" {
                fa.fa-linkedin()                
            } else if lower(profile.network) == "github" {
                fa.fa-github()
            // TODO: Extend the number of networks with icons
            } else {
                // fa.fa-circle()
            }
            profiles.push(contact_display(icon, profile.url, display: profile.username))
        }
    }

    #headerInfoStyle(profiles.join([ #sym.bar.v ]))

    #headerQuoteStyle(eval(info.personal.summary, mode: "markup"))
]

#let styleLabel(str) = {
    text(
        size: 20pt,
        str
    )
}

#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.name
        #if "label" in info.personal {
            styleLabel(info.personal.label)
        }
        #addresstext(info, uservars)
        #contacttext(info, uservars)
    ]
}

#let entryHeading(posA1: none, url: none, posA2: none, posB1: none, dateStart: none, dateEnd: none) = {
    let date = if dateStart == none {
        utils.strpdate(dateEnd)
    } else if dateEnd == none {
        utils.strpdate(dateStart)
    } else {
        let start = utils.strpdate(dateStart)
        let end = utils.strpdate(dateEnd)
        [#start #sym.dash.en #end]
    }
    // parse ISO date strings into datetime objects
    [
        // line 1: company and location
        #if url != none [
            #entryA1Style(link(url, posA1)) #h(1fr) #entryA2Style(posA2)\
        ] else [
            #entryA1Style(posA1) #h(1fr) #entryA2Style(posA2)\
        ]
        #entryB1Style(posB1) #h(1fr) #entryB2Style(date) \
    ]
}

#let cvwork(info, isbreakable: true) = {
    let work = utils
        .filter_visible(info, "work")
        .map(utils.validate_work_instance)
        .sorted(key: i => i.positions.at(0).endDate)
        .rev()
    if work.len() > 0 [
        == Work Experience
        #for w in work {
            // create a block layout for each work entry
            for (index, p) in w.positions.enumerate() {
                block(width: 100%, breakable: isbreakable)[
                    #if index == 0 {
                        entryHeading(posA1: w.organization, url: w.url, posA2: w.location, posB1: p.position, dateStart: p.startDate, dateEnd: p.endDate)
                    } else {
                        entryHeading(posB1: p.position, dateStart: p.startDate, dateEnd: p.endDate)
                    }
                    // highlights or description
                    #if p.summary != none [
                        #eval(p.summary, mode: "markup")
                    ]
                    #for hi in p.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                ]
            }
        }
    ]
}

#let cveducation(info, isbreakable: true) = {
    let education = utils
        .filter_visible(info, "education")
        .sorted(key: i => i.endDate)
        .rev()
    if education.len() > 0 [
        == Education
        #for edu in education {
            let edu-items = ""
            if edu.at("honors", default: none) != none {edu-items = edu-items + "- *Honors*: " + edu.honors.join(", ") + "\n"}
            if edu.at("courses", default: none) != none {edu-items = edu-items + "- *Courses*: " + edu.courses.join(", ") + "\n"}
            if edu.at("highlights", default: none) != none {
                for hi in edu.highlights {
                    edu-items = edu-items + "- " + hi + "\n"
                }
                edu-items = edu-items.trim("\n")
            }

            // create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                #entryHeading(
                    posA1: edu.institution, 
                    url: edu.url, 
                    posA2: edu.location, 
                    posB1: [#edu.studyType in #edu.area], 
                    dateStart: edu.startDate, 
                    dateEnd: edu.endDate
                )
                #eval(edu.summary, mode: "markup")
                #eval(edu-items, mode: "markup")
            ]
        }
    ]
}

#let cvaffiliations(info, isbreakable: true) = {
    if "affiliations" in info and info.affiliations != none [
        == Leadership & Activities
        #for org in info.affiliations {
            // create a block layout for each affiliation entry
            block(width: 100%, breakable: isbreakable)[
                #entryHeading(
                    posA1: org.organization, 
                    url: org.url, 
                    posA2: org.location, 
                    posB1: org.position, 
                    dateStart: org.startDate, 
                    dateEnd: org.endDate
                )
                // highlights or description
                #if org.highlights != none {
                    for hi in org.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]
}

#let cvprojects(info, isbreakable: true) = {
    let projects = utils
        .filter_visible(info, "projects")
        .sorted(key: i => i.endDate)
        .rev()
    if projects.len() > 0 [
        == Projects
        #for project in projects {
            // create a block layout for each project entry
            block(width: 100%, breakable: isbreakable)[
                #entryHeading(
                    posA1: project.name, 
                    url: project.at("url", default: none), 
                    posB1: project.affiliation, 
                    dateStart: project.startDate, 
                    dateEnd: project.endDate
                )
                // summary or description
                #eval(project.summary, mode: "markup")
                #for hi in project.highlights [
                    - #eval(hi, mode: "markup")
                ]
                // Project tools and technologies
                #if "skills" in project and project.skills.len() > 0 [
                    // Ensure the skills look attached to the project
                    #v(-0.5em)
                    *Skills*: #project.skills.join(", ")
                ]
            ]
        }
    ]
}

#let cvawards(info, isbreakable: true) = {
    let awards = utils
        .filter_visible(info, "awards")
        .sorted(key: i => i.date)
        .rev()
    if awards.len() > 0 [
        == Honors & Awards
        #for award in awards {
            // create a block layout for each award entry
            block(width: 100%, breakable: isbreakable)[
                #entryHeading(
                    posA1: award.title, 
                    url: award.at("url", default: none), 
                    posA2: award.location,
                    posB1: [Issued by #text(style: "italic")[#award.issuer]], 
                    dateStart: award.date,
                )
                // summary or description
                #eval(award.summary, mode: "markup")
                #if award.at("highlights", default: none) != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]
}

#let cvcertificates(info, isbreakable: true) = {
    if "certificates" in info and info.certificates != none [
        == Licenses & Certifications

        #for cert in info.certificates {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(cert.date)
            // create a block layout for each certificate entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: certificate name
                #if cert.at("url", default: none) != none [
                    *#link(cert.url)[#cert.name]* \
                ] else [
                    *#cert.name* \
                ]
                // line 2: issuer and date
                Issued by #text(style: "italic")[#cert.issuer]  #h(1fr) #date \
            ]
        }
    ]
}

#let cvpresentations(info, isbreakable: true) = {
    let presentations = utils
        .filter_visible(info, "presentations")
        .sorted(key: i => i.date)
        .rev()
    if presentations.len() > 0 [
        == Presentations
        #for pres in presentations {
            // create a block layout for each publication entry
            block(width: 100%, breakable: isbreakable)[
                #entryHeading(
                    posA1: pres.conference, 
                    url: pres.at("url", default: none), 
                    posA2: pres.location, 
                    posB1: pres.title,
                    dateEnd: pres.date
                )
                #eval(pres.summary, mode: "markup")
            ]
        }
    ]
}

#let cvpublications(info, isbreakable: true) = {
    let publications = utils
        .filter_visible(info, "publications")
        .sorted(key: i => i.releaseDate)
        .rev()
    if publications.len() > 0 [
        == Publications
        #for pub in info.publications {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(pub.releaseDate)
            // create a block layout for each publication entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: publication title
                #if pub.at("url", default: none) != none [
                    *#link(pub.url)[#pub.name]* \
                ] else [
                    *#pub.name* \
                ]
                // line 2: publisher and date
                Published in #text(style: "italic")[#pub.publisher]  #h(1fr) #date \
            ]
        }
    ]
}

#let cvskills(info, isbreakable: true) = {
    let title = ()
    if "languages" in info {
        title.push("Languages")
    }
    if "skills" in info {
        title.push("Skills")
    }
    if "interests" in info {
        title.push("Interests")
    }
    
    if title.len() > 0 {block(breakable: isbreakable)[
        == #title.join(", ")
        #if ("languages" in info and info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if ("skills" in info and info.skills != none) {
            grid(
                columns: 2,
                gutter: 10pt,
                ..info.skills.map(s => {
                    (align(right)[*#s.category*], align(left)[#s.skills.join(", ")])
                }).flatten()
            )
        }
        #if ("interests" in info and info.interests != none) [
            - *Interests*: #info.interests.join(", ")
        ]
    ]}
}

#let cvreferences(info, isbreakable: true) = {
    if "references" in info and info.references != none {block[
        == References
        #for ref in info.references {
            block(width: 100%, breakable: isbreakable)[
                #if ref.at("url", default: none) != none [
                    - *#link(ref.url)[#ref.name]*: "#ref.reference"
                ] else [
                    - *#ref.name*: "#ref.reference"
                ]
            ]
        }
    ]} else {}
}

#let endnote() = {
}
