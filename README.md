# KmlContains

Parse a KML file and check if geographic points fall inside the polygons it defines. Supports multiple polygons and polygons with holes (inner boundaries).

## Usage

```ruby
region = KmlContains.parse_kml(File.read('path/to/regions.kml'))

# assuming regions.kml defines NSW boundaries
sydney = KmlContains::Point.new(151.21, -33.87)
region.contains_point?(sydney)             # => true
region.contains_point?(151.21, -33.87)     # also works

melbourne = KmlContains::Point.new(144.96, -37.81)
region.contains_point?(melbourne)          # => false
```

Points are `(longitude, latitude)`. You can pass a `KmlContains::Point`, a longitude/latitude pair, or any object that responds to `x` and `y`.

## Dependencies

* [Nokogiri](https://nokogiri.org)

## Credits

Originally created as `border_patrol` at Square by **Zach Brock** and **Matt Wilson**.

Contributors: **Scott Gonyea**, **Rob Olson**, **Omar Qazi**, **Denis Haskin**, **Tamir Duberstein**, **Erica Kwan**.

## License

MIT
