use crate::as_sfg;
use extendr_api::{prelude::*, Attributes as ExtendrAttr};
use serde::{Deserialize, Serialize};
use serde_esri::{geometry::EsriPoint, spatial_reference::SpatialReference};
use serde_with::{serde_as, NoneAsEmptyString};

#[serde_as]
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FindCandidatesResponse {
    pub spatial_reference: SpatialReference,
    pub candidates: Vec<Candidate>,
}

#[serde_as]
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Candidate {
    pub address: Option<String>,
    pub location: EsriPoint,
    pub score: f64,
    pub attributes: Attributes,
    pub extent: Extent,
}

#[serde_as]
#[derive(Debug, Clone, Serialize, Deserialize, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
pub struct Attributes {
    #[serde(rename = "ResultID")]
    pub result_id: Option<i32>,

    #[serde(rename = "Loc_name")]
    pub loc_name: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Status")]
    pub status: Option<String>,

    #[serde(rename = "Score")]
    pub score: Option<f64>,

    #[serde(rename = "Match_addr")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub match_addr: Option<String>,

    #[serde(rename = "LongLabel")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub long_label: Option<String>,

    #[serde(rename = "ShortLabel")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub short_label: Option<String>,

    #[serde(rename = "Addr_type")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub addr_type: Option<String>,

    #[serde(rename = "Type")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub type_field: Option<String>,

    #[serde(rename = "PlaceName")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub place_name: Option<String>,

    #[serde(rename = "Place_addr")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub place_addr: Option<String>,

    #[serde(rename = "Phone")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub phone: Option<String>,

    #[serde(rename = "URL")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub url: Option<String>,

    #[serde(rename = "Rank")]
    pub rank: Option<f64>,

    #[serde(rename = "AddBldg")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub add_bldg: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "AddNum")]
    pub add_num: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "AddNumFrom")]
    pub add_num_from: Option<String>,

    #[serde(rename = "AddNumTo")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub add_num_to: Option<String>,

    #[serde(rename = "AddRange")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub add_range: Option<String>,

    #[serde(rename = "Side")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub side: Option<String>,

    #[serde(rename = "StPreDir")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_pre_dir: Option<String>,

    #[serde(rename = "StPreType")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_pre_type: Option<String>,

    #[serde(rename = "StName")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_name: Option<String>,

    #[serde(rename = "StType")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_type: Option<String>,

    #[serde(rename = "StDir")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_dir: Option<String>,

    #[serde(rename = "BldgType")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub bldg_type: Option<String>,

    #[serde(rename = "BldgName")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub bldg_name: Option<String>,

    #[serde(rename = "LevelType")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub level_type: Option<String>,

    #[serde(rename = "LevelName")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub level_name: Option<String>,

    #[serde(rename = "UnitType")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub unit_type: Option<String>,

    #[serde(rename = "UnitName")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub unit_name: Option<String>,

    #[serde(rename = "SubAddr")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub sub_addr: Option<String>,

    #[serde(rename = "StAddr")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub st_addr: Option<String>,

    #[serde(rename = "Block")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub block: Option<String>,

    #[serde(rename = "Sector")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub sector: Option<String>,

    #[serde(rename = "Nbrhd")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub nbrhd: Option<String>,

    #[serde(rename = "District")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub district: Option<String>,

    #[serde(rename = "City")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub city: Option<String>,

    #[serde(rename = "MetroArea")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub metro_area: Option<String>,

    #[serde(rename = "Subregion")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub subregion: Option<String>,

    #[serde(rename = "Region")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub region: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "RegionAbbr")]
    pub region_abbr: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Territory")]
    pub territory: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Zone")]
    pub zone: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Postal")]
    pub postal: Option<String>,

    #[serde(rename = "PostalExt")]
    #[serde_as(as = "NoneAsEmptyString")]
    pub postal_ext: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Country")]
    pub country: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "CntryName")]
    pub cntry_name: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "LangCode")]
    pub lang_code: Option<String>,

    #[serde(rename = "Distance")]
    pub distance: Option<f64>,

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
    #[serde_as(as = "NoneAsEmptyString")]
    pub ex_info: Option<String>,
}

#[serde_as]
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
        Ok(p) => {
            let n = p.candidates.len();

            if n == 0 {
                return ().into_robj();
            }
            let mut extent_res = List::new(n);
            let mut location_res = List::new(n);

            let candidate_attrs = p
                .candidates
                .into_iter()
                .enumerate()
                .map(|(i, pi)| {
                    let _ = location_res.set_elt(i, as_sfg(pi.location));

                    let Extent {
                        xmin,
                        ymin,
                        xmax,
                        ymax,
                    } = pi.extent;

                    let extent = Doubles::from_values([xmin, ymin, xmax, ymax])
                        .into_robj()
                        .set_attrib("names", ["xmin", "ymin", "xmax", "ymax"])
                        .unwrap()
                        .to_owned();

                    let _ = extent_res.set_elt(i, extent);

                    pi.attributes
                })
                .collect::<Vec<_>>();

            let res = candidate_attrs.into_dataframe().unwrap();
            let candidate_attrs = res.as_robj().clone();

            list!(
                attributes = candidate_attrs,
                extents = extent_res,
                locations = location_res,
                sr = extendr_api::serializer::to_robj(&p.spatial_reference).unwrap()
            )
            .into_robj()
        }
        Err(_) => {
            // rprintln!("{:?}", e);
            // rprintln!("{x}");
            ().into_robj()
        }
    }
}

extendr_module! {
    mod find_candidates;
    fn parse_candidate_json;
}
