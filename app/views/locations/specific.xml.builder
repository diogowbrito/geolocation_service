xml.instruct!(:xml, :version=>"1.0")

xml.map(:title => "Map") do
  xml.link(:href => @location.description)
end