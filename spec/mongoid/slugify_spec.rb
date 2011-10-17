#encoding: utf-8
require "spec_helper"

class Author
  include Mongoid::Document
  include Mongoid::Slugify
  field :first_name
  field :last_name
  referenced_in :book
  references_many :characters,
                  :class_name => 'Person',
                  :foreign_key => :author_id

  private
    def generate_slug
      [first_name, last_name].reject(&:blank?).join('-').parameterize
    end
end

class Book
  include Mongoid::Document
  include Mongoid::Slugify
  field :title
  embeds_many :subjects
  references_many :authors
  
  private
    def generate_slug
      title.parameterize
    end
end

class ComicBook < Book
end

class Person
  include Mongoid::Document
  include Mongoid::Slugify
  field :name
  embeds_many :relationships
  referenced_in :author, :inverse_of => :characters
  
  private
    def generate_slug
      name.parameterize
    end
end

class Caption
  include Mongoid::Document
  include Mongoid::Slugify
  field :identity
  field :title
  field :medium

  private
    def generate_slug
      [identity.gsub(/\s*\([^)]+\)/, ''), title].join(' ').parameterize
    end
end

module Mongoid
  describe Slugify do
    let(:book) do
      Book.create(:title => "A Thousand Plateaus")
    end

    context "when the object is top-level" do
      it "generates a slug" do
        book.to_param.should eql "a-thousand-plateaus"
      end

      it "updates the slug" do
        book.title = "Anti Oedipus"
        book.save
        book.to_param.should eql "anti-oedipus"
      end

      it "generates a unique slug by appending a counter to duplicate text" do
        15.times{ |x|
          dup = Book.create(:title => book.title)
          dup.to_param.should eql "a-thousand-plateaus-#{x+1}"
        }
      end

      it "does not update slug if slugged fields have not changed" do
        book.save
        book.to_param.should eql "a-thousand-plateaus"
      end

      it "does not change slug if slugged fields have changed but generated slug is identical" do
        book.title = "a thousand plateaus"
        book.save
        book.to_param.should eql "a-thousand-plateaus"
      end

      it "finds by slug" do
        Book.find_by_slug(book.to_param).should eql book
      end
    end

    context "when the slug is composed of multiple fields" do
      let!(:author) do
        Author.create(
          :first_name => "Gilles",
          :last_name => "Deleuze")
      end

      it "generates a slug" do
        author.to_param.should eql "gilles-deleuze"
      end

      it "updates the slug" do
        author.first_name = "Félix"
        author.last_name = "Guattari"
        author.save
        author.to_param.should eql "felix-guattari"
      end

      it "generates a unique slug by appending a counter to duplicate text" do
        dup = Author.create(
          :first_name => author.first_name,
          :last_name => author.last_name)
        dup.to_param.should eql 'gilles-deleuze-1'

        dup2 = Author.create(
          :first_name => author.first_name,
          :last_name => author.last_name)

        dup.save
        dup2.to_param.should eql 'gilles-deleuze-2'
      end

      it "does not update slug if slugged fields have changed but generated slug is identical" do
        author.last_name = "DELEUZE"
        author.save
        author.to_param.should eql 'gilles-deleuze'
      end

      it "finds by slug" do
        Author.find_by_slug("gilles-deleuze").should eql author
      end
    end

    context "when :slug is given a block" do
      let(:caption) do
        Caption.create(:identity => 'Edward Hopper (American, 1882-1967)',
                       :title => 'Soir Bleu, 1914',
                       :medium => 'Oil on Canvas')
      end

      it "generates a slug" do
        caption.to_param.should eql 'edward-hopper-soir-bleu-1914'
      end

      it "updates the slug" do
        caption.title = 'Road in Maine, 1914'
        caption.save
        caption.to_param.should eql "edward-hopper-road-in-maine-1914"
      end

      it "does not change slug if slugged fields have changed but generated slug is identical" do
        caption.identity = 'Edward Hopper'
        caption.save
        caption.to_param.should eql 'edward-hopper-soir-bleu-1914'
      end

      it "finds by slug" do
        Caption.find_by_slug(caption.to_param).should eql caption
      end
    end

    context "when :index is passed as an argument" do
      before do
        Book.collection.drop_indexes
        Author.collection.drop_indexes
      end

      it "defines an index on the slug in top-level objects" do
        Book.create_indexes
        Book.collection.index_information.should have_key "slug_1"
      end

      context "when slug is not scoped by a reference association" do
        it "defines a unique index" do
          Book.create_indexes
          Book.index_information["slug_1"]["unique"].should be_true
        end
      end
    end

    context "when :index is not passed as an argument" do
      it "does not define an index on the slug" do
        Person.create_indexes
        Person.collection.index_information.should_not have_key "permalink_1"
      end
    end

    context "when the object has STI" do
      it "scopes by the superclass" do
        book = Book.create(:title => "Anti Oedipus")
        comic_book = ComicBook.create(:title => "Anti Oedipus")
        comic_book.slug.should_not eql(book.slug)
      end
    end

    describe ".find_by_slug" do
      let!(:book) { Book.create(:title => "A Thousand Plateaus") }

      it "returns nil if no document is found" do
        Book.find_by_slug(:title => "Anti Oedipus").should be_nil
      end

      it "returns the document if it is found" do
        Book.find_by_slug(book.slug).should == book
      end
    end

    describe ".find_by_slug!" do
      let!(:book) { Book.create(:title => "A Thousand Plateaus") }

      it "raises a Mongoid::Errors::DocumentNotFound error if no document is found" do
        lambda {
          Book.find_by_slug!(:title => "Anti Oedipus")
        }.should raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it "returns the document when it is found" do
        Book.find_by_slug!(book.slug).should == book
      end
    end
  end
end
