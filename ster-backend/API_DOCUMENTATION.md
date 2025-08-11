# STER Car Rental API Documentation

## Base URL
```
http://localhost:1337/api
```

## Authentication
Currently, all endpoints are set to `auth: false` for development. In production, you should implement proper authentication.

## Car API Endpoints

### 1. Search Cars with Advanced Filters
**GET** `/cars/search`

**Query Parameters:**
- `query` (string) - Text search in car name and description
- `category` (string) - Filter by category ID
- `location` (string) - Filter by location
- `minPrice` (number) - Minimum price per day
- `maxPrice` (number) - Maximum price per day
- `startDate` (string) - Start date for availability check
- `endDate` (string) - End date for availability check
- `passengers` (number) - Minimum number of passengers
- `transmission` (string) - Filter by transmission type (manual/automatic)
- `fuelType` (string) - Filter by fuel type (gasoline/diesel/electric/hybrid)
- `minRating` (number) - Minimum rating
- `hostId` (string) - Filter by host ID
- `limit` (number) - Number of results per page (default: 20)
- `offset` (number) - Number of results to skip (default: 0)

**Example:**
```
GET /api/cars/search?query=BMW&location=Alger&minPrice=50&maxPrice=200&transmission=automatic&limit=10
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "BMW X5",
      "description": "Luxury SUV",
      "price_per_day": 150,
      "location": "Alger",
      "transmission": "automatic",
      "fuel_type": "gasoline",
      "passengers": 5,
      "rating": 4.5,
      "is_available": true,
      "images": [...],
      "category": {...},
      "host": {...}
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 10,
      "pageCount": 5,
      "total": 50
    }
  }
}
```

### 2. Get Popular Locations
**GET** `/cars/popular-locations`

**Response:**
```json
[
  "Alger",
  "Oran",
  "Constantine",
  "Setif"
]
```

### 3. Get Host's Cars
**GET** `/cars/host/:hostId`

**Query Parameters:**
- `page` (number) - Page number (default: 1)
- `pageSize` (number) - Results per page (default: 10)

**Response:**
```json
{
  "data": [...],
  "meta": {
    "pagination": {...}
  }
}
```

### 4. Upload Car Images
**POST** `/cars/:carId/images`

**Body:** Multipart form data with `files` field

**Response:**
```json
[
  {
    "id": 1,
    "name": "car_image.jpg",
    "url": "http://localhost:1337/uploads/car_image.jpg"
  }
]
```

### 5. Delete Car Image
**DELETE** `/cars/:carId/images/:imageId`

**Response:**
```json
{
  "success": true
}
```

### 6. Get Host Statistics
**GET** `/cars/host/:hostId/stats`

**Response:**
```json
{
  "totalCars": 5,
  "availableCars": 3,
  "totalBookings": 25,
  "activeBookings": 8,
  "totalRevenue": 2500.00,
  "averageRating": 4.2
}
```

## User API Endpoints

### 1. Upload Profile Picture
**POST** `/users/:userId/profile-picture`

**Body:** Multipart form data with `files` field

**Response:**
```json
{
  "id": 1,
  "name": "profile.jpg",
  "url": "http://localhost:1337/uploads/profile.jpg"
}
```

### 2. Get User Profile
**GET** `/users/:userId/profile`

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+213123456789",
  "profile_image": {...},
  "cars": [...],
  "bookings": [...]
}
```

### 3. Update User Profile
**PUT** `/users/:userId/profile`

**Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+213123456789",
  "bio": "Car enthusiast"
}
```

### 4. Get User's Booking History
**GET** `/users/:userId/bookings`

**Query Parameters:**
- `page` (number) - Page number (default: 1)
- `pageSize` (number) - Results per page (default: 10)
- `status` (string) - Filter by booking status

**Response:**
```json
{
  "data": [...],
  "meta": {
    "pagination": {...}
  }
}
```

## Booking API Endpoints

### 1. Get Host's Bookings
**GET** `/bookings/host/:hostId`

**Query Parameters:**
- `page` (number) - Page number (default: 1)
- `pageSize` (number) - Results per page (default: 10)
- `status` (string) - Filter by booking status

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "start_date": "2024-01-15T10:00:00Z",
      "end_date": "2024-01-17T10:00:00Z",
      "total_price": 300.00,
      "status": "confirmed",
      "car": {...},
      "user": {...}
    }
  ],
  "meta": {
    "pagination": {...}
  }
}
```

### 2. Update Booking Status
**PUT** `/bookings/:bookingId/status`

**Body:**
```json
{
  "status": "confirmed"
}
```

**Valid Statuses:** `pending`, `confirmed`, `active`, `completed`, `cancelled`

### 3. Get Host Booking Statistics
**GET** `/bookings/host/:hostId/stats`

**Response:**
```json
{
  "total": 25,
  "pending": 5,
  "confirmed": 8,
  "active": 3,
  "completed": 7,
  "cancelled": 2,
  "totalRevenue": 2500.00
}
```

### 4. Create Booking
**POST** `/bookings`

**Body:**
```json
{
  "carId": 1,
  "userId": 1,
  "startDate": "2024-01-15T10:00:00Z",
  "endDate": "2024-01-17T10:00:00Z",
  "totalPrice": 300.00,
  "notes": "Early pickup requested"
}
```

### 5. Get User's Bookings
**GET** `/bookings/user/:userId`

**Query Parameters:**
- `page` (number) - Page number (default: 1)
- `pageSize` (number) - Results per page (default: 10)
- `status` (string) - Filter by booking status

## Category API Endpoints

### 1. Get Categories with Car Count
**GET** `/categories/with-count`

**Response:**
```json
[
  {
    "id": 1,
    "name": "Sedan",
    "description": "Comfortable family cars",
    "car_count": 15
  }
]
```

### 2. Get Popular Categories
**GET** `/categories/popular`

**Query Parameters:**
- `limit` (number) - Number of categories to return (default: 5)

**Response:**
```json
[
  {
    "id": 1,
    "name": "Sedan",
    "description": "Comfortable family cars",
    "car_count": 15
  }
]
```

## Error Responses

All endpoints return standard HTTP status codes:

- `200` - Success
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

**Error Response Format:**
```json
{
  "error": {
    "message": "Error description",
    "details": {...}
  }
}
```

## File Upload

For image uploads, use multipart form data with the field name `files`. Multiple files can be uploaded at once.

**Example using curl:**
```bash
curl -X POST \
  -H "Content-Type: multipart/form-data" \
  -F "files=@car_image.jpg" \
  http://localhost:1337/api/cars/1/images
```

## Pagination

All list endpoints support pagination with the following meta structure:

```json
{
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 10,
      "pageCount": 5,
      "total": 50
    }
  }
}
``` 