import React, { useState, useEffect } from 'react';
import { useQuery } from 'react-query';
import { useSearchParams } from 'react-router-dom';
import { productService, categoryService } from '../services';
import { ProductCard, ProductFilters, Pagination, LoadingSkeleton } from '../components';

const Products = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [filters, setFilters] = useState({
    page: parseInt(searchParams.get('page')) || 1,
    limit: 12,
    search: searchParams.get('search') || '',
    category: searchParams.get('category') || '',
    minPrice: searchParams.get('minPrice') || '',
    maxPrice: searchParams.get('maxPrice') || '',
    rating: searchParams.get('rating') || '',
    sort: searchParams.get('sort') || 'newest',
    brands: searchParams.get('brands')?.split(',').filter(Boolean) || [],
    categories: searchParams.get('categories')?.split(',').filter(Boolean) || []
  });

  const [sortBy, setSortBy] = useState(filters.sort);

  // Fetch products
  const { data: productsData, isLoading: productsLoading, error: productsError } = useQuery(
    ['products', filters],
    () => productService.getProducts(filters),
    {
      keepPreviousData: true
    }
  );

  // Fetch categories for filters
  const { data: categoriesData } = useQuery(
    'categories',
    categoryService.getCategories
  );

  // Update URL when filters change
  useEffect(() => {
    const params = new URLSearchParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value && value !== '' && !(Array.isArray(value) && value.length === 0)) {
        if (Array.isArray(value)) {
          params.set(key, value.join(','));
        } else {
          params.set(key, value.toString());
        }
      }
    });
    setSearchParams(params);
  }, [filters, setSearchParams]);

  const handleFilterChange = (newFilters) => {
    setFilters(prev => ({
      ...prev,
      ...newFilters,
      page: 1 // Reset to first page when filters change
    }));
  };

  const handlePageChange = (page) => {
    setFilters(prev => ({ ...prev, page }));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleSortChange = (sort) => {
    setSortBy(sort);
    setFilters(prev => ({ ...prev, sort, page: 1 }));
  };

  const clearFilters = () => {
    setFilters({
      page: 1,
      limit: 12,
      search: '',
      category: '',
      minPrice: '',
      maxPrice: '',
      rating: '',
      sort: 'newest',
      brands: [],
      categories: []
    });
    setSortBy('newest');
  };

  // Get unique brands from products for filter
  const brands = React.useMemo(() => {
    if (!productsData?.products) return [];
    const uniqueBrands = [...new Set(
      productsData.products
        .map(product => product.brand)
        .filter(Boolean)
    )];
    return uniqueBrands.sort();
  }, [productsData]);

  if (productsError) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Error Loading Products</h2>
          <p className="text-gray-600">Sorry, we couldn't load the products. Please try again later.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-4">Products</h1>
        {filters.search && (
          <p className="text-gray-600">
            Search results for: <span className="font-medium">"{filters.search}"</span>
          </p>
        )}
      </div>

      <div className="flex flex-col lg:flex-row gap-8">
        {/* Filters Sidebar */}
        <div className="lg:w-64 flex-shrink-0">
          <ProductFilters
            filters={filters}
            onFilterChange={handleFilterChange}
            categories={categoriesData?.categories || []}
            brands={brands}
            priceRange={{ min: 0, max: 2000 }}
          />
        </div>

        {/* Main Content */}
        <div className="flex-1">
          {/* Results Header */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6">
            <div className="mb-4 sm:mb-0">
              {productsData?.pagination && (
                <p className="text-sm text-gray-700">
                  Showing{' '}
                  <span className="font-medium">
                    {((productsData.pagination.currentPage - 1) * productsData.pagination.limit) + 1}
                  </span>{' '}
                  to{' '}
                  <span className="font-medium">
                    {Math.min(
                      productsData.pagination.currentPage * productsData.pagination.limit,
                      productsData.pagination.totalProducts
                    )}
                  </span>{' '}
                  of{' '}
                  <span className="font-medium">{productsData.pagination.totalProducts}</span>{' '}
                  results
                </p>
              )}
            </div>

            {/* Sort Dropdown */}
            <div className="flex items-center space-x-4">
              <label htmlFor="sort" className="text-sm font-medium text-gray-700">
                Sort by:
              </label>
              <select
                id="sort"
                value={sortBy}
                onChange={(e) => handleSortChange(e.target.value)}
                className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="newest">Newest</option>
                <option value="popular">Most Popular</option>
                <option value="price_asc">Price: Low to High</option>
                <option value="price_desc">Price: High to Low</option>
                <option value="rating">Highest Rated</option>
                <option value="name">Name: A to Z</option>
              </select>
            </div>
          </div>

          {/* Active Filters */}
          {(filters.search || filters.category || filters.minPrice || filters.maxPrice || 
            filters.rating || filters.brands.length > 0 || filters.categories.length > 0) && (
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-sm font-medium text-gray-700">Active Filters:</h3>
                <button
                  onClick={clearFilters}
                  className="text-sm text-primary-600 hover:text-primary-500"
                >
                  Clear All
                </button>
              </div>
              <div className="flex flex-wrap gap-2">
                {filters.search && (
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    Search: {filters.search}
                  </span>
                )}
                {filters.minPrice && (
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    Min: ${filters.minPrice}
                  </span>
                )}
                {filters.maxPrice && (
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    Max: ${filters.maxPrice}
                  </span>
                )}
                {filters.rating && (
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    Rating: {filters.rating}+ stars
                  </span>
                )}
              </div>
            </div>
          )}

          {/* Products Grid */}
          {productsLoading ? (
            <LoadingSkeleton />
          ) : productsData?.products?.length > 0 ? (
            <>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
                {productsData.products.map((product) => (
                  <ProductCard key={product._id} product={product} />
                ))}
              </div>

              {/* Pagination */}
              {productsData.pagination && productsData.pagination.totalPages > 1 && (
                <Pagination
                  currentPage={productsData.pagination.currentPage}
                  totalPages={productsData.pagination.totalPages}
                  onPageChange={handlePageChange}
                />
              )}
            </>
          ) : (
            <div className="text-center py-12">
              <div className="w-24 h-24 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2 2v-5m16 0h-2M4 13h2m-2 0V9a2 2 0 012-2h2m0 0V6a2 2 0 012-2h12a2 2 0 012 2v1M4 9h16" />
                </svg>
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">No products found</h3>
              <p className="text-gray-500 mb-4">
                Try adjusting your search criteria or filters to find what you're looking for.
              </p>
              <button
                onClick={clearFilters}
                className="btn-primary"
              >
                Clear Filters
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Products;
