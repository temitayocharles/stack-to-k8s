import React, { useState } from 'react';
import { ChevronDownIcon, XMarkIcon } from '@heroicons/react/24/outline';

const ProductFilters = ({ 
  filters, 
  onFilterChange, 
  categories = [], 
  brands = [],
  priceRange = { min: 0, max: 1000 }
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [expandedSections, setExpandedSections] = useState({
    category: true,
    price: true,
    brand: true,
    rating: true
  });

  const toggleSection = (section) => {
    setExpandedSections(prev => ({
      ...prev,
      [section]: !prev[section]
    }));
  };

  const handlePriceChange = (type, value) => {
    onFilterChange({
      ...filters,
      [type]: value
    });
  };

  const handleCategoryChange = (categoryId) => {
    const newCategories = filters.categories?.includes(categoryId)
      ? filters.categories.filter(id => id !== categoryId)
      : [...(filters.categories || []), categoryId];
    
    onFilterChange({
      ...filters,
      categories: newCategories
    });
  };

  const handleBrandChange = (brand) => {
    const newBrands = filters.brands?.includes(brand)
      ? filters.brands.filter(b => b !== brand)
      : [...(filters.brands || []), brand];
    
    onFilterChange({
      ...filters,
      brands: newBrands
    });
  };

  const clearFilters = () => {
    onFilterChange({});
  };

  const hasActiveFilters = Object.keys(filters).some(key => 
    filters[key] && (Array.isArray(filters[key]) ? filters[key].length > 0 : true)
  );

  return (
    <>
      {/* Mobile Filter Button */}
      <div className="lg:hidden mb-4">
        <button
          onClick={() => setIsOpen(true)}
          className="flex items-center justify-center w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
        >
          Filters
          {hasActiveFilters && (
            <span className="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
              Active
            </span>
          )}
        </button>
      </div>

      {/* Filter Sidebar */}
      <div className={`
        ${isOpen ? 'fixed inset-0 z-50 lg:relative lg:inset-auto' : 'hidden lg:block'}
        lg:w-64 lg:flex-shrink-0
      `}>
        {/* Mobile Overlay */}
        {isOpen && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 lg:hidden"
            onClick={() => setIsOpen(false)}
          />
        )}

        {/* Filter Content */}
        <div className={`
          ${isOpen ? 'fixed right-0 top-0 h-full w-80 transform translate-x-0' : ''}
          lg:relative lg:w-full lg:h-auto lg:transform-none
          bg-white lg:bg-transparent overflow-y-auto lg:overflow-visible
          border-l lg:border-l-0 lg:border-r border-gray-200
        `}>
          {/* Mobile Header */}
          <div className="lg:hidden flex items-center justify-between p-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">Filters</h2>
            <button
              onClick={() => setIsOpen(false)}
              className="p-2 text-gray-400 hover:text-gray-500"
            >
              <XMarkIcon className="w-6 h-6" />
            </button>
          </div>

          <div className="p-4 lg:p-0 space-y-6">
            {/* Clear Filters */}
            {hasActiveFilters && (
              <div className="flex justify-between items-center">
                <span className="text-sm font-medium text-gray-900">Active Filters</span>
                <button
                  onClick={clearFilters}
                  className="text-sm text-primary-600 hover:text-primary-500"
                >
                  Clear All
                </button>
              </div>
            )}

            {/* Categories */}
            <div className="border-b border-gray-200 pb-6">
              <button
                onClick={() => toggleSection('category')}
                className="flex w-full items-center justify-between text-sm font-medium text-gray-900"
              >
                Categories
                <ChevronDownIcon 
                  className={`w-5 h-5 transform transition-transform ${
                    expandedSections.category ? 'rotate-180' : ''
                  }`} 
                />
              </button>
              {expandedSections.category && (
                <div className="mt-4 space-y-3">
                  {categories.map((category) => (
                    <label key={category._id} className="flex items-center">
                      <input
                        type="checkbox"
                        checked={filters.categories?.includes(category._id) || false}
                        onChange={() => handleCategoryChange(category._id)}
                        className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                      />
                      <span className="ml-3 text-sm text-gray-700">{category.name}</span>
                    </label>
                  ))}
                </div>
              )}
            </div>

            {/* Price Range */}
            <div className="border-b border-gray-200 pb-6">
              <button
                onClick={() => toggleSection('price')}
                className="flex w-full items-center justify-between text-sm font-medium text-gray-900"
              >
                Price Range
                <ChevronDownIcon 
                  className={`w-5 h-5 transform transition-transform ${
                    expandedSections.price ? 'rotate-180' : ''
                  }`} 
                />
              </button>
              {expandedSections.price && (
                <div className="mt-4 space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs font-medium text-gray-700">Min</label>
                      <input
                        type="number"
                        min={priceRange.min}
                        max={priceRange.max}
                        value={filters.minPrice || ''}
                        onChange={(e) => handlePriceChange('minPrice', e.target.value)}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                        placeholder="0"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-medium text-gray-700">Max</label>
                      <input
                        type="number"
                        min={priceRange.min}
                        max={priceRange.max}
                        value={filters.maxPrice || ''}
                        onChange={(e) => handlePriceChange('maxPrice', e.target.value)}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                        placeholder="1000"
                      />
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Brands */}
            {brands.length > 0 && (
              <div className="border-b border-gray-200 pb-6">
                <button
                  onClick={() => toggleSection('brand')}
                  className="flex w-full items-center justify-between text-sm font-medium text-gray-900"
                >
                  Brands
                  <ChevronDownIcon 
                    className={`w-5 h-5 transform transition-transform ${
                      expandedSections.brand ? 'rotate-180' : ''
                    }`} 
                  />
                </button>
                {expandedSections.brand && (
                  <div className="mt-4 space-y-3">
                    {brands.map((brand) => (
                      <label key={brand} className="flex items-center">
                        <input
                          type="checkbox"
                          checked={filters.brands?.includes(brand) || false}
                          onChange={() => handleBrandChange(brand)}
                          className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                        />
                        <span className="ml-3 text-sm text-gray-700">{brand}</span>
                      </label>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Rating */}
            <div className="pb-6">
              <button
                onClick={() => toggleSection('rating')}
                className="flex w-full items-center justify-between text-sm font-medium text-gray-900"
              >
                Customer Rating
                <ChevronDownIcon 
                  className={`w-5 h-5 transform transition-transform ${
                    expandedSections.rating ? 'rotate-180' : ''
                  }`} 
                />
              </button>
              {expandedSections.rating && (
                <div className="mt-4 space-y-3">
                  {[4, 3, 2, 1].map((rating) => (
                    <label key={rating} className="flex items-center">
                      <input
                        type="radio"
                        name="rating"
                        checked={filters.rating === rating}
                        onChange={() => onFilterChange({ ...filters, rating })}
                        className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300"
                      />
                      <span className="ml-3 flex items-center">
                        <div className="flex items-center">
                          {[...Array(5)].map((_, i) => (
                            <svg
                              key={i}
                              className={`w-4 h-4 ${
                                i < rating ? 'text-yellow-400' : 'text-gray-300'
                              }`}
                              fill="currentColor"
                              viewBox="0 0 20 20"
                            >
                              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                            </svg>
                          ))}
                        </div>
                        <span className="ml-2 text-sm text-gray-600">& Up</span>
                      </span>
                    </label>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default ProductFilters;
