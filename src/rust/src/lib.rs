use extendr_api::prelude::*;
use rust_iso3166::CountryCode;
use serde::{Deserialize, Serialize};


use extendr_api::deserializer::from_robj;
use serde_esri::geometry::EsriPoint;
use serde_esri::spatial_reference::SpatialReference;

fn parse_sr(sr: Robj) -> Option<SpatialReference> {
    let sr: Result<SpatialReference> = from_robj(&sr);
    sr.ok()
}

#[extendr]
fn sfc_point_to_esri_point(pnts: List, sr: Robj) {
    let sr = parse_sr(sr);

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
                    spatialReference: sr.clone(),
                };
                Some(pnt)
            }
        })
        .collect::<Vec<_>>();

    rprintln!("{:#?}", esri_pnts);
}


extendr_module! {
    mod arcgeocode;
    fn sfc_point_to_esri_point;
}

// I think it might be good to make each of the
// Endpoints a trait that can be called on objects?
// Well...at least reverse GeoCode should be?

trait ReverseGeocode {
    fn reverse_geocode(
        &self,
        out_sr: Option<SpatialReference>,
        lang_code: Option<CountryCode>,
        // cannot store the results unless true, default is false
        // there are contractual obligations here
        for_storage: Option<bool>,
         // can be multiple comma separated values
        feature_type: Option<Vec<FeatureType>>,
        location_type: Option<LocationType>,
        preferred_label_values: Option<PreferredLabelValues>,
    );
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
    Locality
}

// Expected Response from the /reverseGeocode Endpoint
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReverseGeocodeResponse {
    pub address: Address,
    pub location: EsriPoint,
}

#[derive(Default, Debug, Clone, Serialize, Deserialize)]
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