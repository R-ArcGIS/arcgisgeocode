use std::collections::HashMap;

use extendr_api::prelude::*;
use extendr_api::serializer::to_robj;
use serde_json::{de::from_str, Value};

// Takes a dataframe and creates a hashmap of column names and types
// these are used to match and insert into the elements of a dataframe
fn make_df_type_map(x: &List) -> HashMap<String, Rtype> {
    let mut map = HashMap::new();
    x.iter().for_each(|(key, val)| {
        map.insert(String::from(key), val.rtype());
    });
    map
}

// Function to insert into a data.frame. Requires lots of matching a bit messy
fn insert_into_df(x: &mut List, key: &str, rtype: &Rtype, val: Value, i: usize) {
    match rtype {
        Rtype::Logicals => {
            let col = x.dollar(key).unwrap();
            let mut col_to_insert = Logicals::try_from(col).unwrap();
            let _ = col_to_insert.set_elt(i, Rbool::from(val.as_bool()));
        }
        Rtype::Integers => {
            let col = x.dollar(key).unwrap();
            let mut col_to_insert = Integers::try_from(col).unwrap();
            let to_insert = match val.as_i64() {
                Some(v) => Rint::from(v as i32),
                None => Rint::na(),
            };
            let _ = col_to_insert.set_elt(i, to_insert);
        }
        Rtype::Doubles => {
            let col = x.dollar(key).unwrap();
            let mut col_to_insert = Doubles::try_from(col).unwrap();
            let _ = col_to_insert.set_elt(i, Rfloat::from(val.as_f64()));
        }
        Rtype::Strings => {
            let col = x.dollar(key).unwrap();
            let mut col_to_insert = Strings::try_from(col).unwrap();
            let to_insert = match val.as_str() {
                Some(v) => Rstr::from(v),
                None => Rstr::na(),
            };

            let _ = col_to_insert.set_elt(i, to_insert);
        }
        _ => unimplemented!(),
    };
}

// Takes a data.frame (list) that is modified by reference
// it must be completely pre-allocated otherwise a panic occurs
#[extendr]
fn parse_custom_location_json_(x: &str, to_fill: List) -> Robj {
    let col_maps = make_df_type_map(&to_fill);
    let mut to_fill = to_fill;

    let mut res: Value = from_str(x).unwrap();
    let res = res.as_object_mut();
    let locs = res.filter(|xi| xi.contains_key("locations"));

    // create bindings to set from inside the scope of the iterator
    let mut res_locs = ().into_robj();
    let mut res_sr = ().into_robj();
    locs.into_iter().for_each(|li| {
        let sr = li.get("spatialReference");
        res_sr = match to_robj(&sr) {
            Ok(r) => r,
            Err(_) => ().into_robj(),
        };

        let r = li
            .get("locations")
            .unwrap()
            .as_array()
            .unwrap()
            .into_iter()
            .enumerate()
            .map(|(i, loc)| {
                let _r = loc
                    .get("attributes")
                    .unwrap()
                    .as_object()
                    .into_iter()
                    .for_each(|lli| {
                        lli.into_iter().for_each(|li| {
                            // FIXME this should not be cloned!!!
                            let key = li.0.as_str();
                            let val = li.1.clone();
                            // if this is None then we have an unexpected value
                            // it is skipped
                            let ctype = col_maps.get(key);
                            match ctype {
                                Some(c) => {
                                    let _inserted = insert_into_df(&mut to_fill, key, c, val, i);
                                }
                                None => (),
                            };
                        });
                    });

                let location_field = loc.get("location");

                match location_field {
                    Some(lf) => match lf.as_object() {
                        Some(l) => {
                            let xi = Rfloat::from(l.get("x").unwrap().as_f64());
                            let yi = Rfloat::from(l.get("y").unwrap().as_f64());
                            Doubles::from_values([xi, yi])
                                .into_robj()
                                .set_class(&["XY", "POINT", "sfg"])
                                .unwrap()
                                .to_owned()
                        }
                        None => Doubles::from_values([Rfloat::na(), Rfloat::na()])
                            .into_robj()
                            .set_class(&["XY", "POINT", "sfg"])
                            .unwrap()
                            .to_owned(),
                    },
                    None => Doubles::from_values([Rfloat::na(), Rfloat::na()])
                        .into_robj()
                        .set_class(&["XY", "POINT", "sfg"])
                        .unwrap()
                        .to_owned(),
                }
            })
            .collect::<List>();
        res_locs = r.into();
    });
    list!(attributes = to_fill, locations = res_locs, sr = res_sr).into()
}

extendr_module! {
    mod parse_custom_attrs;
    fn parse_custom_location_json_;
}
