namespace :orcid do
  namespace :batch do
    desc 'Given the input: CSV query for existing Orcids and report to output: CSV'
    task :query => [:environment, :init, :query_runner, :run]

    task :query_runner do
      @runner = lambda { |person|
        puts "Processing: #{person.email}"
        Orcid::Remote::ProfileLookupRunner.new {|on|
          on.found {|results|
            person.found(results)
            puts "\tfound" if verbose
          }
          on.not_found {
            person.not_found
            puts "\tnot found" if verbose
          }
        }.call(email: person.email)
      }
    end

    desc "Given the input: CSV query for existing Orcids and if not found create new ones recording output: CSV"
    task :create => [:environment, :init, :create_runner, :run]

    task :create_runner do
      @creation_service = lambda {|person|
        puts "Creating Profile for: #{person.email}"
        profile_creation_service = Orcid::Remote::ProfileCreationService.new do |on|
          on.success {|orcid_profile_id|
            person.orcid_profile_id = orcid_profile_id
            puts "\tcreated #{orcid_profile_id}" if verbose
          }
        end
        profile_request = Orcid::ProfileRequest.new(person.attributes)
        profile_request.run(
          validator: lambda{|*| true},
          profile_creation_service: profile_creation_service
        )
      }
      @runner = lambda { |person|
        puts "Processing: #{person.email}"
        Orcid::Remote::ProfileQueryService.new {|on|
          on.found {|results|
            person.found(results)
            puts "\tfound" if verbose
          }
          on.not_found {
            person.not_found
            puts "\tnot found" if verbose
            @creation_service.call(person)
          }
        }.call(email: person.email)
      }
    end


    task :run do
      if defined?(WebMock)
        WebMock.allow_net_connect!
      end
      input_file = ENV.fetch('input') { './tmp/orcid_input.csv' }
      output_file = ENV.fetch('output') { './tmp/orcid_output.csv' }

      require 'csv'
      CSV.open(output_file, 'wb+') do |output|
        output << @person_builder.to_header_row
        CSV.foreach(input_file, headers: true, header_converters: [lambda{|col| col.strip }]) do |input|
          person = @person_builder.new(input.to_hash)
          @runner.call(person)
          output << person.to_output_row
        end
      end
    end

    task :init do
      module Orcid::Batch
        class PersonRecord
          def self.to_header_row
            ['email', 'given_names', 'family_name', 'existing_orcids', 'created_orcid', 'queried_at']
          end
          attr_reader :email, :given_names, :family_name, :existing_orcids
          attr_accessor :created_orcid
          def initialize(row)
            @email = row.fetch('email')
            @given_names = row['given_names']
            @family_name = row['family_name']
            @existing_orcids = nil
          end

          def attributes
            { email: email, given_names: given_names, family_name: family_name }
          end

          def found(existing_orcids)
            @existing_orcids = Array.wrap(existing_orcids).collect(&:orcid_profile_id).join("; ")
          end

          def to_output_row
            [email, given_names, family_name, existing_orcids, created_orcid, Time.now]
          end

          def not_found
            @existing_orcids = 'null'
          end

        end
      end
      @person_builder = Orcid::Batch::PersonRecord
    end
  end
end
