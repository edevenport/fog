module Fog
    module Compute
        class ProfitBricks
            class Real
                require 'fog/profitbricks/parsers/compute/update_storage'

                # Update a virtual storage
                #
                # ==== Parameters
                # * storageId<~String> - 
                # * size<~Integer> -
                #
                # ==== Returns
                # * response<~Excon::Response>:
                #   * body<~Hash>:
                #     * updateStorageResponse<~Hash>:
                #       * requestId<~String> - ID of request
                #       * dataCenterId<~String> - UUID of virtual data center
                #       * dataCenterVersion<~Integer> - Version of the virtual data center
                #
                # {ProfitBricks API Documentation}[http://www.profitbricks.com/apidoc/APIDocumentation.html?deleteStorage.html]
                def update_storage(storage_id, size)
                    soap_envelope = Fog::ProfitBricks.construct_envelope {
                      |xml| xml[:ws].updateStorage {
                        xml.request { 
                          xml.storageId(storage_id)
                          xml.size(size)
                        }
                      }
                    }

                    request(
                        :expects => [200],
                        :method  => 'POST',
                        :body    => soap_envelope.to_xml,
                        :parser  =>
                          Fog::Parsers::Compute::ProfitBricks::UpdateStorage.new
                    )
                rescue Excon::Errors::InternalServerError => error
                    Fog::Errors::NotFound.new(error)
                end
            end

            class Mock
                def update_storage(storage_id, size)
                    response = Excon::Response.new
                    response.status = 200
                    
                    if storage = self.data[:volumes].find {
                      |attrib| attrib['id'] == storage_id
                    }
                        storage['size'] = size
                    else
                        raise Fog::Errors::NotFound.new('The requested resource could not be found')
                    end
                    
                    response.body = {
                      'updateStorageResponse' =>
                      {
                        'requestId'         => Fog::Mock::random_numbers(7),
                        'dataCenterId'      => storage['dataCenterId'],
                        'dataCenterVersion' => storage['dataCenterVersion'] + 1
                      }
                    }
                    response
                end
            end
        end
    end
end