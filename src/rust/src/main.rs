use serde_json::from_str;
use serde_esri::geometry::EsriPoint;
use serde::{Deserialize, Serialize};

const JSON: &str = r#"{"address":{"Match_addr":"92373, Redlands, California","LongLabel":"92373, Redlands, CA, USA","ShortLabel":"92373","Addr_type":"Postal","Type":"","PlaceName":"92373","AddNum":"","Address":"","Block":"","Sector":"","Neighborhood":"","District":"","City":"Redlands","MetroArea":"","Subregion":"San Bernardino County","Region":"California","RegionAbbr":"CA","Territory":"","Postal":"92373","PostalExt":"","CntryName":"United States","CountryCode":"USA"},"location":{"x":-117.205525,"y":34.038232,"spatialReference":{"wkid":4326,"latestWkid":4326}}}"#;


use tokio::runtime::Runtime;
fn main() {

    let rt = Runtime::new().unwrap();
    
    let n = 5;
    let mut tasks = Vec::with_capacity(n);

    for _ in 0..5 {
        tasks.push(rt.spawn(fake_json()));
    }

    let mut outputs = Vec::with_capacity(tasks.len());
    for task in tasks {
        outputs.push(rt.block_on(task).unwrap());
    }


    println!("{:#?}", outputs);
    // let res: Result<ReverseGeocodeResponse, _> = from_str(JSON);
    // println!("{:#?}", res);
}


async fn fake_json() -> Result<ReverseGeocodeResponse, serde_json::Error> {
    let res: Result<ReverseGeocodeResponse, _> = from_str(JSON);
    res

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