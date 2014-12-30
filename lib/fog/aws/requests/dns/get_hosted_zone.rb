module Fog
  module DNS
    class Aws
      class Real
        require 'fog/aws/parsers/dns/get_hosted_zone'

        # retrieve information about a hosted zone
        #
        # ==== Parameters
        # * zone_id<~String> - The ID of the hosted zone
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'HostedZone'<~Hash>:
        #       * 'Id'<~String> -
        #       * 'Name'<~String> -
        #       * 'CallerReference'<~String>
        #       * 'Comment'<~String> -
        #     * 'NameServers'<~Array>
        #       * 'NameServer'<~String>
        #   * status<~Integer> - 200 when successful
        def get_hosted_zone(zone_id)
          # Aws methods return zone_ids that looks like '/hostedzone/id'.  Let the caller either use
          # that form or just the actual id (which is what this request needs)
          zone_id = zone_id.sub('/hostedzone/', '')

          request({
            :expects => 200,
            :parser  => Fog::Parsers::DNS::AWS::GetHostedZone.new,
            :method  => 'GET',
            :path    => "hostedzone/#{zone_id}"
          })
        end
      end

      class Mock
        def get_hosted_zone(zone_id)
          response = Excon::Response.new
          if (zone = self.data[:zones][zone_id])
            response.status = 200
            response.body = {
              'HostedZone' => {
                'Id' => zone[:id],
                'Name' => zone[:name],
                'CallerReference' => zone[:reference],
                'Comment' => zone[:comment]
              },
              'NameServers' => Fog::AWS::Mock.nameservers
            }
            response
          else
            response.status = 404
            response.body = "<?xml version=\"1.0\"?><ErrorResponse xmlns=\"https://route53.amazonaws.com/doc/2012-02-29/\"><Error><Type>Sender</Type><Code>NoSuchHostedZone</Code><Message>The specified hosted zone does not exist.</Message></Error><RequestId>#{Fog::AWS::Mock.request_id}</RequestId></ErrorResponse>"
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
        end
      end
    end
  end
end
