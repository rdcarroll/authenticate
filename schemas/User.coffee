mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
  
Action = new Schema
  Network : 
    type : ObjectId
    ref : 'Network'
  Application : 
    type : ObjectId
    ref : 'Application'
  Username : 
    type : String
    required : true
  RefreshToken :
    type : String
  AccessToken :
    type : String
    
  CreatedDate : 
    type : Date
    default : Date.now
  ModifiedDate : 
    type : Date
    default : Date.now

module.exports = Action