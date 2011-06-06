xml.instruct!(:xml, :version=>"1.0")

xml.list(:title => "Maps") do
  @locations.each do |location|
    xml.item(location.name, :title => "Mapa", :href => location.description)
  end
end