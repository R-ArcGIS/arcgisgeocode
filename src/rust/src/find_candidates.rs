use extendr_api::prelude::*;

use serde::{Serialize, Deserialize};
use serde_esri::{
    geometry::EsriPoint, 
    spatial_reference::SpatialReference
};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FindCandidatesResponse {
    pub spatial_reference: SpatialReference,
    pub candidates: Vec<Candidate>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Candidate {
    pub address: Option<String>,
    pub location: EsriPoint,
    pub score: f64,
    pub attributes: Attributes,
    pub extent: Extent,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Attributes {
    #[serde(rename = "Loc_name")]
    pub loc_name: Option<String>,
    #[serde(rename = "Status")]
    pub status: Option<String>,
    #[serde(rename = "Score")]
    pub score: Option<i64>,
    #[serde(rename = "Match_addr")]
    pub match_addr: Option<String>,
    #[serde(rename = "LongLabel")]
    pub long_label: Option<String>,
    #[serde(rename = "ShortLabel")]
    pub short_label: Option<String>,
    #[serde(rename = "Addr_type")]
    pub addr_type: Option<String>,
    #[serde(rename = "Type")]
    pub type_field: Option<String>,
    #[serde(rename = "PlaceName")]
    pub place_name: Option<String>,
    #[serde(rename = "Place_addr")]
    pub place_addr: Option<String>,
    #[serde(rename = "Phone")]
    pub phone: Option<String>,
    #[serde(rename = "URL")]
    pub url: Option<String>,
    #[serde(rename = "Rank")]
    pub rank: Option<i32>,
    #[serde(rename = "AddBldg")]
    pub add_bldg: Option<String>,
    #[serde(rename = "AddNum")]
    pub add_num: Option<String>,
    #[serde(rename = "AddNumFrom")]
    pub add_num_from: Option<String>,
    #[serde(rename = "AddNumTo")]
    pub add_num_to: Option<String>,
    #[serde(rename = "AddRange")]
    pub add_range: Option<String>,
    #[serde(rename = "Side")]
    pub side: Option<String>,
    #[serde(rename = "StPreDir")]
    pub st_pre_dir: Option<String>,
    #[serde(rename = "StPreType")]
    pub st_pre_type: Option<String>,
    #[serde(rename = "StName")]
    pub st_name: Option<String>,
    #[serde(rename = "StType")]
    pub st_type: Option<String>,
    #[serde(rename = "StDir")]
    pub st_dir: Option<String>,
    #[serde(rename = "BldgType")]
    pub bldg_type: Option<String>,
    #[serde(rename = "BldgName")]
    pub bldg_name: Option<String>,
    #[serde(rename = "LevelType")]
    pub level_type: Option<String>,
    #[serde(rename = "LevelName")]
    pub level_name: Option<String>,
    #[serde(rename = "UnitType")]
    pub unit_type: Option<String>,
    #[serde(rename = "UnitName")]
    pub unit_name: Option<String>,
    #[serde(rename = "SubAddr")]
    pub sub_addr: Option<String>,
    #[serde(rename = "StAddr")]
    pub st_addr: Option<String>,
    #[serde(rename = "Block")]
    pub block: Option<String>,
    #[serde(rename = "Sector")]
    pub sector: Option<String>,
    #[serde(rename = "Nbrhd")]
    pub nbrhd: Option<String>,
    #[serde(rename = "District")]
    pub district: Option<String>,
    #[serde(rename = "City")]
    pub city: Option<String>,
    #[serde(rename = "MetroArea")]
    pub metro_area: Option<String>,
    #[serde(rename = "Subregion")]
    pub subregion: Option<String>,
    #[serde(rename = "Region")]
    pub region: Option<String>,
    #[serde(rename = "RegionAbbr")]
    pub region_abbr: Option<String>,
    #[serde(rename = "Territory")]
    pub territory: Option<String>,
    #[serde(rename = "Zone")]
    pub zone: Option<String>,
    #[serde(rename = "Postal")]
    pub postal: Option<String>,
    #[serde(rename = "PostalExt")]
    pub postal_ext: Option<String>,
    #[serde(rename = "Country")]
    pub country: Option<String>,
    #[serde(rename = "CntryName")]
    pub cntry_name: Option<String>,
    #[serde(rename = "LangCode")]
    pub lang_code: Option<String>,
    #[serde(rename = "Distance")]
    pub distance: Option<i64>,
    #[serde(rename = "X")]
    pub x: Option<f64>,
    #[serde(rename = "Y")]
    pub y: Option<f64>,
    #[serde(rename = "DisplayX")]
    pub display_x: Option<f64>,
    #[serde(rename = "DisplayY")]
    pub display_y: Option<f64>,
    #[serde(rename = "Xmin")]
    pub xmin: Option<f64>,
    #[serde(rename = "Xmax")]
    pub xmax: Option<f64>,
    #[serde(rename = "Ymin")]
    pub ymin: Option<f64>,
    #[serde(rename = "Ymax")]
    pub ymax: Option<f64>,
    #[serde(rename = "ExInfo")]
    pub ex_info: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Extent {
    pub xmin: f64,
    pub ymin: f64,
    pub xmax: f64,
    pub ymax: f64,
}

#[extendr]
pub fn parse_candidate_json(x: &str) -> Robj {
    let parsed = serde_json::from_str::<FindCandidatesResponse>(x);

    match parsed {
        Ok(parsed) => {
            let l = extendr_api::serializer::to_robj(&parsed);
            match l {
                Ok(l) => l,
                Err(_) => {
                    ().into_robj()
                }
            }
        },
        Err(_) => {
            ().into_robj()
        }
    }
}

extendr_module! {
    mod find_candidates;
    fn parse_candidate_json;
}