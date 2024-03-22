x <- '{
 "spatialReference": {
  "wkid": 4326,
  "latestWkid": 4326
 },
 "candidates": [
  {
   "address": "Starbucks",
   "location": {
    "x": 151.20641,
    "y": -33.8756
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.20141,
    "ymin": -33.8806,
    "xmax": 151.21141,
    "ymax": -33.8706
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.20555,
    "y": -33.86506
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.20055,
    "ymin": -33.87006,
    "xmax": 151.21055,
    "ymax": -33.86006
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.20908,
    "y": -33.87374
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.20408,
    "ymin": -33.87874,
    "xmax": 151.21408,
    "ymax": -33.86874
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.20697,
    "y": -33.87176
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.20197,
    "ymin": -33.87676,
    "xmax": 151.21197,
    "ymax": -33.86676
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.24979,
    "y": -33.89205
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.24479,
    "ymin": -33.89705,
    "xmax": 151.25479,
    "ymax": -33.88705
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.25052,
    "y": -33.89092
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.24552,
    "ymin": -33.89592,
    "xmax": 151.25552,
    "ymax": -33.88592
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.10432,
    "y": -33.87427
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.09932,
    "ymin": -33.87927,
    "xmax": 151.10932,
    "ymax": -33.86927
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.10238,
    "y": -33.87722
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.09738,
    "ymin": -33.88222,
    "xmax": 151.10738,
    "ymax": -33.87222
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.18427,
    "y": -33.79591
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.17927,
    "ymin": -33.80091,
    "xmax": 151.18927,
    "ymax": -33.79091
   }
  },
  {
   "address": "Starbucks",
   "location": {
    "x": 151.19993,
    "y": -33.88424
   },
   "score": 100,
   "attributes": {
    "type": "Coffee Shop",
    "city": "Sydney",
    "region": "New South Wales"
   },
   "extent": {
    "xmin": 151.19493,
    "ymin": -33.88924,
    "xmax": 151.20493,
    "ymax": -33.87924
   }
  }
 ]
}'

str(parse_candidate_json(x), 2)
