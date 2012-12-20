# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'oaipmh_record'

# Ruby on Rails controller
#
# This is only used for debugging. Users should only change the
# OAI-PMH records through the record controller.

class OaipmhRecordsController < ApplicationController

  before_filter :authenticate

  # GET /oaipmh_records
  # GET /oaipmh_records.json
  def index
    @oaipmh_records = OaipmhRecord.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @oaipmh_records }
    end
  end

  # GET /oaipmh_records/1
  # GET /oaipmh_records/1.json
  def show
    @oaipmh_record = OaipmhRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @oaipmh_record }
    end
  end

  # GET /oaipmh_records/new
  # GET /oaipmh_records/new.json
  def new
    @oaipmh_record = OaipmhRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oaipmh_record }
    end
  end

  # GET /oaipmh_records/1/edit
  def edit
    @oaipmh_record = OaipmhRecord.find(params[:id])
  end

  # POST /oaipmh_records
  # POST /oaipmh_records.json
  def create
    @oaipmh_record = OaipmhRecord.new(params[:oaipmh_record])

    respond_to do |format|
      if @oaipmh_record.save
        format.html { redirect_to @oaipmh_record, notice: 'OAI-PMH record was successfully created.' }
        format.json { render json: @oaipmh_record, status: :created, location: @oaipmh_record }
      else
        format.html { render action: "new" }
        format.json { render json: @oaipmh_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /oaipmh_records/1
  # PUT /oaipmh_records/1.json
  def update
    @oaipmh_record = OaipmhRecord.find(params[:id])

    respond_to do |format|
      if @oaipmh_record.update_attributes(params[:oaipmh_record])
        format.html { redirect_to @oaipmh_record, notice: 'OAI-PMH record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @oaipmh_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oaipmh_records/1
  # DELETE /oaipmh_records/1.json
  def destroy
    @oaipmh_record = OaipmhRecord.find(params[:id])
    @oaipmh_record.destroy

    respond_to do |format|
      format.html { redirect_to oaipmh_records_url }
      format.json { head :no_content }
    end
  end
end
