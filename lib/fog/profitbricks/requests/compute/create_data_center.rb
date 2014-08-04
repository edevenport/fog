module Fog
    module Compute
        class ProfitBricks
            class Real
                require 'fog/profitbricks/parsers/compute/create_data_center'

                # Create a new virtual data center
                #
                # ==== Parameters
                # * options<~Hash>:
                # *   dataCenterName<~String> - Name of the new virtual data center
                # *   region<~String> - Region to create the new data center (NORTH_AMERICA, EUROPE, or DEFAULT)
                #
                # ==== Returns
                # * response<~Excon::Response>:
                #   * body<~Hash>:
                #     * createDataCenterResponse<~Hash>:
                #       * requestId<~String> - ID of request
                #       * dataCenterId<~String> - UUID of virtual data center
                #       * dataCenterVersion<~Integer> - Version of the virtual data center
                #       * region<~String> - Region of virtual data center
                #
                # {ProfitBricks API Documentation}[http://www.profitbricks.com/apidoc/CreateDataCenter.html]
                def create_data_center(data_center_name, region='DEFAULT')
                    soap_envelope = Fog::ProfitBricks.construct_envelope {
                      |xml| xml[:ws].createDataCenter {
                        options.each { |key, value| xml.send(key, value) }
                      }
                    }

                    request(
                        :expects => [200],
                        :method  => 'POST',
                        :body    => soap_envelope.to_xml,
                        :parser  => 
                          Fog::Parsers::Compute::ProfitBricks::CreateDataCenter.new
                    )
                end
            end

            class Mock
                def create_data_center(data_center_name, region='DEFAULT')
                    response = Excon::Response.new
                    response.status = 200
                    
                    data_center = {
                        'requestId'         => Fog::Mock::random_numbers(7),
                        'id'                => Fog::UUID.uuid,
                        'name'              => data_center_name,
                        'dataCenterVersion' => 1,
                        'provisioningState' => 'AVAILABLE',
                        'region'            => region
                    }
                    
                    self.data[:datacenters] << data_center
                    response.body = { 'createDataCenterResponse' => data_center }
                    response
                end
            end
        end
    end
end
