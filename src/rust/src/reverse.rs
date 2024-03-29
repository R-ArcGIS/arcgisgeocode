use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};
use serde_esri::{geometry::EsriPoint, spatial_reference::SpatialReference};

// use reqwest::Url;
// use std::result::Result;
// use std::sync::Arc;

// pub async fn reverse_geocode_(
//     service_url: Url,
//     params: Vec<ReverseGeocodeParams>,
//     token: Option<String>,
// ) -> Vec<Result<ReverseGeocodeResponse, reqwest::Error>> {
//     let url = Arc::new(service_url);
//     let client = reqwest::Client::new();
//     let token = Arc::new(token.unwrap_or("".to_string()));

//     let mut tasks = Vec::with_capacity(params.len());

//     // create a task for each param
//     for param in params {
//         let task = client
//             .clone()
//             .post(url.as_ref().clone())
//             .query(&[("f", "json")])
//             .form(&param.as_form_body())
//             .header("X-Esri-Authorization", token.as_ref().clone())
//             .send();

//         tasks.push(tokio::spawn(task));
//     }

//     // create a vector to store the output
//     let mut outputs = Vec::with_capacity(tasks.len());

//     // capture the output of each task
//     for task in tasks {
//         let task_res = task.await.unwrap();
//         match task_res {
//             Ok(res) => {
//                 let res = res.json::<ReverseGeocodeResponse>().await;
//                 outputs.push(res);
//             }
//             Err(e) => outputs.push(Err(e)),
//         }
//     }

//     outputs
// }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReverseGeocodeParams {
    pub location: EsriPoint,
    #[serde(rename = "outSR")]
    pub out_sr: SpatialReference,
    #[serde(rename = "langCode")]
    pub lang_code: Option<String>,
    #[serde(rename = "forStorage")]
    pub for_storage: Option<bool>,
    #[serde(rename = "featureTypes")]
    pub feature_types: Option<FeatureType>,
    #[serde(rename = "locationType")]
    pub location_type: Option<LocationType>,
    #[serde(rename = "preferredLabelValues")]
    pub preferred_label_values: Option<PreferredLabelValues>,
}

// use serde_json::to_string;
// use std::collections::HashMap;

// impl ReverseGeocodeParams {
//     pub fn as_form_body(self) -> HashMap<&'static str, String> {
//         let mut map = HashMap::new();
//         map.insert("location", to_string(&self.location).unwrap());

//         // insert spatialReference
//         map.insert("outSR", to_string(&self.out_sr).unwrap());

//         // inserts langCode if present
//         self.lang_code
//             .map(|lang_code| map.insert("langCode", to_string(&lang_code).unwrap()));

//         // inserts forStorage if present
//         self.for_storage
//             .map(|for_storage| map.insert("forStorage", to_string(&for_storage).unwrap()));

//         // inserts locationType if present
//         self.location_type
//             .map(|location_type| map.insert("locationType", to_string(&location_type).unwrap()));

//         // inserts preferredLabelValues if present
//         self.preferred_label_values.map(|preferred_label_values| {
//             map.insert(
//                 "preferredLabelValues",
//                 to_string(&preferred_label_values).unwrap(),
//             )
//         });

//         map
//     }

//     pub fn _new(x: f64, y: f64) -> Self {
//         ReverseGeocodeParams {
//             location: EsriPoint {
//                 x,
//                 y,
//                 z: None,
//                 m: None,
//                 spatialReference: None,
//             },
//             out_sr: SpatialReference {
//                 wkid: Some(3857),
//                 latest_wkid: None,
//                 vcs_wkid: None,
//                 latest_vcs_wkid: None,
//                 wkt: None,
//             },
//             lang_code: None,
//             for_storage: None,
//             feature_types: None,
//             location_type: None,
//             preferred_label_values: None,
//         }
//     }
// }

impl Default for ReverseGeocodeParams {
    fn default() -> Self {
        ReverseGeocodeParams {
            location: EsriPoint {
                x: 0.0,
                y: 0.0,
                z: None,
                m: None,
                spatialReference: None,
            },
            out_sr: SpatialReference {
                wkid: Some(4326),
                latest_wkid: None,
                vcs_wkid: None,
                latest_vcs_wkid: None,
                wkt: None,
            },
            lang_code: None,
            for_storage: None,
            feature_types: None,
            location_type: None,
            preferred_label_values: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum LocationType {
    Rooftop,
    Street,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PreferredLabelValues {
    PostalCity,
    LocalCity,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum FeatureType {
    StreetInt,
    DistanceMarker,
    StreetAddress,
    StreetName,
    POI,
    Subaddress,
    PointAddress,
    Postal,
    Locality,
}

// Expected Response from the /reverseGeocode Endpoint
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReverseGeocodeResponse {
    pub address: Address,
    pub location: EsriPoint,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
pub struct Address {
    #[serde(rename = "Match_addr")]
    pub match_addr: String,
    #[serde(rename = "LongLabel")]
    pub long_label: String,
    #[serde(rename = "ShortLabel")]
    pub short_label: String,
    #[serde(rename = "Addr_type")]
    pub addr_type: String,
    #[serde(rename = "Type")]
    pub type_field: String,
    #[serde(rename = "PlaceName")]
    pub place_name: String,
    #[serde(rename = "AddNum")]
    pub add_num: String,
    #[serde(rename = "Address")]
    pub address: String,
    #[serde(rename = "Block")]
    pub block: String,
    #[serde(rename = "Sector")]
    pub sector: String,
    #[serde(rename = "Neighborhood")]
    pub neighborhood: String,
    #[serde(rename = "District")]
    pub district: String,
    #[serde(rename = "City")]
    pub city: String,
    #[serde(rename = "MetroArea")]
    pub metro_area: String,
    #[serde(rename = "Subregion")]
    pub subregion: String,
    #[serde(rename = "Region")]
    pub region: String,
    #[serde(rename = "RegionAbbr")]
    pub region_abbr: String,
    #[serde(rename = "Territory")]
    pub territory: String,
    #[serde(rename = "Postal")]
    pub postal: String,
    #[serde(rename = "PostalExt")]
    pub postal_ext: String,
    #[serde(rename = "CntryName")]
    pub country_name: String,
    #[serde(rename = "CountryCode")]
    pub country_code: String,
}

#[extendr]
pub fn parse_rev_geocode_resp(resps: Strings) -> List {
    let mut res_geo = List::new(resps.len());

    let res_attrs = resps
        .into_iter()
        .enumerate()
        .map(|(i, ri)| {
            let resp = serde_json::from_str::<ReverseGeocodeResponse>(ri.as_str());
            let res = match resp {
                Ok(r) => {
                    // let res = to_robj(&r.address).unwrap().as_list().unwrap();
                    let _ = res_geo.set_elt(i, crate::as_sfg(r.location));
                    vec![r.address].into_dataframe().unwrap().as_robj().clone()
                    // res.into_robj()
                }
                Err(_) => ().into_robj(),
            };
            res
        })
        .collect::<List>()
        .into();

    List::from_names_and_values(&["attributes", "geometry"], [res_attrs, res_geo]).unwrap()
}

extendr_module! {
    mod reverse;
    fn parse_rev_geocode_resp;
}
