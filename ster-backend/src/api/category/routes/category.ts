/**
 * category router
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreRouter('api::category.category', {
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
    // Get categories with car count
    {
      method: 'GET',
      path: '/categories/with-count',
      handler: 'category.getCategoriesWithCount',
      config: {
        auth: false,
      },
    },
    // Get popular categories
    {
      method: 'GET',
      path: '/categories/popular',
      handler: 'category.getPopularCategories',
      config: {
        auth: false,
      },
    },
  ],
}); 