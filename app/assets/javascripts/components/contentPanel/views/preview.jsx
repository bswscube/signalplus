import React from 'react'
import SignalIcon from 'components/links/signal_icon';
import _ from 'lodash';

const DEFAULT_SIGNAL_NAME = 'Name';
const DEFAULT_RESPONSE_TYPE = 'default';
const REPEAT_RESPONSE_TYPE = 'repeat';
const CUSTOM_RESPONSE_TYPE = 'timed';

function getResponse(signal, type) {
  const response = _.find(signal.responses, { response_type: type });
  const message = _.get(response, 'message', '')
  return message;
}

function renderCustomResponseBubbles({ responses }) {
  const customResponses = _.filter(responses, { response_type: CUSTOM_RESPONSE_TYPE });

  if (_.isEmpty(customResponses)) {
    return undefined;
  }

  return _.map(customResponses, (response, idx) => {
    return (
      <div className='preview-response' key={idx}>
        <div className='preview-label'>
          <h5>Response</h5>
        </div>
        <div className='preview-response-bubble'>
          {response.message}
        </div>
      </div>
    );
  });
}

function renderDefaultDescription(type) {
  console.log(type)
  if (type == 'offers') {
    return (
      <h5 className='preview-wrap-text'>
        Not Available/ <br/>Repeat Requests
      </h5>
    );
  } else {
    return (
      <h5 className='preview-wrap-text'>
        Repeat Requests
      </h5>
    );
  }
}

export default function Preview(props) {
  const { signal, brand } = props;
  const signalName = signal.id ? signal.name : DEFAULT_SIGNAL_NAME;

  return (
    <div className='col-xs-10 content-box'>
      <div className='content-header'>
        <p className='signal-type-label'>REQUEST > RESPONSE</p>
      </div>

      <div className='response-info'>
        <SignalIcon src={window.__IMAGE_ASSETS__.socialTwitterBlueSvg} />
        <h4>Public Tweet or Direct Message</h4>
        <SignalIcon
          className="arrow"
          src={window.__IMAGE_ASSETS__.iconsBlueArrowPng}
          />
        <h4 className='subheading'>Direct Message</h4>
      </div>

      <div className='preview-bubble'>
        <div className='bubble'>
            @{brand.user_name} #{signalName}
        </div>
        <span><SignalIcon className='preview-image' type="public"/></span>
      </div>

      <div className='preview-response'>
        <div className='preview-label'>
          <h5>Default Response</h5>
        </div>
        <div className='preview-response-bubble'>
          {getResponse(signal, DEFAULT_RESPONSE_TYPE)}
        </div>
      </div>
      <div className='preview-response'>
        <div className='preview-label'>
          {renderDefaultDescription(signal.signal_type)}
        </div>
        <div className='preview-response-bubble'>
          {getResponse(signal, REPEAT_RESPONSE_TYPE)}
        </div>
      </div>
      {renderCustomResponseBubbles(signal)}
    </div>
  );
}
