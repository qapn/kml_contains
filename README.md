# KmlContains

Parse a KML file and check if geographic points fall inside the polygons it defines. Supports multiple polygons and polygons with holes (inner boundaries).

## Usage

Using [NSW Local Government Areas](https://data.gov.au/data/dataset/nsw-local-government-areas) from data.gov.au as an example — download the ESRI Shapefile (GDA94) and convert it to KML with [GDAL](https://gdal.org):

```bash
ogr2ogr -f KML nsw-lga.kml nsw_lga.shp
```

Then in Ruby:

```ruby
region = KmlContains.parse_kml(File.read('nsw-lga.kml'))

sydney = KmlContains::Point.new(151.21, -33.87)
region.contains_point?(sydney)             # => true
region.contains_point?(151.21, -33.87)     # also works

melbourne = KmlContains::Point.new(144.96, -37.81)
region.contains_point?(melbourne)          # => false

# find which polygon contains a point and access its ExtendedData
lga = region.find { |p| p.contains_point?(sydney) }
lga.extended_data['LGA_NAME']              # => "Council of the City of Sydney"
```

Points are `(longitude, latitude)`. You can pass a `KmlContains::Point`, a longitude/latitude pair, or any object that responds to `x` and `y`.

## Dependencies

* [Nokogiri](https://nokogiri.org)

## Credits

Originally created as `border_patrol` at Square by **Zach Brock** and **Matt Wilson**.

Contributors: **Scott Gonyea**, **Rob Olson**, **Omar Qazi**, **Denis Haskin**, **Tamir Duberstein**, **Erica Kwan**.

## License

MIT
