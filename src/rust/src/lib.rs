use extendr_api::prelude::*;
// use rust_iso3166::CountryCode;
// use serde::{Deserialize, Serialize};

use serde_json::to_string;
// use tokio::runtime::Runtime;
use extendr_api::deserializer::from_robj;
use extendr_api::serializer::to_robj;

use reqwest::Url;
use serde_esri::geometry::EsriPoint;
use serde_esri::spatial_reference::SpatialReference;

fn parse_sr(sr: Robj) -> Option<SpatialReference> {
    let sr: Result<SpatialReference> = from_robj(&sr);
    sr.ok()
}

mod reverse;
use crate::reverse::*;
use std::sync::Arc;

fn sfc_point_to_esri_point(pnts: List, sr: SpatialReference) -> Vec<Option<EsriPoint>> {
    let sr = Arc::new(sr);

    if !pnts.inherits("sfc_POINT") {
        throw_r_error("Expected `sfc_POINT`")
    }

    let esri_pnts = pnts
        .into_iter()
        .map(|(_, pi)| {
            let crds = Doubles::try_from(pi).unwrap();

            if crds.len() < 2 {
                None
            } else {
                let pnt = EsriPoint {
                    x: crds[0].inner(),
                    y: crds[1].inner(),
                    z: None,
                    m: None,
                    spatialReference: Some(sr.as_ref().clone()),
                };
                Some(pnt)
            }
        })
        .collect::<Vec<_>>();

    // rprintln!("{:#?}", esri_pnts);
    esri_pnts
}

use std::collections::HashMap;

#[extendr]
fn reverse_geocode_rs(
    service_url: &str,
    locations: List,
    crs: Robj,
    lang: Option<&str>,
    for_storage: Option<bool>,
    feature_type: Option<&str>,
    location_type: Option<&str>,
    preferred_label_values: Option<&str>,
   _token: Option<String>,
) -> 
// Strings 
    List
{

    // create a url
    let _service_url = Url::parse(service_url).unwrap();

    // extract spatial reference
    let sr = Arc::new(parse_sr(crs).unwrap());

    let ftype = feature_type.map_or(None, |f| match f {
        "StreetInt" => Some(FeatureType::StreetInt),
        "DistanceMarker" => Some(FeatureType::DistanceMarker),
        "StreetAddress" => Some(FeatureType::StreetAddress),
        "StreetName" => Some(FeatureType::StreetName),
        "POI" => Some(FeatureType::POI),
        "Subaddress" => Some(FeatureType::Subaddress),
        "PointAddress" => Some(FeatureType::PointAddress),
        "Postal" => Some(FeatureType::Postal),
        "Locality" => Some(FeatureType::Locality),
        _ => None,
    });

    let ltype = location_type.map_or(None, |l| match l {
        "Rooftop" => Some(LocationType::Rooftop),
        "Street" => Some(LocationType::Street),
        _ => None,
    });

    let pref_lab_vals = preferred_label_values.map_or(None, |p| match p {
        "PostalCity" => Some(PreferredLabelValues::PostalCity),
        "LocalCity" => Some(PreferredLabelValues::LocalCity),
        _ => None,
    });

    // get the locations as esri points
    let locs = sfc_point_to_esri_point(locations, sr.as_ref().clone());

    // allocate params vec
    // let mut params = Vec::with_capacity(locs.len());

    let mut res_list = List::new(locs.len());

    // fill in the params vec
    for (i, loc) in locs.into_iter().enumerate() {
        let param = ReverseGeocodeParams {
            location: loc.unwrap(),
            out_sr: sr.as_ref().clone(),
            lang_code: lang.map_or(None, |l| Some(String::from(l))),
            for_storage: for_storage,
            feature_types: ftype.clone(),
            location_type: ltype.clone(),
            preferred_label_values: pref_lab_vals.clone(),
        };

        let hm = param.as_form_body();
        let hm2 = hm.into_iter().map(|(k, v)| (k, v.into())).collect::<HashMap<&str, Robj>>();
        let _ = res_list.set_elt(i, List::from_hashmap(hm2).into());
        // params.push(param);
    }
    res_list
    // // create new runtime
    // let rt = Runtime::new().unwrap();

    // // run the reverse geocode in parallel
    // let res = rt.block_on(
    //     reverse_geocode_(service_url, params, token)
    // );

    // // print the result
    // // println!("{:?}", res);
    // res.into_iter().map(|r| {
    //     let rr = r.unwrap();
    //     let json = serde_json::to_string(&rr).unwrap();
    //     json
    // })
    // .collect::<Strings>()
}

// convert an EsriPoint to an sfg
fn as_sfg(x: EsriPoint) -> Robj {
    let coord = Doubles::from_values([x.x, x.y]);
    coord
        .into_robj()
        .set_class(&["XY", "POINT", "sfg"])
        .unwrap()
}

#[extendr]
fn as_esri_point_json(x: List, sr: Robj) -> Strings {
    let res = sfc_point_to_esri_point(x, parse_sr(sr).unwrap());
    res
        .into_iter()
        .map(|pi| {
            match pi {
                Some(p) => {
                    let json = to_string(&p).unwrap();
                    Rstr::from_string(&json)
                }
                None => {
                    Rstr::na()
                }
            }    
        })
        .collect::<Strings>()
}

#[extendr]
fn parse_rev_geocode_resp(resps: Strings) -> List {
    let mut res_geo = List::new(resps.len());

    let res_attrs = resps 
        .into_iter()
        .enumerate()
        .map(|(i, ri)| {
            let resp  = serde_json::from_str::<ReverseGeocodeResponse>(ri.as_str()).unwrap();
            let res = to_robj(&resp.address).unwrap().as_list().unwrap(); 
            let _ = res_geo.set_elt(i, as_sfg(resp.location));

            res
        }).collect::<List>().into();

    List::from_names_and_values(
        &["attributes", "geometry"], 
        [res_attrs, res_geo]
    ).unwrap()
}


#[extendr]
/// @export
fn is_iso3166(code: &str) -> bool {
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
    mod arcgeocode;
    fn as_esri_point_json;
    fn reverse_geocode_rs;
    fn parse_rev_geocode_resp;
    fn is_iso3166;
    fn iso_3166_2;
    fn iso_3166_3;
    fn iso_3166_names;
}
