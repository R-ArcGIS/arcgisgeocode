# geocode_addresses() functions

    Code
      res
    Output
      Simple feature collection with 3 features and 62 fields
      Geometry type: POINT
      Dimension:     XY
      Bounding box:  xmin: -117.1957 ymin: 34.05609 xmax: -117.1957 ymax: 34.05609
      Geodetic CRS:  WGS 84
        result_id loc_name status score match_addr
      3         1    World      T   100       Esri
      2         2    World      M   100       Esri
      1         3    World      M   100       Esri
                                             long_label short_label addr_type
      3 Esri, 380 New York St, Redlands, CA, 92373, USA        Esri       POI
      2 Esri, 380 New York St, Redlands, CA, 92373, USA        Esri       POI
      1 Esri, 380 New York St, Redlands, CA, 92373, USA        Esri       POI
               type_field place_name                                   place_addr
      3 Business Facility       Esri 380 New York St, Redlands, California, 92373
      2 Business Facility       Esri 380 New York St, Redlands, California, 92373
      1 Business Facility       Esri 380 New York St, Redlands, California, 92373
                 phone                 url rank add_bldg add_num add_num_from
      3 (909) 793-2853 http://www.esri.com   10     <NA>     380         <NA>
      2 (909) 793-2853 http://www.esri.com   10     <NA>     380         <NA>
      1 (909) 793-2853 http://www.esri.com   10     <NA>     380         <NA>
        add_num_to add_range side st_pre_dir st_pre_type  st_name st_type st_dir
      3       <NA>      <NA> <NA>       <NA>        <NA> New York      St   <NA>
      2       <NA>      <NA> <NA>       <NA>        <NA> New York      St   <NA>
      1       <NA>      <NA> <NA>       <NA>        <NA> New York      St   <NA>
        bldg_type bldg_name level_type level_name unit_type unit_name sub_addr
      3      <NA>      <NA>       <NA>       <NA>      <NA>      <NA>     <NA>
      2      <NA>      <NA>       <NA>       <NA>      <NA>      <NA>     <NA>
      1      <NA>      <NA>       <NA>       <NA>      <NA>      <NA>     <NA>
                st_addr block sector         nbrhd district     city metro_area
      3 380 New York St  <NA>   <NA> West Redlands     <NA> Redlands       <NA>
      2 380 New York St  <NA>   <NA> West Redlands     <NA> Redlands       <NA>
      1 380 New York St  <NA>   <NA> West Redlands     <NA> Redlands       <NA>
                    subregion     region region_abbr territory zone postal postal_ext
      3 San Bernardino County California          CA      <NA> <NA>  92373       <NA>
      2 San Bernardino County California          CA      <NA> <NA>  92373       <NA>
      1 San Bernardino County California          CA      <NA> <NA>  92373       <NA>
        country    cntry_name lang_code distance         x        y display_x
      3     USA United States       ENG        0 -117.1957 34.05609 -117.1957
      2     USA United States       ENG        0 -117.1957 34.05609 -117.1957
      1     USA United States       ENG        0 -117.1957 34.05609 -117.1957
        display_y      xmin      xmax     ymin     ymax ex_info bldg_comp struc_type
      3  34.05609 -117.2007 -117.1907 34.05109 34.06109    <NA>      <NA>       <NA>
      2  34.05609 -117.2007 -117.1907 34.05109 34.06109    <NA>      <NA>       <NA>
      1  34.05609 -117.2007 -117.1907 34.05109 34.06109    <NA>      <NA>       <NA>
        struc_det                   geometry
      3      <NA> POINT (-117.1957 34.05609)
      2      <NA> POINT (-117.1957 34.05609)
      1      <NA> POINT (-117.1957 34.05609)

