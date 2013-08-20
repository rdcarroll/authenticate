mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Network = new Schema
  Name : 
    type : String
    required : true
  start_base_url : 
    type : String
  oauth_path : 
    type : String
  access_path :
    type : String
  grant_type :
    type : String
  response_type :
    type : String
  type :
    type : String
  feed_url :
    type : String
    
  CreatedDate : 
    type : Date
    default : Date.now
  ModifiedDate : 
    type : Date
    default : Date.now

module.exports = Network