class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_default_format
  
  protected
  
  def set_default_format
    request.format = :json
  end
  
  def render_success(data = {}, message = nil, status = :ok)
    response = { success: true }
    response[:message] = message if message
    response[:data] = data unless data.empty?
    
    render json: response, status: status
  end
  
  def render_error(message, status = :unprocessable_entity, details = nil)
    response = { 
      success: false, 
      error: message 
    }
    response[:details] = details if details
    
    render json: response, status: status
  end
  
  def render_validation_errors(record)
    render json: {
      success: false,
      error: 'Validation failed',
      details: record.errors.full_messages
    }, status: :unprocessable_entity
  end
  
  def pagination_meta(collection)
    {
      current_page: collection.respond_to?(:current_page) ? collection.current_page : 1,
      total_pages: collection.respond_to?(:total_pages) ? collection.total_pages : 1,
      total_count: collection.respond_to?(:total_count) ? collection.total_count : collection.count,
      per_page: collection.respond_to?(:limit_value) ? collection.limit_value : collection.count
    }
  end
  
  def paginate_collection(collection, page: params[:page], per_page: params[:per_page])
    page = [page.to_i, 1].max
    per_page = [[per_page.to_i, 1].max, 50].min # Max 50 items per page
    
    if collection.respond_to?(:page)
      collection.page(page).per(per_page)
    else
      offset = (page - 1) * per_page
      collection.limit(per_page).offset(offset)
    end
  end
end
