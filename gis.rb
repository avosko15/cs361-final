#!/usr/bin/env ruby

class Track
  attr_reader :name, :segments

  def initialize(args)
    @name = args[:name]
    @segments = args[:segments]
  end

  def get_track_json()
    json = '{'
    json += '"type": "Feature", '
    if @name != nil
      json += '"properties": {'
      json += '"title": "' + @name + '"'
      json += '},'
    end
    json += '"geometry": {'
    json += '"type": "MultiLineString",'
    json +='"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        json += ","
      end
        json += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      json += tsj
      json += ']'
    end
    json + ']}}'
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(args)
    @lat = args[:lat]
    @lon = args[:lon]
    @ele = args[:ele] || ''
    @name = args[:name] || ''
    @type = args[:type] || ''
  end

  def get_waypoint_json
    json = '{"type": "Feature",'
    json += '"geometry": {"type": "Point","coordinates": '
    json += "[#{@lat},#{@lon}"
    if ele != nil
      json += ",#{@ele}"
    end
    json += ']},'
    if name != nil or type != nil
      json += '"properties": {'
      if name != nil
        json += '"title": "' + @name + '"'
      end
      if type != nil
        if name != nil
          json += ','
        end
        json += '"icon": "' + @type + '"'
      end
      json += '}'
    end
    json += "}"
    return json
  end
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(type)
  end

  def to_geojson
    string = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature, index|
      if index != 0
        string += ","
      end
        if feature.class == Track
            string += feature.get_track_json
        elsif feature.class == Waypoint
            string += feature.get_waypoint_json
      end
    end
    string + "]}"
  end
end

def main()
  w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 30, :name => "home", :type => "flag")
  w2 = Waypoint.new(:lat => -121.5, :lon => 45.6, :ele => nil, :name => "store", :type => "dot")

  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  ts2 = [ 
    Point.new(-121, 45),
    Point.new(-121, 46), 
  ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new(:segments => [TrackSegment.new(ts1), TrackSegment.new(ts2)], :name => "track 1")
  t2 = Track.new(:segments => [TrackSegment.new(ts3)], :name => "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

