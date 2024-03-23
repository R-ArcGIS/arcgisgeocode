use serde::{Deserialize, Serialize};
use serde_esri::geometry::EsriPoint;

#[derive(Debug, Deserialize, Serialize)]
pub struct Address {
    objectid: i32,
    address: String,
    address2: Option<String>,
    address3: Option<String>,
    neighborhood: Option<String>,
    city: Option<String>,
    subregion: Option<String>,
    region: Option<String>,
    postal: Option<String>,
    #[serde(rename = "postalExt")]
    postal_ext: Option<String>,
    #[serde(rename = "countryCode")]
    country_code: Option<String>,
    location: Option<EsriPoint>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Records(Vec<Address>);
