#Encoding: UTF-8

class LocationsController < ApplicationController


  def description
    @address = get_address
    respond_to :xml
  end

  def meta_info
    @address = get_address
    respond_to :xml
  end

  def status
    respond_to :xml
  end


  def writeToFile(file_name, location)

    require 'cgi'

  #  @file_name = args[:nome_file]
    puts file_name
    File.new(file_name.to_s+".kml", "w+")

    @file = File.open("public/kmlTrunk/" + file_name.to_s+".kml", "w+")



    @file.puts('<?xml version="1.0" encoding="utf-8" ?>
     <kml xmlns="http://www.opengis.net/kml/2.2">
     <Document><Folder><name>sql_statement</name>
     <Schema name="sql_statement" id="sql_statement">
       <SimpleField name="Name" type="string"></SimpleField>
       <SimpleField name="Description" type="string"></SimpleField>
     </Schema>
       <Placemark>')

    @file.puts('<name>'+ location.name.to_s+'</name>
       <description>'+ CGI.escapeHTML(location.description.to_s)+'</description>
       <ExtendedData><SchemaData schemaUrl="#sql_statement">
         <SimpleData name="Name">'+ location.name.to_s+'</SimpleData>
         <SimpleData name="Description">'+CGI.escapeHTML(location.description.to_s)+'</SimpleData>
       </SchemaData></ExtendedData>'+
                   location.SHAPE.as_kml+'</Placemark>
     </Folder></Document></kml>')


    @file.close()

    return ("/kmlTrunk/" + file_name.to_s+".kml");

  end


  def exists_space(args)

    @return = args[:name].to_s
    if (args[:name].to_s.include?(" "))

      @return = @return.gsub(" ", "%")

    end

    return
    @return

  end

  def upload_file_to_dropbox(file_name)

    require 'dropbox'

    #login
    settings = JSON.parse(File.read('keys.json'))
    session = Dropbox::Session.new(settings['key'], settings['secret'], :authorizing_user => settings['email'],
                                   :authorizing_password => settings['password'])
    session.mode = :dropbox
    session.authorize!

   # upload the file
      session.upload file_name + '.kml', '/public'
      uploaded_file = session.file(file_name + '.kml')


    return 'http://dl.dropbox.com/u/31524619/' + file_name + '.kml'

  end

  def search

    @keyword =  params[:keyword].gsub("%", "\%").gsub("_", "\_")
    @start = params[:start] || '1'
    @end = params[:end] || '20'
    @next = @end.to_i+1
    @address = get_address

    keyarray = @keyword.to_s.split(' ')

    case keyarray.length
      when 1
        building = keyarray[0]
      when 2
        if (keyarray[0].upcase.include? "ED")
          if (keyarray[0].include? ".")
            building = "ED." + keyarray[0].rpartition(".")[2].upcase
            room = keyarray[1]

            if (room == "departamental")
              building="departamental"
              room = nil
            end

          else
              building = keyarray[1].upcase
              room = nil
          end
        end
      when 3
        if (keyarray[0].upcase == "EDIFICIO" || keyarray[0].upcase == "EDIFÍCIO" || keyarray[0].upcase == "EDIFíCIO" || keyarray[0].upcase == "ED" || keyarray[0].upcase == "ED.")
          building = "ED." + keyarray[1].upcase
          room = keyarray[2].upcase
        end
      else
        @locations = []
    end

  #  building = keyarray[0]
  #  room = keyarray[1]
    #if there are three arguments
  #  if keyarray[2] != nil
   #   building = "ED." + keyarray[1].upcase
   #   room = keyarray[2].upcase
   # else
   #   if (keyarray[0].upcase == "EDIFICIO" || keyarray[0].upcase == "EDIFÍCIO" || keyarray[0].upcase == "EDIFíCIO" || keyarray[0].upcase == "ED" || keyarray[0].upcase == "ED.")
   #     building = "ED." + keyarray[1].upcase
   #     room = nil
   #   end
   # end
   if (room != nil || building != nil)


    if (room == nil)
      office = building;
      @locations = Campus.find_by_sql(["SELECT * from campus where name like ?", "%"+building.strip+"%"])
    else

      case building
        when "ED.I"
          @locations = Edi.find_by_sql(["SELECT * from edis where name like ?", "%"+room.strip+"%" ])
        when "ED.II"
          @locations = Edii.find_by_sql(["SELECT * from ediis where name like ?", "%"+room.strip+"%" ])
        when "ED.III"
          @locations = Ediii.find_by_sql(["SELECT * from ediiis where name like ?", "%"+room.strip+"%" ])
        when "ED.IV"
          @locations = Ediv.find_by_sql(["SELECT * from edivs where name like ?", "%"+room.strip+"%" ])
        when "CAMPUS"
          @locations = Campus.find_by_sql(["SELECT * from campus where name like ?", "%"+room.strip+"%" ])
        when "CITI"
          @locations = Citi.find_by_sql(["SELECT * from citis where name like ?", "%"+room.strip+"%" ])
        else
          @locations = Campus.find_by_sql(["SELECT * from campus where name like ?", "%"+room.strip+"%" ])
      end
    end
    end
    @list = []
    counter = 1

    @locations.each do |location|
      if (room != nil)
      	location.description = building + " " + location.name
        location.name = building + "&room=" + location.name
    	else
        location.description = building
    	end
      if counter >= @start.to_i then
        @list << location
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


  def specific

    building = params[:building]
    room = params[:room]

    if (room == nil)
      office = building;
      @location = Campus.find_by_name(building)

    else
      case building
        when "ED.I"
          @location = Edi.find_by_name(room)
        when "ED.II"
          @location = Edii.find_by_name(room)
        when "ED.III"
          @location = Ediii.find_by_name(room)
        when "ED.IV"
          @location = Ediv.find_by_name(room)
        when "CAMPUS"
          @location = Campus.find_by_name(room)
        when "CITI"
          @location = Citi.find_by_name(room)
        else
            #
      end
      office = building + "_" + @location.name
    end

    @location.description = get_address + writeToFile(office, @location)

  #  @location.description = upload_file_to_dropbox(office)

    respond_to :xml
  end

  def download_kml
    fileName = params[:id]
        send_data("public/kmlTrunk/" +fileName, :filename => "#{fileName}", :type => "application/kml")
    end
end


