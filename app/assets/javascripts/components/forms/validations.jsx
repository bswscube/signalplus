import _ from 'lodash';
import moment from 'moment';

export function signalNameValidator(name) {
  if (!name) {
    return 'Hashtag required.';
  } else if (name.indexOf(' ') >= 0) {
    return 'Your hashtag cannot contain a space.';
  } else if (name.indexOf('#') >= 0) {
    return 'Please put your hashtag name without #.';
  }

  return null;
}

export function defaultResponseValidator(defaultResponse) {
  return responseTextValidator(defaultResponse, 'Default');
}

export function repeatResponseValidator(repeatResponse) {
  return responseTextValidator(repeatResponse, 'Repeat');
}

// TODO: Validate time only for new calendars
export function timedResponseValidator(responses) {
  const responseArrayErrors = [];

  if (responses.length) {
    responses.forEach((response, index) => {
      const responseErrors = {};
      responseErrors.message = responseTextValidator(response.message, 'Timed');
      responseErrors.expiration_date = expirationDateValidator(response.expiration_date);
      responseArrayErrors[index] = responseErrors;
    });
  }

  if (responses.length) {
    responses.forEach((response, index) => {
      const responseErrors = {};
      responseErrors.message = responseTextValidator(response.message, 'Timed');
      responseErrors.res_start_date = expirationDateValidator(response.res_start_date);
      responseArrayErrors[index] = responseErrors;
    });
  }

  return responseArrayErrors.length ? responseArrayErrors : null;
}

export function responseTextValidator(text, type) {
  if (!text) {
    return `${type} response required.`;
  }

  if (text.length > 140) {
    return 'Your tweet response cannot exceed 140 characters.';
  }

  return null;
}

export function expirationDateValidator(date) {
  if (!date) {
    return 'Expiration date required';
  }

  return null;
}

export function timezoneValidator(tz) {
  if (!tz) {
    return 'Timezone required.';
  }

  return null;
}

export function emailValidator(email) {
  if (!email) {
    return 'Email Required'
  } else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(email)) {
    return 'Invalid email address'
  }

  return null;
}

export function required(value) {
  if (!value) {
    return 'Required'
  }

  return null;
}

export function createValidator(fields) {
  return (values = {}, props) => {
    const actualValues = values || {};
    return _.reduce(fields, (memoOne, rules, field) => {
      const errors = _.reduce([].concat(rules), (memoTwo, rule) => {
        // Return if there is already an error
        if (!_.isEmpty(memoTwo)) return memoTwo;

        const fieldValue = actualValues[field];
        const error = rule(fieldValue);
        return error ? [error, ...memoTwo] : memoTwo;
      }, []);

      const fieldError = errors[0];
      return fieldError ? { ...memoOne, [field]: fieldError } : { ...memoOne };
    }, {});
  };
}
