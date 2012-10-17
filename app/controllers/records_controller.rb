
require 'uuid'
require 'thales/properties/basic/collection'

class RecordsController < ApplicationController
  # GET /records
  # GET /records.json
  def index

    @records = Record.all

    @entries = @records.map { |rec| [ rec, collection_load(rec) ] }
  
#   @entries.sort! { |a,b| a[1].title <=> b[1].title }
#   @entries.sort! { |a,b| b[0].uuid <=> a[0].uuid }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @records }
    end
  end

  # GET /records/1
  # GET /records/1.json
  def show

    @record = Record.find(params[:id])
    @collection = collection_load(@record)

    @collection.valid?
    @msg = @collection.to_json

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/new
  # GET /records/new.json
  def new
    @record = Record.new
    @collection = collection_new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/1/edit
  def edit
    @record = Record.find(params[:id])
    @collection = collection_load(@record)
  end

  # POST /records
  # POST /records.json
  def create

    collection = Properties::Basic::Collection.new(params[:collection])

    entry = Entry.new
    entry.property_id = edit_collection_property_id
    entry.order = 1
    entry.value = collection.serialize
    entry.save()

    @record = Record.new(params[:record])
    @record.uuid = UUID.new.generate(:compact)
    @record.entries << entry

    if @record.save
      redirect_to @record, notice: 'Record was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /records/1
  # PUT /records/1.json
  def update
    collection = Properties::Basic::Collection.new(params[:collection])

    @record = Record.find(params[:id])

    entries = @record.entries.where(:property_id => edit_collection_property_id)
    if entries.size != 1
      # Expecting only one "edit collection" property in this current implementation
      raise "Internal error: incorrect number of 'edit collection' entries in record: #{entries.size} found, expecting 1"
    end
    entry = entries.first

    entry.value = collection.serialize()
    entry.save()

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to @record, notice: 'Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record = Record.find(params[:id])
    @record.destroy

    respond_to do |format|
      format.html { redirect_to records_url }
      format.json { head :no_content }
    end
  end


  def collection_new
    Properties::Basic::Collection.new
  end

  # Given a record, obtain the 'Test metadata format' property and
  # parse it into a collection.

  def collection_load(record)

    entries = record.entries.where(:property_id => edit_collection_property_id)
    if entries.size != 1
      # Expecting only one "edit collection" property in this current implementation
      raise "Internal error: incorrect number of 'edit collection' entries in record: #{entries.size} found, expecting 1"
    end

    Properties::Basic::Collection.deserialize(entries.first.value)
  end

  def edit_collection_property_id
    # Obtain the internal ID for the 'test collection' property

    edit_collection_uuid = 'd4cdb36b73a94b5295ac93232d5ce7b1'

    relation = Property.where(:uuid => edit_collection_uuid)
    if relation.size != 1
      raise "Internal error: property #{edit_collection_uuid}: expecting 1, #{relation.size} found"
    end
    
    relation.first.id # result
  end

end
