mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Network = require './Network'

Application = new Schema
  Name : 
    type : String
    required : true
  AppKey : 
    type : String
    required : true
  AppSecret : 
    type : String
    required : true
  RedirectUrl :
    type : String
  
  Network : 
    type : ObjectId
    ref : 'Network'
    
  CreatedDate : 
    type : Date
    default : Date.now
  ModifiedDate : 
    type : Date
    default : Date.now

module.exports = Application