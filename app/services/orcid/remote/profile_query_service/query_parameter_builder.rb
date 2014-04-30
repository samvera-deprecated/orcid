require_dependency 'orcid/remote/profile_query_service'
module Orcid
  module Remote
    class ProfileQueryService
      # http://support.orcid.org/knowledgebase/articles/132354-searching-with-the-public-api
      module QueryParameterBuilder

        module_function
        # Responsible for converting an arbitrary query string to the acceptable
        # Orcid query format.
        #
        # @TODO - Note this is likely not correct, but is providing the singular
        # point of entry
        def call(input = {})
          params = {}
          q_params = []
          text_params = []
          input.each do |key, value|
            next if value.nil? || value.to_s.strip == ''
            case key.to_s
            when 'start', 'row'
              params[key] = value
            when 'q', 'text'
              text_params << "#{value}"
            else
              q_params << "#{key.to_s.gsub('_', '-')}:#{value}"
            end
          end

          case text_params.size
          when 0; then nil
          when 1
            q_params << "text:#{text_params.first}"
          else
            q_params << "text:((#{text_params.join(') AND (')}))"
          end
          params[:q] = q_params.join(' AND ')
          params
        end
      end
    end
  end
end
