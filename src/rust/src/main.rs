
mod reverse;
use reverse::*;
use reqwest::{Request, Method, Url, Body, Client};
use tokio::runtime::Runtime;

#[tokio::main]
async fn main() {


    let mut req_params = ReverseGeocodeParams::new(-117.205525, 34.038232);
    let geo_url = Url::parse("https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode").unwrap();
    

    let res = reverse_geocode_(geo_url, vec![req_params; 100], None).await;


}






// const JSON: &str = r#"{"address":{"Match_addr":"92373, Redlands, California","LongLabel":"92373, Redlands, CA, USA","ShortLabel":"92373","Addr_type":"Postal","Type":"","PlaceName":"92373","AddNum":"","Address":"","Block":"","Sector":"","Neighborhood":"","District":"","City":"Redlands","MetroArea":"","Subregion":"San Bernardino County","Region":"California","RegionAbbr":"CA","Territory":"","Postal":"92373","PostalExt":"","CntryName":"United States","CountryCode":"USA"},"location":{"x":-117.205525,"y":34.038232,"spatialReference":{"wkid":4326,"latestWkid":4326}}}"#;
// println!("{:#?}", outputs);
// // let res: Result<ReverseGeocodeResponse, _> = from_str(JSON);
// // println!("{:#?}", res);
// let rt = Runtime::new().unwrap();
    
// let n = 5;
// let mut tasks = Vec::with_capacity(n);

// for _ in 0..5 {
//     tasks.push(rt.spawn(fake_json()));
// }

// let mut outputs = Vec::with_capacity(tasks.len());
// for task in tasks {
//     outputs.push(rt.block_on(task).unwrap());
// }