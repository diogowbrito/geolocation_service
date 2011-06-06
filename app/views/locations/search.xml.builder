xml.instruct!(:xml, :version=>"1.0")

xml.list(:title => @keyword, :start => @start, :end => @end, :next => @next) do
  @list.each do |location|
    xml.item(location.name, :title => "Map", :href => $myApplicationURL + "/specific?building="+ location.name)
  end
end