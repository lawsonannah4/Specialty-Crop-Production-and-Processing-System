# Specialty Crop Production and Processing System

A comprehensive blockchain-based system for managing specialty crop production, processing, and market coordination using Clarity smart contracts.

## Overview

This system provides end-to-end management for specialty crop operations, from harvest planning to direct-to-consumer sales. It ensures transparency, quality control, and sustainable practices throughout the supply chain.

## Core Features

### 🌾 Crop Management
- Harvest timing optimization and scheduling
- Post-harvest handling tracking and quality metrics
- Crop variety and yield management
- Seasonal planning and resource allocation

### 🏭 Processing Facility Management
- Facility compliance monitoring and certification
- Quality standards enforcement and auditing
- Processing capacity planning and scheduling
- Equipment maintenance and safety tracking

### 🏆 Certification & Compliance
- Organic certification verification and maintenance
- Sustainable practice documentation and validation
- Regulatory compliance tracking and reporting
- Third-party audit management

### 💰 Marketplace & Pricing
- Transparent pricing mechanisms and market data
- Direct-to-consumer sales coordination
- Farmer market integration and scheduling
- Supply chain cost tracking and optimization

### 📊 Market Access Coordination
- Buyer-seller matching and relationship management
- Order fulfillment and delivery coordination
- Inventory management and demand forecasting
- Payment processing and settlement

## Smart Contract Architecture

The system consists of five interconnected Clarity smart contracts:

1. **crop-management.clar** - Core crop lifecycle and harvest management
2. **processing-facility.clar** - Processing operations and facility compliance
3. **certification-compliance.clar** - Certification tracking and regulatory compliance
4. **marketplace-pricing.clar** - Pricing mechanisms and market coordination
5. **market-access.clar** - Buyer-seller coordination and order management

## Data Models

### Crop Records
- Crop ID, variety, planting/harvest dates
- Quality metrics and yield data
- Processing requirements and handling instructions
- Certification status and compliance records

### Processing Facilities
- Facility registration and capacity information
- Compliance certifications and audit history
- Processing schedules and quality standards
- Equipment status and maintenance records

### Market Transactions
- Pricing data and market trends
- Order management and fulfillment tracking
- Payment processing and settlement records
- Customer relationship and feedback data

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Basic understanding of Clarity smart contracts

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd specialty-crop-system

# Install dependencies
npm install

# Initialize Clarinet project
clarinet check

# Run tests
npm test
\`\`\`

### Deployment

\`\`\`bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
\`\`\`

## Testing

The system includes comprehensive test coverage using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific test file
npm test crop-management.test.js

# Run tests with coverage
npm run test:coverage
