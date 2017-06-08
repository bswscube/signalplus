import React, { Component } from 'react';
import { connect } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
import { provideHooks } from 'redial';
import _ from 'lodash';

// Components
import InputBox from 'components/forms/inputBox';
import Checkbox from 'components/forms/checkbox';
import SignalIcon from 'components/links/signal_icon';
import TimezoneDropdown from 'components/forms/timezoneDropdown';
import { updateUserInfo, getUserData } from 'redux/modules/models/user';
import {
  createValidator,
  emailValidator,
  timezoneValidator,
} from 'components/forms/validations';


const hooks = {
  fetch: ({ dispatch }) => (dispatch(getUserData())),
};


class UndecoratedAccountInfo extends Component {
  constructor(props) {
    super(props);
    this.updateDetails = this.updateDetails.bind(this);
  }

  updateDetails(form) {
    const { tz, ...user } = form;
    const { dispatch } = this.props;
    dispatch(updateUserInfo({ user, brand: { tz } }));
  }

  render() {
    const { handleSubmit } = this.props;

    return (
      <form onSubmit={handleSubmit(this.updateDetails)}>
        <div className='col-xs-10 content-box'>
          <div className='account-details'>
            <p className='account-input-label'>Email Address</p>
            <p className='email-sublabel'>We’ll notify you of changes to your account</p>
            <InputBox
              name="email"
              placeholder="ie. john@signalplus.com"
              className='account-input-box'
              componentClass="input"
            />
          </div>
          <div className='notification-checkbox checkbox'>
            <Checkbox
              name="email_subscription"
              label='Notify me of new features/product annoucements'
            />
          </div>
          <hr className='line'/>
          <div className='account-timezone'>
            <p className='account-input-label'>Time Zone</p>
            <p className='tz-sublabel'>Set a default time zone for your account. This will determine timing for your responses.</p>
            <TimezoneDropdown
              name="tz"
              componentClass="input"
            />
          </div>
          <hr className='line'/>
            <SignalIcon type="tip" className="account-tip-icon"/>
              <p className='account-input-label'>Enable Direct Messages from Any User</p>
              <p className='twitter-tip-text'>To receive requests from any user,
                select “Receive Direct Messages from anyone” in your &nbsp;
                <a href="https://twitter.com/settings/security">Twitter security settings</a>
              </p>
          <hr className='line'/>
          <button className='btn btn-primary save-btn'>
            Save
          </button>
        </div>
      </form>
    );
  }
}

const validate = createValidator({
  email: emailValidator,
  tz: timezoneValidator,
});

const AccountInfo = reduxForm({
  form: 'accountInfo',
  enableReinitialize: true,
  destroyOnUnmount: false,
  validate,
})(UndecoratedAccountInfo)

const ConnectedAccountInfo = connect((state) => {
  return {
    initialValues: {
      email: _.get(state, 'models.user.data.email'),
      email_subscription: _.get(state, 'models.user.data.email_subscription'),
      tz: _.get(state, 'models.brand.data.tz'),
    },
  };
})(AccountInfo);

export default provideHooks(hooks)(ConnectedAccountInfo);
