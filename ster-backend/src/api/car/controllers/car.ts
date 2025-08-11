/**
 * car controller
 */

import { factories } from '@strapi/strapi'

export default factories.createCoreController('api::car.car', ({ strapi }) => ({
  // Search cars with advanced filters
  async search(ctx) {
    try {
      const {
        query,
        category,
        location,
        minPrice,
        maxPrice,
        startDate,
        endDate,
        passengers,
        transmission,
        fuelType,
        minRating,
        limit = 20,
        offset = 0,
        hostId
      } = ctx.query;

      let filters: any = {
        $and: [
          { is_available: true }
        ]
      };

      // Text search
      if (query) {
        filters.$and.push({
          $or: [
            { name: { $containsi: query } },
            { description: { $containsi: query } }
          ]
        });
      }

      // Category filter
      if (category) {
        filters.category = category;
      }

      // Location filter
      if (location) {
        filters.location = { $containsi: location };
      }

      // Price range
      if (minPrice || maxPrice) {
        filters.price_per_day = {};
        if (minPrice) filters.price_per_day.$gte = parseFloat(minPrice);
        if (maxPrice) filters.price_per_day.$lte = parseFloat(maxPrice);
      }

      // Other filters
      if (passengers) {
        filters.passengers = { $gte: parseInt(passengers) };
      }

      if (transmission) {
        filters.transmission = transmission;
      }

      if (fuelType) {
        filters.fuel_type = fuelType;
      }

      if (minRating) {
        filters.rating = { $gte: parseFloat(minRating) };
      }

      if (hostId) {
        filters.host = hostId;
      }

      // Date availability check (simplified)
      if (startDate && endDate) {
        // This would need a more complex query to check booking conflicts
        // For now, we'll just filter by cars that are generally available
        filters.is_available = true;
      }

      const cars = await strapi.entityService.findMany('api::car.car', {
        filters,
        populate: {
          category: true,
          host: {
            fields: ['id', 'name', 'email', 'profile_image']
          },
          images: true
        },
        sort: { rating: 'desc' },
        limit: parseInt(limit),
        start: parseInt(offset)
      });

      const total = await strapi.entityService.count('api::car.car', {
        filters
      });

      return {
        data: cars,
        meta: {
          pagination: {
            page: Math.floor(offset / limit) + 1,
            pageSize: limit,
            pageCount: Math.ceil(total / limit),
            total
          }
        }
      };
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get popular locations
  async getPopularLocations(ctx) {
    try {
      const cars = await strapi.entityService.findMany('api::car.car', {
        filters: { is_available: true },
        fields: ['location']
      });

      const locations = [...new Set(cars.map(car => car.location).filter(Boolean))];
      return locations.slice(0, 10);
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get host's cars
  async getHostCars(ctx) {
    try {
      const { hostId } = ctx.params;
      const { page = 1, pageSize = 10 } = ctx.query;

      const cars = await strapi.entityService.findMany('api::car.car', {
        filters: { host: hostId },
        populate: {
          category: true,
          images: true
        },
        sort: { created_at: 'desc' },
        limit: pageSize,
        start: (page - 1) * pageSize
      });

      const total = await strapi.entityService.count('api::car.car', {
        filters: { host: hostId }
      });

      return {
        data: cars,
        meta: {
          pagination: {
            page,
            pageSize,
            pageCount: Math.ceil(total / pageSize),
            total
          }
        }
      };
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Upload car images
  async uploadImages(ctx) {
    try {
      const { carId } = ctx.params;
      const { files } = ctx.request.files;

      if (!files || files.length === 0) {
        return ctx.badRequest('No files uploaded');
      }

      const uploadedImages = [];
      const fileArray = Array.isArray(files) ? files : [files];

      for (const file of fileArray) {
        const uploadedFile = await strapi.plugins.upload.services.upload.upload({
          data: {
            car: carId
          },
          files: file
        });

        uploadedImages.push(uploadedFile[0]);
      }

      // Update car with new images
      const car = await strapi.entityService.findOne('api::car.car', carId, {
        populate: { images: true }
      });

      const updatedImages = [...(car.images || []), ...uploadedImages];

      await strapi.entityService.update('api::car.car', carId, {
        images: updatedImages
      });

      return uploadedImages;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Delete car image
  async deleteImage(ctx) {
    try {
      const { carId, imageId } = ctx.params;

      const car = await strapi.entityService.findOne('api::car.car', carId, {
        populate: { images: true }
      });

      if (!car.images) {
        return ctx.notFound('Image not found');
      }

      const updatedImages = car.images.filter(img => img.id !== parseInt(imageId));

      await strapi.entityService.update('api::car.car', carId, {
        images: updatedImages
      });

      // Delete the file from storage
      await strapi.plugins.upload.services.upload.remove({ id: imageId });

      return { success: true };
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get car statistics for host dashboard
  async getHostStats(ctx) {
    try {
      const { hostId } = ctx.params;

      const cars = await strapi.entityService.findMany('api::car.car', {
        filters: { host: hostId }
      });

      const bookings = await strapi.entityService.findMany('api::booking.booking', {
        filters: { car: { host: hostId } },
        populate: { car: true }
      });

      const totalCars = cars.length;
      const availableCars = cars.filter(car => car.is_available).length;
      const totalBookings = bookings.length;
      const activeBookings = bookings.filter(booking => 
        ['confirmed', 'active'].includes(booking.status)
      ).length;
      const totalRevenue = bookings
        .filter(booking => booking.status === 'completed')
        .reduce((sum, booking) => sum + (booking.total_price || 0), 0);

      const averageRating = cars.length > 0 
        ? cars.reduce((sum, car) => sum + (car.rating || 0), 0) / cars.length 
        : 0;

      return {
        totalCars,
        availableCars,
        totalBookings,
        activeBookings,
        totalRevenue,
        averageRating: parseFloat(averageRating.toFixed(2))
      };
    } catch (error) {
      ctx.throw(500, error);
    }
  }
}));
