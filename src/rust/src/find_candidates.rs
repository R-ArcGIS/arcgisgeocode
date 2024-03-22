use extendr_api::{prelude::*, Attributes as ExtendrAttr};

use serde::{Deserialize, Serialize};
use serde_esri::{geometry::EsriPoint, spatial_reference::SpatialReference};

use serde_with::{serde_as, NoneAsEmptyString};

use crate::as_sfg;

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
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Attributes {
    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Loc_name")]
    pub loc_name: Option<String>,

    #[serde_as(as = "NoneAsEmptyString")]
    #[serde(rename = "Status")]
    pub status: Option<String>,

    #[serde(rename = "Score")]
    pub score: Option<i32>,

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
    pub rank: Option<i32>,

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
            let mut extent_res = List::new(n);
            let mut location_res = List::new(n);

            let candidate_attrs = p
                .candidates
                .into_iter()
                .enumerate()
                .map(|(i, pi)| {
                    let ri = parse_candidate(pi);
                    let _ = extent_res.set_elt(i, ri.1);
                    let _ = location_res.set_elt(i, ri.2);
                    ri.0
                })
                .collect::<List>();

            list!(
                attributes = candidate_attrs,
                extents = extent_res,
                locations = location_res,
                sr = extendr_api::serializer::to_robj(&p.spatial_reference).unwrap()
            )
            .into_robj()
        }
        Err(_) => ().into_robj(),
    }
}

fn parse_candidate(x: Candidate) -> (Robj, Robj, Robj) {
    let loc = as_sfg(x.location);
    let Extent {
        xmin,
        ymin,
        xmax,
        ymax,
    } = x.extent;

    let extent = Doubles::from_values([xmin, ymin, xmax, ymax])
        .into_robj()
        .set_attrib("names", ["xmin", "ymin", "xmax", "ymax"])
        .unwrap();

    let attrs = x.attributes;

    let attribute_res = list!(
        address = x.address,
        score = x.score,
        loc_name = attrs.loc_name,
        status = attrs.status,
        match_addr = attrs.match_addr,
        long_label = attrs.long_label,
        short_label = attrs.short_label,
        addr_type = attrs.addr_type,
        type_field = attrs.type_field,
        place_name = attrs.place_name,
        place_addr = attrs.place_addr,
        phone = attrs.phone,
        url = attrs.url,
        rank = attrs.rank,
        add_bldg = attrs.add_bldg,
        add_num = attrs.add_num,
        add_num_from = attrs.add_num_from,
        add_num_to = attrs.add_num_to,
        add_range = attrs.add_range,
        side = attrs.side,
        st_pre_dir = attrs.st_pre_dir,
        st_pre_type = attrs.st_pre_type,
        st_name = attrs.st_name,
        st_type = attrs.st_type,
        st_dir = attrs.st_dir,
        bldg_type = attrs.bldg_type,
        bldg_name = attrs.bldg_name,
        level_type = attrs.level_type,
        level_name = attrs.level_name,
        unit_type = attrs.unit_type,
        unit_name = attrs.unit_name,
        sub_addr = attrs.sub_addr,
        st_addr = attrs.st_addr,
        block = attrs.block,
        sector = attrs.sector,
        nbrhd = attrs.nbrhd,
        district = attrs.district,
        city = attrs.city,
        metro_area = attrs.metro_area,
        subregion = attrs.subregion,
        region = attrs.region,
        region_abbr = attrs.region_abbr,
        territory = attrs.territory,
        zone = attrs.zone,
        postal = attrs.postal,
        postal_ext = attrs.postal_ext,
        country = attrs.country,
        cntry_name = attrs.cntry_name,
        lang_code = attrs.lang_code,
        distance = attrs.distance,
        x = attrs.x,
        y = attrs.y,
        display_x = attrs.display_x,
        display_y = attrs.display_y,
        xmin = attrs.xmin,
        xmax = attrs.xmax,
        ymin = attrs.ymin,
        ymax = attrs.ymax,
        ex_info = attrs.ex_info,
    )
    .into_robj();

    (attribute_res, extent, loc)
}

extendr_module! {
    mod find_candidates;
    fn parse_candidate_json;
}
