use extendr_api::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize, IntoDataFrameRow)]
#[serde(rename_all = "camelCase")]
pub struct Suggestion {
    pub text: String,
    pub magic_key: String,
    pub is_collection: bool,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Suggestions {
    pub suggestions: Vec<Suggestion>,
}

#[extendr]
pub fn parse_suggestions(x: &str) -> Robj {
    let sugg = serde_json::from_str::<Suggestions>(x);
    match sugg {
        Ok(s) => Dataframe::try_from_values(s.suggestions).unwrap().as_robj().clone(),
        Err(_) => Dataframe::try_from_values(Suggestions::default().suggestions).unwrap().as_robj().clone(),
    }
}

extendr_module! {
    mod suggest;
    fn parse_suggestions;
}
