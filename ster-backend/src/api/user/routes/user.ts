/**
 * user router
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreRouter('api::user.user', {
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
    // Upload profile picture
    {
      method: 'POST',
      path: '/users/:userId/profile-picture',
      handler: 'user.uploadProfilePicture',
      config: {
        auth: false,
      },
    },
    // Get user profile
    {
      method: 'GET',
      path: '/users/:userId/profile',
      handler: 'user.getProfile',
      config: {
        auth: false,
      },
    },
    // Update user profile
    {
      method: 'PUT',
      path: '/users/:userId/profile',
      handler: 'user.updateProfile',
      config: {
        auth: false,
      },
    },
    // Get user's booking history
    {
      method: 'GET',
      path: '/users/:userId/bookings',
      handler: 'user.getBookingHistory',
      config: {
        auth: false,
      },
    },
  ],
}); 