/**
 * booking router
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreRouter('api::booking.booking', {
  config: {
    find: {
      policies: [],
      middlewares: [],
    },
    findOne: {
      policies: [],
      middlewares: [],
    },
    create: {
      policies: [],
      middlewares: [],
    },
    update: {
      policies: [],
      middlewares: [],
    },
    delete: {
      policies: [],
      middlewares: [],
    },
  },
  routes: [
    // Get host's bookings
    {
      method: 'GET',
      path: '/bookings/host/:hostId',
      handler: 'booking.getHostBookings',
      config: {
        auth: false,
      },
    },
    // Update booking status
    {
      method: 'PUT',
      path: '/bookings/:bookingId/status',
      handler: 'booking.updateStatus',
      config: {
        auth: false,
      },
    },
    // Get booking statistics for host
    {
      method: 'GET',
      path: '/bookings/host/:hostId/stats',
      handler: 'booking.getHostBookingStats',
      config: {
        auth: false,
      },
    },
    // Create booking
    {
      method: 'POST',
      path: '/bookings',
      handler: 'booking.createBooking',
      config: {
        auth: false,
      },
    },
    // Get user's bookings
    {
      method: 'GET',
      path: '/bookings/user/:userId',
      handler: 'booking.getUserBookings',
      config: {
        auth: false,
      },
    },
  ],
}); 