/**
 * booking controller
 */

import { factories } from '@strapi/strapi'

export default factories.createCoreController('api::booking.booking', ({ strapi }) => ({
  // Get host's bookings
  async getHostBookings(ctx) {
    try {
      const { hostId } = ctx.params;
      const { page = 1, pageSize = 10, status } = ctx.query;

      let filters: any = {
        car: { host: hostId }
      };

      if (status) {
        filters.status = status;
      }

      const bookings = await strapi.entityService.findMany('api::booking.booking', {
        filters,
        populate: {
          car: {
            populate: {
              images: true,
              category: true
            }
          },
          user: {
            fields: ['id', 'name', 'email', 'profile_image']
          }
        },
        sort: { created_at: 'desc' },
        limit: pageSize,
        start: (page - 1) * pageSize
      });

      const total = await strapi.entityService.count('api::booking.booking', {
        filters
      });

      return {
        data: bookings,
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

  // Update booking status
  async updateStatus(ctx) {
    try {
      const { bookingId } = ctx.params;
      const { status } = ctx.request.body;

      const validStatuses = ['pending', 'confirmed', 'active', 'completed', 'cancelled'];
      if (!validStatuses.includes(status)) {
        return ctx.badRequest('Invalid status');
      }

      const booking = await strapi.entityService.update('api::booking.booking', bookingId, {
        status,
        updated_at: new Date()
      });

      return booking;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get booking statistics for host
  async getHostBookingStats(ctx) {
    try {
      const { hostId } = ctx.params;

      const bookings = await strapi.entityService.findMany('api::booking.booking', {
        filters: { car: { host: hostId } }
      });

      const stats = {
        total: bookings.length,
        pending: bookings.filter(b => b.status === 'pending').length,
        confirmed: bookings.filter(b => b.status === 'confirmed').length,
        active: bookings.filter(b => b.status === 'active').length,
        completed: bookings.filter(b => b.status === 'completed').length,
        cancelled: bookings.filter(b => b.status === 'cancelled').length,
        totalRevenue: bookings
          .filter(b => b.status === 'completed')
          .reduce((sum, b) => sum + (b.total_price || 0), 0)
      };

      return stats;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Create booking
  async createBooking(ctx) {
    try {
      const { carId, userId, startDate, endDate, totalPrice, notes } = ctx.request.body;

      // Get the car to find the host
      const car = await strapi.entityService.findOne('api::car.car', carId);
      if (!car) {
        return ctx.notFound('Car not found');
      }

      const bookingData = {
        car: carId,
        user: userId,
        host: car.host,
        start_date: startDate,
        end_date: endDate,
        total_price: totalPrice,
        status: 'pending',
        notes,
        created_at: new Date(),
        updated_at: new Date()
      };

      const booking = await strapi.entityService.create('api::booking.booking', {
        data: bookingData
      });

      return booking;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get user's bookings
  async getUserBookings(ctx) {
    try {
      const { userId } = ctx.params;
      const { page = 1, pageSize = 10, status } = ctx.query;

      let filters: any = { user: userId };

      if (status) {
        filters.status = status;
      }

      const bookings = await strapi.entityService.findMany('api::booking.booking', {
        filters,
        populate: {
          car: {
            populate: {
              images: true,
              category: true,
              host: {
                fields: ['id', 'name', 'email', 'profile_image']
              }
            }
          }
        },
        sort: { created_at: 'desc' },
        limit: pageSize,
        start: (page - 1) * pageSize
      });

      const total = await strapi.entityService.count('api::booking.booking', {
        filters
      });

      return {
        data: bookings,
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
  }
})); 