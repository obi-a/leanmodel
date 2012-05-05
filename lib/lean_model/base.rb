module LeanModel
 class Base
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  attr_accessor :database_token
  attr_accessor :doc_id
  
  class_attribute :_attributes
  self._attributes = []


  attribute_method_prefix 'clear_'
  
  attribute_method_suffix '?' 

  def initialize(attributes = {})
    attributes.each do |attr, value|
      self.send("#{attr}=",value)
    end unless attributes.blank?
  end

  def self.attributes(*names)
    attr_accessor *names

    define_attribute_methods names
    self._attributes += names
  end

 def attributes
  self._attributes.inject({}) do |hash,attr|
    hash[attr.to_s] = send(attr)
    hash
  end
 end

 def persisted?
   false
 end

#database functions
 def config(token)
   @database_token = token
 end

 def token
  if @database_token.lambda?
     @database_token.call
  end
 end

  def database
    self.class.name.split('::').last.downcase + 's'
  end

 def all
  #returns hash of all key/values in the database
  docs = Couchdb.docs_from database,token
 end

 def find(id)
  #returns a model object with the given ID
  doc = {:database => database, :doc_id => id}
  hash = Couchdb.view doc,token
 end

 def save
   #save this model object to database
   if self.valid?
    @doc_id = UUIDTools::UUID.random_create.to_s
    doc = { :database => database, :doc_id => @doc_id, :data => attributes}   
    Couchdb.create_doc doc,token
    true
   else
    false
   end
 end

 def service
  self
 end

 def update_attributes(hash)
   #update this model on database
   if self.valid?
    id = hash[:id]
    hash.delete(:id)
    doc = { :database => database, :doc_id => id, :data => hash}   
    Couchdb.update_doc doc,token
    true
   else
    false
   end
 end

 def destroy
   #delete this model from database
   doc = {:database => database, :doc_id => @doc_id}
   Couchdb.delete_doc doc,token
 end

 #end of database functions
 protected 
  def clear_attribute(attribute)
    send("#{attribute}=",nil)
  end

  def attribute?(attribute)
    send(attribute).present?
  end
 end
end
