class LocationsController < ApplicationController




  def writeToFile(args)

    require 'cgi'

    @file_name = args[:nome_file]

    File.new(@file_name.to_s+".kml", "w+")

    @file = File.open(@file_name.to_s+".kml", "w+")


    @file.puts('<?xml version="1.0" encoding="utf-8" ?>
     <kml xmlns="http://www.opengis.net/kml/2.2">
     <Document><Folder><name>sql_statement</name>
     <Schema name="sql_statement" id="sql_statement">
       <SimpleField name="Name" type="string"></SimpleField>
       <SimpleField name="Description" type="string"></SimpleField>
     </Schema>
       <Placemark>')

    @file.puts('<name>'+@name.to_s+'</name>
       <description>'+ CGI.escapeHTML(@description.to_s)+'</description>
       <ExtendedData><SchemaData schemaUrl="#sql_statement">
         <SimpleData name="Name">'+ @name.to_s+'</SimpleData>
         <SimpleData name="Description">'+CGI.escapeHTML(@description.to_s)+'</SimpleData>
       </SchemaData></ExtendedData>'+
                   @kml+'</Placemark>
     </Folder></Document></kml>')


    @file.close()


  end


  def exists_space(args)

    @return = args[:name].to_s
    if (args[:name].to_s.include?(" "))

      @return = @return.gsub(" ", "%")

    end

    return
    @return

  end


  def get_location_map_from_name

    building = params[:building].upcase
    room_name = params[:room]

    case building
      when "ED.I"
        @location = Edi.find_by_name(room_name)

      when "ED.II"
        @location = Edii.find_by_name(room_name)
      when "ED.III"
        @location = Ediii.find_by_name(room_name)
      when "ED.IV"
        @location = Ediv.find_by_name(room_name)
      when "CAMPUS"
        @location = Campus.find_by_name(room_name)
      when "CITI"
        @location = Citi.find_by_name(room_name)
      else
        @pling = 'ED.I'
    end


  end


  def search

    @keyword =  params[:keyword].gsub("%", "\%").gsub("_", "\_")
    @start = params[:start] || '1'
    @end = params[:end] || '20'
    @next = @end.to_i+1
    keyarray = @keyword.to_s.split(' ')

    professors = Professor.find(:all, :conditions=> ["professor_name like ?","%"+@keyword+"%"])

    @list = []
    counter = 1
    professors.each do |p|

      if counter >= @start.to_i then
           @list << p
      end

      counter = counter.to_i+1

      if counter > @end.to_i then
        break
      end

    end

    if @list.count != 20 then
      @next = ""
    end

    respond_to :xml
  end


end
