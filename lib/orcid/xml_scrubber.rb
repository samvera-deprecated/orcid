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

    private

    # Iterate through the xml nodes, depth-first
    # On the way up remove elements that are empty and text nodes that are blank
    # Return the xml doc
    def remove_empty_nodes( xml )

      # Iterate through each child node of the xml root
      xml.children.each do |el| 
        # Recurse
        remove_empty_nodes( el )

        # Check if the current node is an element with no children ...
        empty_el = el.elem? && el.children.empty?
        # or an empty text node
        empty_text = el.text? && el.blank?

        # If the current node has no children or is empty text ...
        if empty_el || empty_text
          # remove it
          el.remove
        end
      end

      return xml
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
      end

      #have to remove empty nodes so ORCID won't barf
      xml_doc = remove_empty_nodes( xml_doc.root )

      return xml_doc.to_xml

    end  
  end
end

