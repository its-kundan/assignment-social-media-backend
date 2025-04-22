import Joi from 'joi';

export const createPostSchema = Joi.object({
  content: Joi.string().required().max(1000).messages({
    'string.empty': 'Content is required',
    'string.max': 'Content cannot exceed 1000 characters',
  }),
  authorId: Joi.number().required().messages({
    'number.base': 'Author ID must be a number',
    'any.required': 'Author ID is required',
  }),
  hashtagTags: Joi.array().items(Joi.string().max(100)).optional().messages({
    'string.max': 'Hashtag cannot exceed 100 characters',
  }),
});

export const updatePostSchema = Joi.object({
  content: Joi.string().max(1000).messages({
    'string.max': 'Content cannot exceed 1000 characters',
  }),
})
  .min(1)
  .messages({
    'object.min': 'At least one field must be provided for update',
  });