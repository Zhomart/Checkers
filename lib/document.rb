require 'active_support/inflector/methods'

module Jongoid
  module Document
    extend ActiveSupport::Concern

    def collection; self.class.collection; end

    def new_record?; !!@_mongo_data[:_id]; end

    def save
      collection.drop

      query = collection.find(_id: self.id)

      record = query.first

      q = if record
        query.update(@_mongo_data)
      else
        collection.insert(@_mongo_data)
      end
      print "-- "+q.inspect+" -- " +@_mongo_data.inspect
    end

    def initialize(params = {})
      params = Jongoid::Document.symbolize_hash(params)

      params.delete(:id)
      params.delete(:_id)

      @_mongo_data = params.merge(_id: Jongoid::Document.generate_id)
    end

    def inspect
      "#<#{self.class}:#{@_mongo_data.to_json[1..-2].gsub(/:/, '=')}>"
    end

    def to_s
      inspect
    end

    def method_missing(method, value = nil)
      if method[-1] == "="
        method = method[0..-2].to_sym
        return super if not self.class.fields.keys.include?(method)
        @_mongo_data[method] = value
      else
        method = method.to_sym
        return super if not self.class.fields.keys.include?(method)
        @_mongo_data[method]
      end
    end

    module ClassMethods
      def mongo; Checkers::API.mongo; end

      def collection_name; ActiveSupport::Inflector.underscore(self.to_s).to_sym; end

      def collection; mongo[collection_name]; end

      def fields; @fields || {}; end

      def field(name, opts = {})
        @fields ||= { :_id => {} }
        @fields[name] = opts
      end

      def first(criteria)
        data = collection.find(criteria).first
        return nil unless data
        data = Jongoid::Document.symbolize_hash(data)
        doc = self.new data
        doc._id = data[:_id]
        doc
      end

      def all(criteria)
        raise "not implemented"
      end

      def find(id)
        collection.find(_id: id).first
      end

    end

    def self.symbolize_hash(hsh)
      Hash[hsh.to_a.map{|a, b| [a.to_sym, b] }]
    end

  private
    def self.generate_id
      rand(36**24).to_s(36)
    end

  end

  # class Criteria
  # end
end
