module Orcid

  module XmlScrubber
    
    # Get the xml to send to ORCID's API's. This replaces underscores with hyphens for element names.
    def outgoing_xml
      scrub(to_xml, "_", "-")
    end

    # Scrub the xml from ORCID's API's. This replaces hyphens with underscores for element names.
    def scrub_incoming_xml
      scrub(to_xml, "-", "_")
    end

    # Using the xml, loop through the elements and replace the orig_character with new_character
    def scrub(xml, orig_character, new_character)
     
     #Create a Nokogiri document
     xml_doc = Nokogiri::XML(xml)

     #get all nodes
     node_set = xml_doc.xpath("//*")
     
     node_set.each do |node|

       # rename the node if it has the character that needs replacing
       if node.node_name.include? orig_character
         node.name = node.name.gsub(orig_character, new_character)
       end

     end

     xml_doc.to_s

    end
  
  end


end

