use std::collections::HashMap;

use extendr_api::prelude::*;
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

#[extendr]
fn parse_any_json(x: &str, to_fill: List) {
    let col_maps = make_df_type_map(&to_fill);
    let mut to_fill = to_fill;

    let mut res: Value = from_str(x).unwrap();
    let res = res.as_object_mut();
    let locs = res.filter(|xi| xi.contains_key("locations"));

    locs.into_iter().for_each(|li| {
        let _ = li
            .get("locations")
            .unwrap()
            .as_array()
            .unwrap()
            .into_iter()
            .enumerate()
            .for_each(|(i, loc)| {
                loc.get("attributes")
                    .unwrap()
                    .as_object()
                    .into_iter()
                    .for_each(|lli| {
                        lli.into_iter().for_each(|li| {
                            // FIXME this should not be cloned!!!
                            let key = li.0.as_str();
                            let val = li.1.clone();
                            println!("{:?}", li);
                            let ctype = col_maps.get(key).unwrap();
                            let _inserted = insert_into_df(&mut to_fill, key, ctype, val, i);
                        });
                    })
            });
    });
}

extendr_module! {
    mod parse_custom_attrs;
    fn parse_any_json;
}
