// Helper Functions
#let monthname(n, display: "short") = {
    n = int(n)
    let month = ""

    if n == 1 { month = "January" }
    else if n == 3 { month = "March" }
    else if n == 2 { month = "February" }
    else if n == 4 { month = "April" }
    else if n == 5 { month = "May" }
    else if n == 6 { month = "June" }
    else if n == 7 { month = "July" }
    else if n == 8 { month = "August" }
    else if n == 9 { month = "September" }
    else if n == 10 { month = "October" }
    else if n == 11 { month = "November" }
    else if n == 12 { month = "December" }
    else { result = none }
    if month != none {
        if display == "short" {
            month = month.slice(0, 3)
        } else {
            month
        }
    }
    month
}

#let strpdate(isodate) = {
    let date = ""
    if lower(isodate) != "present" {
        date = datetime(
            year: int(isodate.slice(0, 4)),
            month: int(isodate.slice(5, 7)),
            day: int(isodate.slice(8, 10))
        )
        date = date.display("[month repr:short]") + " " + date.display("[year repr:full]")
    } else if lower(isodate) == "present" {
        date = "Present"
    }
    return date
}

#let filter_visible(info, section) = {
    if section in info and info.at(section) != none {
        info.at(section).filter(i => i.at("display", default: true))
    } else {
        info.section = []
    }
}

#let validate_work_instance(info) = {
    assert("organization" in info, message: "Work instance: must include the key: organization" + info.keys().join(","))
    let base_msg = "work instance: " + info.organization + "must include the key: "
    if "positions" in info {
        for position in info.positions {
            let base_msg = "work.positions instance: " + info.organization + "must include the key: "
            assert("position" in position, message: base_msg + "position")
            assert("startDate" in position, message: base_msg + "startDate")

            if "endDate" not in position {
                position.endDate = "present"
            }
            if "summary" not in position {
                position.summary = ""
            }
            if "highlights" not in position {
                position.highlights = []
            }

        }
    } else {
        let position = (:)
        assert("position" in info, message: base_msg + "position")
        assert("startDate" in info, message: base_msg + "startDate")
        position.position = info.remove("position")
        position.startDate = info.remove("startDate")

        position.endDate = info.remove("endDate", default: "present")
        position.summary = info.remove("summary", default: "")
        position.highlights = info.remove("highlights", default: [])

        info.positions = (position, )
    }
    info
}
