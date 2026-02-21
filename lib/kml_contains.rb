require 'set'
require 'forwardable'
require 'nokogiri'
require 'kml_contains/version'
require 'kml_contains/point'
require 'kml_contains/polygon'
require 'kml_contains/region'

module KmlContains
  class InsufficientPointsToActuallyFormAPolygonError < ArgumentError; end

  def self.parse_kml(string)
    doc = Nokogiri::XML(string)

    polygons = doc.search('Polygon').map do |polygon_kml|
      placemark_name = placemark_name_for_polygon(polygon_kml)
      extended_data = extended_data_for_polygon(polygon_kml)
      parse_kml_polygon_data(polygon_kml.to_s, placemark_name, extended_data)
    end
    KmlContains::Region.new(polygons)
  end

  def self.bounding_box(points)
    xs = points.map(&:x)
    ys = points.map(&:y)
    [Point.new(xs.min, ys.max), Point.new(xs.max, ys.min)]
  end

  def self.central_point(box)
    point1, point2 = box

    x = (point1.x + point2.x) / 2
    y = (point1.y + point2.y) / 2

    Point.new(x, y)
  end

  private

  def self.parse_kml_polygon_data(string, name = nil, extended_data = {})
    doc = Nokogiri::XML(string)
    # "A Polygon is defined by an outer boundary and 0 or more inner boundaries."
    outerboundary = doc.xpath('//outerBoundaryIs')
    innerboundaries = doc.xpath('//innerBoundaryIs')
    coordinates = outerboundary.xpath('.//coordinates').text.strip.split(/\s+/)
    points = points_from_coordinates(coordinates)
    if innerboundaries
      inner_boundary_polygons = innerboundaries.map do |i|
        KmlContains::Polygon.new(points_from_coordinates(i.xpath('.//coordinates').text.strip.split(/\s+/)))
      end
      KmlContains::Polygon.new(points).with_placemark_name(name).with_extended_data(extended_data).with_inner_boundaries(inner_boundary_polygons)
    else
      KmlContains::Polygon.new(points).with_placemark_name(name).with_extended_data(extended_data)
    end
  end

  def self.points_from_coordinates c
    c.map do |coord|
      x, y, _ = coord.strip.split(',')
      KmlContains::Point.new(x.to_f, y.to_f)
    end
  end

  def self.placemark_for_polygon(p)
    # A polygon can be contained by a MultiGeometry or Placemark
    parent = p.parent
    parent = parent.parent if parent.name == 'MultiGeometry'

    return nil unless parent.name == 'Placemark'

    parent
  end

  def self.placemark_name_for_polygon(p)
    placemark = placemark_for_polygon(p)
    return nil unless placemark

    placemark.search('name').text
  end

  def self.extended_data_for_polygon(p)
    placemark = placemark_for_polygon(p)
    return {} unless placemark

    data = {}
    placemark.search('Data').each { |d| data[d['name']] = d.search('value').text }
    placemark.search('SimpleData').each { |sd| data[sd['name']] = sd.text }
    data
  end
end
