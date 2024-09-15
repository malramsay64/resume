#import "template.typ": *

#let cvdata = toml("resume.toml")

#let uservars = (
    headingfont: "Roboto",
    bodyfont: "Open Sans",
    fontsize: 10pt, // 10pt, 11pt, 12pt
    awesomeColor: "concrete",
    linespacing: 6pt,
    showAddress: false, // true/false show address in contact info
    showNumber: true,  // true/false show phone number in contact info
    headingsmallcaps: false
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // add custom document style rules here
//
//      doc
// }

#let customrules(doc) = {
    // add custom document style rules here
    set page(
        paper: "a4", // a4, us-letter
        numbering: "1 / 1",
        number-align: right, // left, center, right
    )

    doc
}

#let cvinit(doc) = {
    doc = setrules(uservars, doc)
    doc = showrules(uservars, doc)
    doc = customrules(doc)

    doc
}

// each section body can be overridden by re-declaring it here
// #let cveducation = []

// ========================================================================== //

#show: doc => cvinit(doc)

#set page(
    footer: text(size: 9pt, fill: luma(80))[#cvdata.personal.name #h(1fr) #counter(page).display("1 / 1", both: true)]
)

#cvheading(cvdata, uservars)
#cvwork(cvdata, isbreakable: false)
#cveducation(cvdata, isbreakable: false)
#cvprojects(cvdata, isbreakable: false)
// #cvaffiliations(cvdata)
// #cvawards(cvdata)
// #cvcertificates(cvdata)
#cvpresentations(cvdata, isbreakable: false)
#cvpublications(cvdata)
// #cvskills(cvdata, isbreakable: false)
// #cvreferences(cvdata)
#endnote()
