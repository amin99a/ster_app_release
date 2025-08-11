/**
 * user controller
 */

import { factories } from '@strapi/strapi'

export default factories.createCoreController('api::user.user', ({ strapi }) => ({
  // Upload profile picture
  async uploadProfilePicture(ctx) {
    try {
      const { userId } = ctx.params;
      const { files } = ctx.request.files;

      if (!files || files.length === 0) {
        return ctx.badRequest('No files uploaded');
      }

      const file = Array.isArray(files) ? files[0] : files;

      const uploadedFile = await strapi.plugins.upload.services.upload.upload({
        data: {
          user: userId
        },
        files: file
      });

      // Update user with new profile picture
      await strapi.entityService.update('api::user.user', userId, {
        profile_image: uploadedFile[0]
      });

      return uploadedFile[0];
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get user profile
  async getProfile(ctx) {
    try {
      const { userId } = ctx.params;

      const user = await strapi.entityService.findOne('api::user.user', userId, {
        populate: {
          profile_image: true,
          cars: {
            populate: {
              images: true,
              category: true
            }
          },
          bookings: {
            populate: {
              car: {
                populate: {
                  images: true,
                  category: true
                }
              }
            }
          }
        }
      });

      return user;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Update user profile
  async updateProfile(ctx) {
    try {
      const { userId } = ctx.params;
      const { name, email, phone, bio } = ctx.request.body;

      const updates: any = {};
      if (name) updates.name = name;
      if (email) updates.email = email;
      if (phone) updates.phone = phone;
      if (bio) updates.bio = bio;

      const user = await strapi.entityService.update('api::user.user', userId, updates);

      return user;
    } catch (error) {
      ctx.throw(500, error);
    }
  },

  // Get user's booking history
  async getBookingHistory(ctx) {
    try {
      const { userId } = ctx.params;
      const { page = 1, pageSize = 10 } = ctx.query;

      const bookings = await strapi.entityService.findMany('api::booking.booking', {
        filters: { user: userId },
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
        filters: { user: userId }
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