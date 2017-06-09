import React, { Component } from 'react';
import { arrayPush, FieldArray } from 'redux-form';
import { connect } from 'react-redux';
import _ from 'lodash';
import InputBox from 'components/forms/inputBox';
import SignalIcon from 'components/links/signal_icon';
import DateRangeResponseForm from 'components/forms/dateRangeResponseForm';
import TimedResponseForm from 'components/forms/timedResponseForm';
import { getFormNameFromSignal } from 'components/forms/util';

function renderInputBox(signal) {
  return (
    <div>
      <p className="signal-instruction">
        <span className='signal-instruction-text'>
          Responses to:
        </span>
        <InputBox
          name="name"
          placeholder="#Name"
          componentClass="input"
          className="signalNameInput signalResponseInput uctext"
        />
      </p>

    </div>
  );
}

function renderSignalName(signal) {
  return <div>{`#${signal.name}`}</div>;
}

const DEFAULT_SIGNAL_NAME = 'Name';

class Edit extends Component {
  constructor(props) {
    super(props);
    this.addCustomDateRangeResponse = this.addCustomDateRangeResponse.bind(this);
    this.addCustomResponse = this.addCustomResponse.bind(this);
  }

  displaySignalName() {
    const { signal, brand } = this.props;
    const signalName = signal.id ? signal.name : DEFAULT_SIGNAL_NAME;
    return (
      <h4 className='subheading'>@{brand.user_name} #{signalName}</h4>
    );
  }

  renderSubheader(type) {
    if (type == 'offers') {
      return 'Send a special offer every time a follower sends a custom hashtag. Add your offer responses here, be sure to include a link or details on how to use the offer. When you’re ready, activate your signal and promote it.'
    } else if (type == 'custom') {
      return 'Respond to your users with a custom message every time they send a custom hashtag'
    } else if (type == 'today') {
      return 'Send a summary of your location or event each day a follower uses a custom hashtag. Specific dates or date ranges override daily information. Date information is sent based on the time zone you selected in your account settings.'
    } else if (type == 'contest') {
      return 'Run a contest for your followers for a specific date range. Include links to additional contest information such as rules & regulations along with links to request more user information. Be sure to include dates when your contest closes and when a winner be selected.'
    } else if (type == 'reminder') {
      return 'Send a reminder on a specific date to users when they use a custom hashtag. Include a date notifying when users will be reminded on first response. On Reminder Date, include any links/details. Tease your reminder with the Reminder Soon response.'
    } else if (type == 'support') {
      return 'Notify users that you received their customer service request. Enter a time frame when users should expect a response in your First Response. Add day or date range responses if you Customer Service team in unavailable.'
    }
  }

  addCustomResponse() {
    const { dispatch, signal } = this.props;
    const form = getFormNameFromSignal(signal);
    dispatch(arrayPush(form, 'responses', { text: '', expiration_date: '' }));
  }

  addCustomDateRangeResponse() {
    const { dispatch, signal } = this.props;
    const form = getFormNameFromSignal(signal);
    dispatch(arrayPush(form, 'responses_date_range', { text: '', res_start_date: '', res_end_date: '' }));
  }

  renderDefaultDescription(type) {
    if (type == 'offers') {
      return 'Users will see this response the first time they use your signal'
    } else if (type == 'custom') {
      return 'Respond to your users with a custom message every time they send a custom hashtag'
    } else if (type == 'today') {
      return 'Send a summary of your location or event each day a follower uses a custom hashtag. Specific dates or date ranges override daily information. Date information is sent based on the time zone you selected in your account settings.'
    } else if (type == 'contest') {
      return 'Run a contest for your followers for a specific date range. Include links to additional contest information such as rules & regulations along with links to request more user information. Be sure to include dates when your contest closes and when a winner be selected.'
    } else if (type == 'reminder') {
      return 'Send a reminder on a specific date to users when they use a custom hashtag. Include a date notifying when users will be reminded on first response. On Reminder Date, include any links/details. Tease your reminder with the Reminder Soon response.'
    } else if (type == 'support') {
      return 'Notify users that you received their customer service request. Enter a time frame when users should expect a response in your First Response. Add day or date range responses if you Customer Service team in unavailable.'
    }
  }

  renderTipText(type) {
    if (type == 'offers') {
      return (
        <p>Add your offer responses here, be sure to include a link or details on how to use the offer.<br/>
         When you’re ready, activate your signal and promote it.</p>
      );
    } else if (type == 'custom') {
      return (
        <p>Add your custom responses here, you can have responses expire on different dates.<br/>
         When you’re ready, activate your signal and promote it.</p>
      );
    }
  }

  renderResponseText(type) {
    if (type == 'offers') {
      return(
       <div className='response-text'>
          <h5>
            Repeat Requests
          </h5>
          <p>Enter a thank you message for repeat requests</p>
        </div>
      );
    } else if (type == 'custom') {
      return(
       <div className='response-text'>
          <h5>
            Not Available/ <br/>
            Repeat Requests
          </h5>
        </div>
      );
    }

  }

  render() {
    const { signal } = this.props;

    return (
      <div className='col-xs-10 content-box'>
        <div className='content-header'>
          <div className='content-icon-main'> <SignalIcon type={signal.signal_type} className='content-icon' />
          <SignalIcon type='explanation' className='content-explanation' />
          </div>
          <div className='content-main'>
            <p className='signal-type-label'>TYPE</p>
            <h3 className='signal-type-header uctext'>{signal.signal_type} Signal</h3>
            <p className='signal-description'>
              {this.renderSubheader(signal.signal_type)}
            </p>
          </div>
          <div className='clearfix'></div>
        </div>

        <hr className='line'/>

        <div className='response-info'>


          <label className="signalLabel">
            {signal.id ? renderSignalName(signal) : renderInputBox(signal)}
          </label>


          <div className='edit-btns'>
            <div className="dropdown">
            <button className="btn btn-primary add-btn dropdown-toggle" type="button" data-toggle="dropdown">+ ADD RESPONSE</button>
            <ul className="dropdown-menu">
              <li><a onClick={this.addCustomResponse}>Day Response</a></li>
              <li><a onClick={this.addCustomDateRangeResponse}>Date Range Response</a></li>
            </ul>
          </div>

            <button
              type='submit'
              className='btn btn-primary save-btn'
            >
              SAVE
            </button>
          </div>
        </div>


        <div className='response-edit-box'>
          <div className='response-text'>
            <h5>Default Response</h5>
            <p>{this.renderDefaultDescription(signal.signal_type)}</p>
          </div>
          <InputBox
            name="default_response"
            placeholder="Type in a response here, add website links too"
            componentClass="textarea"
          />
          <span className='required'>REQUIRED</span>
        </div>

        <div className='response-edit-box'>
          {this.renderResponseText(signal.signal_type)}
          <InputBox
            name="repeat_response"
            placeholder="Type in a response here, add website links too"
            componentClass="textarea"
          />
          <span className='required'>REQUIRED</span>
        </div>

        <FieldArray
          name='responses'
          component={TimedResponseForm}
        />

        <FieldArray
          name='responses_date_range'
          component={DateRangeResponseForm}
        />
      </div>
    );
  }
}

export default connect()(Edit);
