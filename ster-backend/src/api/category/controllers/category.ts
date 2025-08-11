/**
 * category controller
 */

import { factories } from '@strapi/strapi'

export default factories.createCoreController('api::category.category', ({ strapi }) => ({
  // Get all categories with car count
  async getCategoriesWithCount(ctx) {
    try {
      const categories = await strapi.entityService.findMany('api::category.category', {
        populate: {
          cars: {
            filters: { is_available: true },
            fields: ['id']
          }
        }
      });

      const categoriesWithCount = categories.map(category => ({
        ...category,
        car_count: category.cars?.length || 0
      }));

      return categoriesWithCount;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get popular categories
  async getPopularCategories(ctx) {
    try {
      const { limit = 5 } = ctx.query;

      const categories = await strapi.entityService.findMany('api::category.category', {
        populate: {
          cars: {
            filters: { is_available: true },
            fields: ['id']
          }
        },
        sort: { cars: { count: 'desc' } },
        limit: parseInt(limit)
      });

      return categories.filter(category => (category.cars?.length || 0) > 0);
    } catch (error) {
      ctx.throw(500, error);
    }
  }
})); 