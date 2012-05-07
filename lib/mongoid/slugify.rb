require 'mongoid'
require 'mongoid/slugify/version'
require 'active_support/concern'

module Mongoid
  module Slugify
    extend ActiveSupport::Concern

    included do
      field :slug
      index :slug, :unique => true
      before_save :assign_slug
    end

    def to_param
      slug || super
    end

    private
      def generate_slug
        raise NotImplementedError
      end

      def generate_unique_slug
        current_slug = generate_slug
        pattern = /^#{Regexp.escape(current_slug)}(?:-(\d+))?$/

        appropriate_class = self.class
        while (appropriate_class.superclass.include?(Mongoid::Document))
          appropriate_class = appropriate_class.superclass
        end

        existing_slugs = appropriate_class.where(:slug => pattern, :_id.ne => _id).only(:slug).map { |record| record.slug }
        if existing_slugs.count > 0
          max_counter = existing_slugs.map { |slug| (pattern.match(slug)[1] || 0).to_i }.max
          current_slug << "-#{max_counter + 1}"
        end

        current_slug
      end

      def assign_slug
        self.slug = generate_unique_slug
      end

    module ClassMethods
      def find_by_slug(slug)
        where(:slug => slug).first
      end

      def find_by_slug!(slug)
        find_by_slug(slug) || raise(Mongoid::Errors::DocumentNotFound.new(self, slug))
      end

      def find_by_slug_or_id(slug_or_id)
        find_by_slug(slug_or_id) || where(:_id => slug_or_id).first
      end

      def find_by_slug_or_id!(slug_or_id)
        find_by_slug(slug_or_id) || find(slug_or_id)
      end
    end
  end
end
