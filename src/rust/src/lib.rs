// use extendr_api::prelude::*;
// use rust_iso3166::CountryCode;
// use serde::{Deserialize, Serialize};

// use tokio::runtime::Runtime;
// use extendr_api::deserializer::from_robj;
// use serde_esri::geometry::EsriPoint;
// use serde_esri::spatial_reference::SpatialReference;

// fn parse_sr(sr: Robj) -> Option<SpatialReference> {
//     let sr: Result<SpatialReference, _> = from_robj(&sr);
//     sr.ok()
// }

// #[extendr]
// fn sfc_point_to_esri_point(pnts: List, sr: Robj) {
//     let sr = parse_sr(sr);

//     if !pnts.inherits("sfc_POINT") {
//         throw_r_error("Expected `sfc_POINT`")
//     }

//     let esri_pnts = pnts
//         .into_iter()
//         .map(|(_, pi)| {
//             let crds = Doubles::try_from(pi).unwrap();

//             if crds.len() < 2 {
//                 None
//             } else {
//                 let pnt = EsriPoint {
//                     x: crds[0].inner(),
//                     y: crds[1].inner(),
//                     z: None,
//                     m: None,
//                     spatialReference: sr.clone(),
//                 };
//                 Some(pnt)
//             }
//         })
//         .collect::<Vec<_>>();

//     rprintln!("{:#?}", esri_pnts);
// }


// extendr_module! {
//     mod arcgeocode;
//     fn sfc_point_to_esri_point;
// }
