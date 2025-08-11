'use strict';

/**
 * cars service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::cars.cars');
