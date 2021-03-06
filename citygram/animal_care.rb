require_relative './url'

module Citygram
  class AnimalCare
    def self.build_features(records)
      records.map do |record|
        lat = record['attributes']['Latitude'].to_f
        lng = record['attributes']['Longitude'].to_f
        next if lat == 0.0 || lng == 0.0

        title = record['attributes']['CategoryHierarchy']
        {
          'id'          => record['attributes']['GlobalID'],
          'type'        => 'Feature',
          'properties'  => record.merge('title' => title),
          'geometry'    => {
            'type'        => 'Point',
            'coordinates' =>  [lng, lat]
          }
        }
      end
    end

    def self.retrieve_records(offset = 0)
      url = Citygram::Url.build('Animal care', 0)
      response = JSON.parse(HTTParty.get(url).body)
      records = response['features']

      features = build_features(records)

      next_page_url =  Citygram::Url.build('Animal care', offset + 1000) if response['exceededTransferLimit']
      [{'features' => features.compact }.to_json, next_page_url]
    end
  end
end
