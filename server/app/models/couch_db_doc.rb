class CouchDbDoc
  class << self
    def cloudant
      "https://hatenereationstanstratse:BUpiAo71MBUgKt3T43clfL27@akofink.cloudant.com"
    end

    def cloudant_uri
      URI "#{cloudant}"
    end

    def total_rows
      db.get(URI("#{cloudant}/smart_building_development/_design/data_points/_view/all?limit=0&skip=0"))["total_rows"]
    end

    def delete_all(args={})
      db.post URI("#{cloudant}/smart_building_development/_bulk_docs"),
        {
        docs: JSON.parse(
          db.get(
            URI("#{cloudant}/smart_building_development/_design/data_points/_view/all?limit=10000")
          ).body
        )["rows"].map do |e|
          {
            _id: e["value"]["_id"],
            _rev: e["value"]["_rev"],
            _deleted: true
          }
        end
      }.to_json
    end

    def add_sin(label: "test", f: 1, resolution: 10.0, cycles: 1)
      docs = []
      cycles.times do
        0.upto(resolution - 1) do |t|
          docs << {
            sensor_id: label,
            type: "data_point",
            raw_data: Math.sin(2*Math::PI*t/resolution),
            created_at: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%N%z'),
            updated_at: DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%N%z')
          }
          sleep 1.0 / (f.to_f * resolution)
        end
      end
      db.post "#{cloudant}/smart_building_development/_bulk_docs", {docs: docs}.to_json
    end

    def all
      res = db.get URI("#{cloudant}/smart_building_development/_design/data_points/_view/all")
      JSON.parse(res.body)["rows"].map do |e|
        e["value"]
      end
    end

    def no_created_at
      res = db.get cloudant_uri.path="/smart_building_development/_design/data_points/_view/no_created_at"
      JSON.parse(res.body)["rows"][0]["value"]
    end

    def raw_data
      all.map do |data_point|
        data_point["raw_data"]
      end
    end

    def db
      @db ||= Couch::Server.new cloudant_uri
    end
  end
end
