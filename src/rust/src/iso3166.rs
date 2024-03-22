use extendr_api::prelude::*;


#[extendr]
fn is_iso3166(code: Strings) -> Logicals {
    code
        .into_iter()
        .map(|c| {
            if c.is_na() {
                Rbool::na()
            } else {
                Rbool::from(is_iso3166_scalar(c.as_str()))
            }
        })
        .collect::<Logicals>()
}

fn is_iso3166_scalar(code: &str) -> bool {
    let code = code.to_uppercase();
    //https://developers.arcgis.com/rest/geocode/api-reference/geocode-coverage.htm#GUID-D61FB53E-32DF-4E0E-A1CC-473BA38A23C0
    let non_iso_valid = ["EUR", "NCY", "PLI", "RKS", "SPI"];

    // check these first
    if non_iso_valid.contains(&code.as_str()) {
        return true;
    }

    // check the rest
    let alpha2 = rust_iso3166::from_alpha2(&code);

    if alpha2.is_some() {
        return true
    }

    let alpha3 = rust_iso3166::from_alpha3(&code);

    if alpha3.is_some() {
        return true
    }

    false
}

#[extendr]
fn iso_3166_2() -> Strings {
    let iso = rust_iso3166::ALL;
    iso
        .iter()
        .map(|c| c.alpha2)
        .collect::<Strings>()
}

#[extendr]
fn iso_3166_3() -> Strings {
    let iso = rust_iso3166::ALL;
    iso
        .iter()
        .map(|c| c.alpha3)
        .collect::<Strings>()
}

#[extendr]
fn iso_3166_names() -> Strings {
    let iso = rust_iso3166::ALL;
    iso
        .iter()
        .map(|c| c.name)
        .collect::<Strings>()
}

extendr_module! {
    mod iso3166;
    fn is_iso3166;
    fn iso_3166_2;
    fn iso_3166_3;
    fn iso_3166_names;
}