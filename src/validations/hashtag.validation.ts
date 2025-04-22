import Joi from 'joi';

export const createHashtagSchema = Joi.object({
  tag: Joi.string().required().min(1).max(100).messages({
    'string.empty': 'Tag is required',
    'string.min': 'Tag must be at least 1 character long',
    'string.max': 'Tag cannot exceed 100 characters',
  }),
});

export const updateHashtagSchema = Joi.object({
  tag: Joi.string().min(1).max(100).messages({
    'string.min': 'Tag must be at least 1 character long',
    'string.max': 'Tag cannot exceed 100 characters',
  }),
})
  .min(1)
  .messages({
    'object.min': 'At least one field must be provided for update',
  });