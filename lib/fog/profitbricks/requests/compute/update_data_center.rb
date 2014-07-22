module Fog
    module Compute
        class ProfitBricks
            class Real
                require 'fog/profitbricks/parsers/compute/update_data_center'
                def update_data_center(data_center_id, data_center_name='')
                    soap_envelope = Fog::ProfitBricks.construct_envelope {
                      |xml| xml[:ws].updateDataCenter {
                        xml.request { 
                          xml.dataCenterId(data_center_id)
                          xml.dataCenterName(data_center_name)
                        }
                      }
                    }

                    request(
                        :expects => [200],
                        :method  => 'POST',
                        :body    => soap_envelope.to_xml,
                        :parser  => 
                          Fog::Parsers::Compute::ProfitBricks::UpdateDataCenter.new
                    )
                rescue Excon::Errors::InternalServerError => error
                    Fog::Errors::NotFound.new(error)
                end
            end

            class Mock
                def update_data_center(data_center_id, data_center_name='')
                    response = Excon::Response.new
                    response.status = 200
                    
                    if data_center = self.data[:datacenters].find {
                      |attrib| attrib['id'] == data_center_id
                    }
                        data_center['name'] = data_center_name
                        data_center['dataCenterVersion'] += 1
                    else
                        raise Fog::Errors::NotFound.new('The requested resource could not be found')
                    end
                    
                    response.body = { 'updateDataCenterResponse' => data_center }
                    response
                end
            end
        end
    end
end