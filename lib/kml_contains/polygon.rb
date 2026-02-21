module KmlContains
  class Polygon
    attr_reader :placemark_name, :inner_boundaries, :extended_data
    extend Forwardable

    # Note @points is the outer boundary.
    # A polygon may also have 1 or more inner boundaries.  In order to not change the ctor signature,
    # the inner boundaries are not settable at construction.
    def initialize(*args)
      args.flatten!
      args.uniq!
      raise InsufficientPointsToActuallyFormAPolygonError unless args.size > 2
      @inner_boundaries = []
      @extended_data = {}
      @points = args.dup
      precompute_normalised_bounds
    end

    def_delegators :@points, :size, :each, :first, :include?, :[], :index

    def with_inner_boundaries(polygons)
      @inner_boundaries = [polygons].flatten
      self
    end

    def with_placemark_name(placemark)
      @placemark_name ||= placemark
      self
    end

    def with_extended_data(data)
      @extended_data = data
      self
    end

    def ==(other)
      # Do we have the right number of points?
      return false unless other.size == size

      # Are the points in the right order?
      first, second = first(2)
      index = other.index(first)
      return false unless index
      direction = (other[index - 1] == second ? -1 : 1)
      # Check if the two polygons have the same edges and the same points
      # i.e. [point1, point2, point3] is the same as [point2, point3, point1] is the same as [point3, point2, point1]
      each do |i|
        return false unless i == other[index]
        index += direction
        index = 0 if index == size
      end
      return true if @inner_boundaries.empty?
      @inner_boundaries == other.inner_boundaries
    end

    # Quick and dirty hash function
    def hash
      @points.map { |point| point.x + point.y }.reduce(&:+).to_i
    end

    def contains_point?(point)
      return false unless inside_bounding_box?(point)
      px = normalise_lng(point.x)
      c = false
      i = -1
      j = size - 1
      while (i += 1) < size
        iy = self[i].y
        jy = self[j].y
        if (iy <= point.y && point.y < jy) ||
           (jy <= point.y && point.y < iy)
          if px < (@norm_xs[j] - @norm_xs[i]) * (point.y - iy) / (jy - iy) + @norm_xs[i]
            c = !c
          end
        end
        j = i
      end
      return c if c == false
      # Check if excluded by any of the inner boundaries
      @inner_boundaries.each do |inner_boundary|
        return false if inner_boundary.contains_point?(point)
      end
      c
    end

    def inside_bounding_box?(point)
      px = normalise_lng(point.x)
      !(px < @bb_min_x || px > @bb_max_x ||
        point.y < @bb_min_y || point.y > @bb_max_y)
    end

    def bounding_box
      [KmlContains::Point.new(@bb_min_x, @bb_max_y),
       KmlContains::Point.new(@bb_max_x, @bb_min_y)]
    end

    def central_point
      KmlContains.central_point(bounding_box)
    end

    private

    def normalise_lng(lng)
      diff = lng - @ref_x
      diff -= 360 while diff > 180
      diff += 360 while diff < -180
      @ref_x + diff
    end

    def precompute_normalised_bounds
      @ref_x = @points.first.x
      @norm_xs = @points.map { |p| normalise_lng(p.x) }
      ys = @points.map(&:y)
      @bb_min_x = @norm_xs.min
      @bb_max_x = @norm_xs.max
      @bb_min_y = ys.min
      @bb_max_y = ys.max
    end
  end
end
