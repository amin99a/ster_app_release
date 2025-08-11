/**
 * car router
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreRouter('api::car.car', {
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
    // Search cars with advanced filters
    {
      method: 'GET',
      path: '/cars/search',
      handler: 'car.search',
      config: {
        auth: false,
      },
    },
    // Get popular locations
    {
      method: 'GET',
      path: '/cars/popular-locations',
      handler: 'car.getPopularLocations',
      config: {
        auth: false,
      },
    },
    // Get host's cars
    {
      method: 'GET',
      path: '/cars/host/:hostId',
      handler: 'car.getHostCars',
      config: {
        auth: false,
      },
    },
    // Upload car images
    {
      method: 'POST',
      path: '/cars/:carId/images',
      handler: 'car.uploadImages',
      config: {
        auth: false,
      },
    },
    // Delete car image
    {
      method: 'DELETE',
      path: '/cars/:carId/images/:imageId',
      handler: 'car.deleteImage',
      config: {
        auth: false,
      },
    },
    // Get host statistics
    {
      method: 'GET',
      path: '/cars/host/:hostId/stats',
      handler: 'car.getHostStats',
      config: {
        auth: false,
      },
    },
  ],
});
