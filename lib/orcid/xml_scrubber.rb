module Orcid

  module XmlScrubber
    
    # Get the xml to send to ORCID's API's. This replaces underscores with hyphens for element names.
    def outgoing_xml
      scrub(to_xml, "_", "-", "orcid", "http://www.orcid.org/ns/orcid")
    end

    # Scrub the xml from ORCID's API's. This replaces hyphens with underscores for element names.
    def scrub_incoming_xml
      scrub(to_xml, "-", "_", "orcid", "http://www.orcid.org/ns/orcid")
    end

    # Using the xml, loop through the elements and replace the orig_character with new_character
    def scrub(xml, orig_character, new_character, namespace_name=nil, namespace_url=nil)
     
      #Create a Nokogiri document
      xml_doc = Nokogiri::XML(xml)



      #get all nodes
      if namespace_name && namespace_url
        node_set  = xml_doc.xpath( "//#{namespace_name}:*", namespace_name => namespace_url )
        node_set += xml_doc.xpath( "//#{namespace_name}:*/@*", namespace_name => namespace_url )
      else
        node_set  = xml_doc.xpath( "//*" )
        node_set += xml_doc.xpath( "//*/@*" )
      end

      node_set.each do |node|

        # rename the node if it has the character that needs replacing
        if node.node_name.include? orig_character
          node.name = node.name.gsub(orig_character, new_character)
        end

        #have to remove empty nodes so ORCID won't barf
        if (node.element_children.empty? && node.content.strip.empty?)
          node.remove
        end

      end

      #we're going to run this 3 more times to pick up nodes that were cleaned up previously
      #this should really be recursive instead
      node_set.each do |node|
        if (node.element_children.empty? && node.content.strip.empty?)
          node.remove
        end
      end
      node_set.each do |node|
        if (node.element_children.empty? && node.content.strip.empty?)
          node.remove
        end
      end
      node_set.each do |node|
        if (node.element_children.empty? && node.content.strip.empty?)
          node.remove
        end
      end
      #have to pull the root rather to to_xml so we don't get the XML header info
      xml_doc.root.to_s

    end  
  end
end

