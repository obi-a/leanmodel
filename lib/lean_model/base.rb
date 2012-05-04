module LeanModel
 class Base
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods

  attr_accessor :database_token
  
  class_attribute :_attributes
  self._attributes = []


  attribute_method_prefix 'clear_'
  
  attribute_method_suffix '?' 

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

 def self.all
  #returns hash of all key/values in the database
 end

 def self.find(id)
  #returns a model object with the given ID
 end

 def save
   #save this model object to database
 end

 def update_attributes(hash)
   #update this model on database
 end

 def destroy
   #delete this model from database
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
