import Joi from 'joi';

export const createFollowSchema = Joi.object({
  followerId: Joi.number().required().messages({
    'number.base': 'Follower ID must be a number',
    'any.required': 'Follower ID is required',
  }),
  followedId: Joi.number().required().messages({
    'number.base': 'Followed ID must be a number',
    'any.required': 'Followed ID is required',
  }),
});