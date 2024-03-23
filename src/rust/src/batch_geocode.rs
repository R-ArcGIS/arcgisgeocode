use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};
use serde_esri::geometry::EsriPoint;

use crate::parse_sr;

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Address {
    objectid: i32,
    #[serde(rename = "singleLine")]
    single_line: Option<String>,
    address: Option<String>,
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

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Record {
    attributes: Address,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Records {
    records: Vec<Record>,
}

#[extendr]
pub fn create_records(
    single_line: Nullable<Strings>,
    address: Nullable<Strings>,
    address2: Nullable<Strings>,
    address3: Nullable<Strings>,
    neighborhood: Nullable<Strings>,
    city: Nullable<Strings>,
    subregion: Nullable<Strings>,
    region: Nullable<Strings>,
    postal: Nullable<Strings>,
    postal_ext: Nullable<Strings>,
    country_code: Nullable<Strings>,
    location: Nullable<List>,
    sr: Robj,
    n: i32,
) -> String {
    let n = n as usize;
    let spatial_ref = parse_sr(sr).unwrap();
    let mut record_vec: Vec<Record> = Vec::with_capacity(n);

    for i in 0..n {
        let single = match single_line {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let addr = match address {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let addr2 = match address2 {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let addr3 = match address3 {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let nbh = match neighborhood {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let cty = match city {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let sub = match subregion {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let reg = match region {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let post = match postal {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let postx = match postal_ext {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let cc = match country_code {
            NotNull(ref a) => {
                let s = a.elt(i);
                Some(s.to_string())
            }
            Null => None,
        };

        let loc = match location {
            NotNull(ref a) => {
                let loc = Doubles::try_from(a.elt(i).unwrap()).unwrap();
                let p = EsriPoint {
                    x: loc[0].inner(),
                    y: loc[1].inner(),
                    z: None,
                    m: None,
                    spatialReference: Some(spatial_ref.clone()),
                };

                Some(p)
            }
            Null => None,
        };

        let record = Address {
            objectid: (i as i32) + 1_i32,
            single_line: single,
            address: addr,
            address2: addr2,
            address3: addr3,
            neighborhood: nbh,
            city: cty,
            subregion: sub,
            region: reg,
            postal: post,
            postal_ext: postx,
            country_code: cc,
            location: loc,
        };

        // push record into vec
        record_vec.push(Record { attributes: record });
    }

    let recs = Records {
        records: record_vec,
    };

    serde_json::to_string(&recs).unwrap()
}

extendr_module! {
    mod batch_geocode;
    fn create_records;
}
