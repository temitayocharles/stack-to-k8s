const express = require('express');
const { body, validationResult } = require('express-validator');
const Product = require('../models/Product');
const Category = require('../models/Category');

const router = express.Router();

// @route   GET /api/search/products
// @desc    Advanced product search with filters, sorting, and faceted search
// @access  Public
router.get('/products', async (req, res) => {
  try {
    const {
      q,              // Search query
      category,       // Category filter
      minPrice,       // Minimum price
      maxPrice,       // Maximum price
      brand,          // Brand filter
      rating,         // Minimum rating
      inStock,        // In stock only
      sort,           // Sort option
      page = 1,       // Page number
      limit = 12,     // Items per page
      facets = true   // Include faceted search data
    } = req.query;

    // Build search query
    let searchQuery = { status: 'active' };

    // Text search across multiple fields
    if (q) {
      searchQuery.$or = [
        { name: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { brand: { $regex: q, $options: 'i' } },
        { tags: { $in: [new RegExp(q, 'i')] } },
        { sku: { $regex: q, $options: 'i' } }
      ];
    }

    // Category filter
    if (category) {
      if (Array.isArray(category)) {
        searchQuery.category = { $in: category };
      } else {
        searchQuery.category = category;
      }
    }

    // Price range filter
    if (minPrice || maxPrice) {
      searchQuery.price = {};
      if (minPrice) searchQuery.price.$gte = parseFloat(minPrice);
      if (maxPrice) searchQuery.price.$lte = parseFloat(maxPrice);
    }

    // Brand filter
    if (brand) {
      if (Array.isArray(brand)) {
        searchQuery.brand = { $in: brand };
      } else {
        searchQuery.brand = brand;
      }
    }

    // Rating filter
    if (rating) {
      searchQuery.averageRating = { $gte: parseFloat(rating) };
    }

    // Stock filter
    if (inStock === 'true') {
      searchQuery.quantity = { $gt: 0 };
    }

    // Build sort options
    let sortOptions = {};
    switch (sort) {
      case 'price_asc':
        sortOptions = { price: 1 };
        break;
      case 'price_desc':
        sortOptions = { price: -1 };
        break;
      case 'rating':
        sortOptions = { averageRating: -1, reviewCount: -1 };
        break;
      case 'newest':
        sortOptions = { createdAt: -1 };
        break;
      case 'popular':
        sortOptions = { salesCount: -1, viewCount: -1 };
        break;
      case 'name':
        sortOptions = { name: 1 };
        break;
      default:
        // Relevance score for text search
        if (q) {
          sortOptions = { score: { $meta: 'textScore' } };
        } else {
          sortOptions = { createdAt: -1 };
        }
    }

    // Add text score for relevance sorting
    let projection = {};
    if (q && sort === 'relevance') {
      projection.score = { $meta: 'textScore' };
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Execute main search query
    const products = await Product.find(searchQuery, projection)
      .populate('category', 'name slug')
      .sort(sortOptions)
      .skip(skip)
      .limit(parseInt(limit))
      .lean();

    // Get total count for pagination
    const total = await Product.countDocuments(searchQuery);

    // Build faceted search data if requested
    let facetData = {};
    if (facets === 'true' || facets === true) {
      facetData = await buildFacetData(searchQuery, q);
    }

    // Enhanced product data with additional computed fields
    const enhancedProducts = products.map(product => ({
      ...product,
      discountPercentage: product.originalPrice ? 
        Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100) : 0,
      isOnSale: product.originalPrice && product.originalPrice > product.price,
      isLowStock: product.quantity > 0 && product.quantity <= 5,
      isOutOfStock: product.quantity === 0,
      ratingStars: Math.round(product.averageRating || 0),
      formattedPrice: `$${product.price.toFixed(2)}`,
      formattedOriginalPrice: product.originalPrice ? `$${product.originalPrice.toFixed(2)}` : null
    }));

    // Build response
    const response = {
      products: enhancedProducts,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalProducts: total,
        hasNextPage: skip + parseInt(limit) < total,
        hasPrevPage: parseInt(page) > 1,
        limit: parseInt(limit)
      },
      filters: {
        query: q || '',
        category: category || null,
        priceRange: {
          min: minPrice ? parseFloat(minPrice) : null,
          max: maxPrice ? parseFloat(maxPrice) : null
        },
        brand: brand || null,
        minRating: rating ? parseFloat(rating) : null,
        inStockOnly: inStock === 'true',
        sort: sort || 'relevance'
      }
    };

    // Add facet data if requested
    if (Object.keys(facetData).length > 0) {
      response.facets = facetData;
    }

    res.json(response);
  } catch (error) {
    console.error('Product search error:', error);
    res.status(500).json({ message: 'Search operation failed' });
  }
});

// @route   GET /api/search/suggestions
// @desc    Search suggestions/autocomplete
// @access  Public
router.get('/suggestions', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.length < 2) {
      return res.json({ suggestions: [] });
    }

    const regex = new RegExp(q, 'i');

    // Get product name suggestions
    const productSuggestions = await Product.find(
      { 
        name: regex, 
        status: 'active' 
      },
      { name: 1 }
    )
    .limit(5)
    .lean();

    // Get brand suggestions
    const brandSuggestions = await Product.distinct('brand', {
      brand: regex,
      status: 'active'
    }).limit(3);

    // Get category suggestions
    const categorySuggestions = await Category.find(
      { name: regex },
      { name: 1, slug: 1 }
    )
    .limit(3)
    .lean();

    // Get popular search terms (simulated - in production, store actual search data)
    const popularTerms = [
      'laptop', 'smartphone', 'headphones', 'shoes', 'dress',
      'watch', 'bag', 'camera', 'tablet', 'keyboard'
    ].filter(term => term.toLowerCase().includes(q.toLowerCase())).slice(0, 3);

    const suggestions = {
      products: productSuggestions.map(p => ({
        type: 'product',
        text: p.name,
        value: p.name
      })),
      brands: brandSuggestions.map(brand => ({
        type: 'brand',
        text: brand,
        value: brand
      })),
      categories: categorySuggestions.map(cat => ({
        type: 'category',
        text: cat.name,
        value: cat.slug
      })),
      popular: popularTerms.map(term => ({
        type: 'popular',
        text: term,
        value: term
      }))
    };

    // Flatten and limit total suggestions
    const allSuggestions = [
      ...suggestions.products,
      ...suggestions.brands,
      ...suggestions.categories,
      ...suggestions.popular
    ].slice(0, 10);

    res.json({ suggestions: allSuggestions });
  } catch (error) {
    console.error('Search suggestions error:', error);
    res.status(500).json({ message: 'Failed to get suggestions' });
  }
});

// @route   POST /api/search/save-search
// @desc    Save user search for analytics and recommendations
// @access  Public (with optional authentication)
router.post('/save-search', async (req, res) => {
  try {
    const { query, filters, resultCount, userId } = req.body;

    // In production, save to a SearchLog collection
    const searchLog = {
      query: query || '',
      filters: filters || {},
      resultCount: parseInt(resultCount) || 0,
      userId: userId || null,
      timestamp: new Date(),
      sessionId: req.sessionID || 'anonymous',
      userAgent: req.get('User-Agent'),
      ip: req.ip
    };

    console.log('Search logged:', searchLog);

    // Update search analytics (in production, use proper analytics service)
    // This could be used for:
    // - Popular search terms
    // - Search result quality
    // - User behavior analysis
    // - Search recommendations

    res.json({ message: 'Search logged successfully' });
  } catch (error) {
    console.error('Save search error:', error);
    res.status(500).json({ message: 'Failed to log search' });
  }
});

// @route   GET /api/search/trending
// @desc    Get trending search terms and products
// @access  Public
router.get('/trending', async (req, res) => {
  try {
    // Get trending products based on views and sales
    const trendingProducts = await Product.find({ status: 'active' })
      .sort({ 
        viewCount: -1, 
        salesCount: -1, 
        createdAt: -1 
      })
      .limit(8)
      .populate('category', 'name')
      .select('name price originalPrice images averageRating reviewCount viewCount salesCount')
      .lean();

    // Simulated trending searches (in production, use actual search data)
    const trendingSearches = [
      { term: 'wireless headphones', count: 1250 },
      { term: 'gaming laptop', count: 890 },
      { term: 'running shoes', count: 675 },
      { term: 'smartphone case', count: 520 },
      { term: 'yoga mat', count: 445 },
      { term: 'coffee maker', count: 380 },
      { term: 'desk chair', count: 320 },
      { term: 'fitness tracker', count: 280 }
    ];

    // Get trending categories
    const trendingCategories = await Category.find()
      .sort({ productCount: -1 })
      .limit(6)
      .select('name slug productCount')
      .lean();

    res.json({
      products: trendingProducts.map(product => ({
        ...product,
        discountPercentage: product.originalPrice ? 
          Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100) : 0,
        isOnSale: product.originalPrice && product.originalPrice > product.price,
        formattedPrice: `$${product.price.toFixed(2)}`
      })),
      searches: trendingSearches,
      categories: trendingCategories,
      lastUpdated: new Date()
    });
  } catch (error) {
    console.error('Trending data error:', error);
    res.status(500).json({ message: 'Failed to get trending data' });
  }
});

// Helper function to build faceted search data
async function buildFacetData(baseQuery, searchTerm) {
  try {
    // Remove filters that we want to facet on
    const facetQuery = { ...baseQuery };
    delete facetQuery.category;
    delete facetQuery.brand;
    delete facetQuery.price;
    delete facetQuery.averageRating;

    // Get category facets
    const categoryFacets = await Product.aggregate([
      { $match: facetQuery },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $lookup: { from: 'categories', localField: '_id', foreignField: '_id', as: 'category' } },
      { $unwind: '$category' },
      { $project: { name: '$category.name', slug: '$category.slug', count: 1 } },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]);

    // Get brand facets
    const brandFacets = await Product.aggregate([
      { $match: facetQuery },
      { $group: { _id: '$brand', count: { $sum: 1 } } },
      { $match: { _id: { $ne: null } } },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]);

    // Get price range facets
    const priceStats = await Product.aggregate([
      { $match: facetQuery },
      {
        $group: {
          _id: null,
          minPrice: { $min: '$price' },
          maxPrice: { $max: '$price' },
          avgPrice: { $avg: '$price' }
        }
      }
    ]);

    // Define price ranges
    const priceRangeFacets = await Product.aggregate([
      { $match: facetQuery },
      {
        $bucket: {
          groupBy: '$price',
          boundaries: [0, 25, 50, 100, 200, 500, 1000, 10000],
          default: 'other',
          output: { count: { $sum: 1 } }
        }
      }
    ]);

    // Get rating facets
    const ratingFacets = await Product.aggregate([
      { $match: facetQuery },
      {
        $bucket: {
          groupBy: '$averageRating',
          boundaries: [0, 1, 2, 3, 4, 5],
          default: 'unrated',
          output: { count: { $sum: 1 } }
        }
      }
    ]);

    return {
      categories: categoryFacets,
      brands: brandFacets.map(b => ({ name: b._id, count: b.count })),
      priceRanges: priceRangeFacets.map(p => {
        let label;
        if (p._id === 'other') {
          label = '$1000+';
        } else {
          const ranges = {
            0: '$0 - $25',
            25: '$25 - $50',
            50: '$50 - $100',
            100: '$100 - $200',
            200: '$200 - $500',
            500: '$500 - $1000'
          };
          label = ranges[p._id] || `$${p._id}+`;
        }
        return { range: label, min: p._id === 'other' ? 1000 : p._id, count: p.count };
      }),
      ratings: ratingFacets.map(r => ({
        rating: r._id === 'unrated' ? 0 : r._id,
        label: r._id === 'unrated' ? 'Unrated' : `${r._id}+ stars`,
        count: r.count
      })),
      priceStats: priceStats[0] || { minPrice: 0, maxPrice: 0, avgPrice: 0 }
    };
  } catch (error) {
    console.error('Facet data error:', error);
    return {};
  }
}

module.exports = router;