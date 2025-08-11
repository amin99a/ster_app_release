'use strict';

/**
 * cars controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::cars.cars');
