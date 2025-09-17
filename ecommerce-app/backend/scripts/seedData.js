const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Category = require('../models/Category');
const Product = require('../models/Product');

const seedData = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce');
    console.log('Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Category.deleteMany({});
    await Product.deleteMany({});
    console.log('Cleared existing data');

    // Create admin user
    const adminUser = new User({
      firstName: 'Admin',
      lastName: 'User',
      email: 'admin@shophub.com',
      password: 'admin123',
      role: 'admin',
      isEmailVerified: true
    });
    await adminUser.save();

    // Create sample customer
    const customerUser = new User({
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      password: 'password123',
      role: 'customer',
      isEmailVerified: true
    });
    await customerUser.save();

    console.log('Created users');

    // Create categories
    const categories = [
      {
        name: 'Electronics',
        description: 'Latest electronic gadgets and devices',
        image: '/images/categories/electronics.jpg'
      },
      {
        name: 'Clothing',
        description: 'Fashion and apparel for all occasions',
        image: '/images/categories/clothing.jpg'
      },
      {
        name: 'Home & Garden',
        description: 'Everything for your home and garden',
        image: '/images/categories/home-garden.jpg'
      },
      {
        name: 'Sports & Outdoors',
        description: 'Sports equipment and outdoor gear',
        image: '/images/categories/sports.jpg'
      },
      {
        name: 'Books',
        description: 'Books for every reader',
        image: '/images/categories/books.jpg'
      }
    ];

    const createdCategories = await Category.insertMany(categories);
    console.log('Created categories');

    // Create sample products
    const products = [
      // Electronics
      {
        name: 'iPhone 15 Pro',
        description: 'The latest iPhone with advanced camera system and powerful A17 Pro chip. Features titanium design, Action Button, and USB-C connectivity.',
        shortDescription: 'Latest iPhone with A17 Pro chip and titanium design',
        sku: 'IPHONE15PRO',
        price: 999.99,
        comparePrice: 1099.99,
        category: createdCategories[0]._id,
        brand: 'Apple',
        images: [
          { url: '/images/products/iphone15pro.jpg', alt: 'iPhone 15 Pro', isPrimary: true }
        ],
        variants: [
          { name: 'Color', options: ['Natural Titanium', 'Blue Titanium', 'White Titanium', 'Black Titanium'] },
          { name: 'Storage', options: ['128GB', '256GB', '512GB', '1TB'] }
        ],
        specifications: [
          { name: 'Display', value: '6.1-inch Super Retina XDR' },
          { name: 'Chip', value: 'A17 Pro' },
          { name: 'Camera', value: '48MP Main, 12MP Ultra Wide, 12MP Telephoto' },
          { name: 'Battery', value: 'Up to 23 hours video playback' }
        ],
        tags: ['smartphone', 'apple', 'ios', 'premium'],
        quantity: 50,
        featured: true,
        weight: { value: 187, unit: 'g' },
        dimensions: { length: 14.67, width: 7.09, height: 0.83, unit: 'cm' }
      },
      {
        name: 'MacBook Air M2',
        description: 'Supercharged by M2 chip for incredible performance. Features a stunning 13.6-inch Liquid Retina display and all-day battery life.',
        shortDescription: 'Lightweight laptop with M2 chip and Liquid Retina display',
        sku: 'MACBOOKAIRM2',
        price: 1199.99,
        comparePrice: 1299.99,
        category: createdCategories[0]._id,
        brand: 'Apple',
        images: [
          { url: '/images/products/macbook-air-m2.jpg', alt: 'MacBook Air M2', isPrimary: true }
        ],
        variants: [
          { name: 'Color', options: ['Space Gray', 'Silver', 'Starlight', 'Midnight'] },
          { name: 'Memory', options: ['8GB', '16GB', '24GB'] },
          { name: 'Storage', options: ['256GB', '512GB', '1TB', '2TB'] }
        ],
        specifications: [
          { name: 'Display', value: '13.6-inch Liquid Retina' },
          { name: 'Chip', value: 'Apple M2' },
          { name: 'Memory', value: '8GB unified memory' },
          { name: 'Battery', value: 'Up to 18 hours' }
        ],
        tags: ['laptop', 'apple', 'macbook', 'm2'],
        quantity: 30,
        featured: true,
        weight: { value: 1.24, unit: 'kg' }
      },

      // Clothing
      {
        name: 'Classic Denim Jacket',
        description: 'Timeless denim jacket made from premium cotton denim. Perfect for layering and suitable for all seasons.',
        shortDescription: 'Premium cotton denim jacket for all seasons',
        sku: 'DENIMJACKET01',
        price: 89.99,
        comparePrice: 119.99,
        category: createdCategories[1]._id,
        brand: 'Urban Style',
        images: [
          { url: '/images/products/denim-jacket.jpg', alt: 'Classic Denim Jacket', isPrimary: true }
        ],
        variants: [
          { name: 'Size', options: ['XS', 'S', 'M', 'L', 'XL', 'XXL'] },
          { name: 'Color', options: ['Light Blue', 'Dark Blue', 'Black'] }
        ],
        specifications: [
          { name: 'Material', value: '100% Cotton Denim' },
          { name: 'Fit', value: 'Regular Fit' },
          { name: 'Care', value: 'Machine Wash Cold' }
        ],
        tags: ['jacket', 'denim', 'casual', 'cotton'],
        quantity: 100,
        featured: true
      },
      {
        name: 'Organic Cotton T-Shirt',
        description: 'Soft and comfortable organic cotton t-shirt. Sustainably made with eco-friendly materials.',
        shortDescription: 'Sustainable organic cotton t-shirt',
        sku: 'ORGCOTTONTEE',
        price: 24.99,
        category: createdCategories[1]._id,
        brand: 'EcoWear',
        images: [
          { url: '/images/products/organic-tshirt.jpg', alt: 'Organic Cotton T-Shirt', isPrimary: true }
        ],
        variants: [
          { name: 'Size', options: ['XS', 'S', 'M', 'L', 'XL'] },
          { name: 'Color', options: ['White', 'Black', 'Navy', 'Gray', 'Forest Green'] }
        ],
        specifications: [
          { name: 'Material', value: '100% Organic Cotton' },
          { name: 'Certification', value: 'GOTS Certified' },
          { name: 'Fit', value: 'Relaxed Fit' }
        ],
        tags: ['t-shirt', 'organic', 'sustainable', 'cotton'],
        quantity: 200
      },

      // Home & Garden
      {
        name: 'Smart Home Security Camera',
        description: 'Advanced wireless security camera with 4K video, night vision, and AI-powered motion detection. Easy setup and mobile app control.',
        shortDescription: '4K wireless security camera with AI motion detection',
        sku: 'SMARTHOMECAM',
        price: 199.99,
        comparePrice: 249.99,
        category: createdCategories[2]._id,
        brand: 'SecureHome',
        images: [
          { url: '/images/products/security-camera.jpg', alt: 'Smart Security Camera', isPrimary: true }
        ],
        specifications: [
          { name: 'Resolution', value: '4K Ultra HD' },
          { name: 'Field of View', value: '130° diagonal' },
          { name: 'Night Vision', value: 'Color night vision up to 25ft' },
          { name: 'Storage', value: 'Cloud & Local (microSD)' }
        ],
        tags: ['security', 'camera', 'smart-home', 'wireless'],
        quantity: 75,
        featured: true
      },

      // Sports & Outdoors
      {
        name: 'Professional Yoga Mat',
        description: 'High-quality yoga mat with superior grip and cushioning. Made from eco-friendly materials for comfortable practice.',
        shortDescription: 'Eco-friendly yoga mat with superior grip',
        sku: 'YOGAMATPRO',
        price: 59.99,
        category: createdCategories[3]._id,
        brand: 'YogaLife',
        images: [
          { url: '/images/products/yoga-mat.jpg', alt: 'Professional Yoga Mat', isPrimary: true }
        ],
        variants: [
          { name: 'Color', options: ['Purple', 'Blue', 'Pink', 'Green', 'Black'] },
          { name: 'Thickness', options: ['4mm', '6mm', '8mm'] }
        ],
        specifications: [
          { name: 'Material', value: 'Natural Rubber & TPE' },
          { name: 'Dimensions', value: '183cm x 61cm' },
          { name: 'Weight', value: '1.5kg' }
        ],
        tags: ['yoga', 'fitness', 'mat', 'eco-friendly'],
        quantity: 120
      },

      // Books
      {
        name: 'The Art of Programming',
        description: 'Comprehensive guide to modern programming practices and software development. Perfect for beginners and experienced developers.',
        shortDescription: 'Complete guide to modern programming practices',
        sku: 'ARTPROGRAMMING',
        price: 39.99,
        category: createdCategories[4]._id,
        brand: 'TechBooks',
        images: [
          { url: '/images/products/programming-book.jpg', alt: 'The Art of Programming', isPrimary: true }
        ],
        specifications: [
          { name: 'Pages', value: '450' },
          { name: 'Format', value: 'Paperback' },
          { name: 'Language', value: 'English' },
          { name: 'ISBN', value: '978-1234567890' }
        ],
        tags: ['programming', 'book', 'software', 'development'],
        quantity: 80,
        isDigital: false,
        requiresShipping: true
      }
    ];

    // Add ratings to some products
    products[0].reviews = [
      {
        user: customerUser._id,
        rating: 5,
        comment: 'Amazing phone! The camera quality is incredible.',
        verified: true
      }
    ];

    products[2].reviews = [
      {
        user: customerUser._id,
        rating: 4,
        comment: 'Great quality denim jacket. Fits perfectly!',
        verified: true
      }
    ];

    const createdProducts = await Product.insertMany(products);
    console.log('Created products');

    console.log('✅ Seed data created successfully!');
    console.log(`Created ${createdCategories.length} categories`);
    console.log(`Created ${createdProducts.length} products`);
    console.log(`Created 2 users (admin: admin@shophub.com, customer: john@example.com)`);
    console.log('Default password for all users: password123 (admin: admin123)');

  } catch (error) {
    console.error('Error seeding data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
};

seedData();
