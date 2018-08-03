require 'securerandom'

module Shoryuken
  module Later
    class Client
      @@tables = {}
      
      class << self
        def tables(table)
          @@tables[table] ||= ddb.describe_table(table_name: table)
        end
        
        def first_item(table, filter=nil)
          item = nil
          response = ddb.scan(table_name: table, limit: 1, scan_filter: filter)
          response.each do |result|
            item = result.items.first and break
          end
          item
        end
        
        def create_item(table, item)
          item['id'] ||= SecureRandom.uuid
          
          ddb.put_item(table_name: table, item: item,
                       expected: {id: {exists: false}})
        end
        
        def delete_item(table, item)
          ddb.delete_item(table_name: table, key: {id: item['id']},
                          expected: {id: {value: item['id'], exists: true}})
        end
        
        def ddb
          options = {
            endpoint: ENV['AWS_DYNAMODB_ENDPOINT']
          }.reject{|k,v| v.nil?}

          @ddb ||= Aws::DynamoDB::Client.new(options)
        end
      end
    end
  end
end
