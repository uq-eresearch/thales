
require 'uuid'
require 'thales/properties/basic/collection'

class RecordsController < ApplicationController
  # GET /records
  # GET /records.json
  def index
    @records = Record.all

    @entries = @records.map { |rec| [ rec, collection_load(rec) ] }
  
    @entries.sort! { |a,b| a[1].title <=> b[1].title }

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

    prop = PropertyRecord.new
    prop.order = 1
    prop.value = collection.serialize
    prop.save()

    @record = Record.new(params[:record])
    @record.uuid = UUID.new.generate(:compact)
    @record.property_records << prop

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

    prop = @record.property_records.first
    prop.value = collection.serialize()
    prop.save()

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

  def collection_load(record)
    properties = record.property_records
    if properties.size != 1
      # Expecting only one property in this current implementation
      raise "Internal error: multiple properties found"
    end

    Properties::Basic::Collection.deserialize(record.property_records.first.value)
  end

end
