import React, { Component } from 'react';
import { Link } from 'react-router';
import _ from 'lodash';
import SignalIcon from 'components/links/signal_icon';
import { actions as appActions } from 'redux/modules/app/index';
import cn from 'classnames';

function renderSignalWidgets(signals) {
  return _.map(signals, (signal) => {
    const { id, name, signal_type, active } = signal;

    const signalClasses = cn(
      'panel',
      'signal-panel',
      'active-tab',
      { inactiveSignal: !active }
    );

    return (
      <Link to={`/dashboard/signals/${id}`} className={signalClasses} key={`signal_${id}`}>
        <div className="panel-active-platform"> Fb, Tw, In </div>
        <div className='panel-header'>{`#${name}`}</div>
        <div className='panel-text'>
          { signal_type == 'offers' && 'Send your users a special offer every time they send a custom hashtag.'}
          { signal_type == 'custom' && 'Create your own custom response whenever a follower sends a custom hashtag'}
        </div>

        <div className='panel-status'>
          <div className='signal-status'>
            <div className='circle'></div>
            <span className='status'>{active ? 'ACTIVE' : 'INACTIVE'}</span>
          </div>
        </div>

        <div className='signal-type'>
          <p className='panel-type-label'>TYPE</p>
          <span className='uctext type'>{signal_type}</span>
        </div>
      </Link>
    );
  });
}

export default function SignalWidgets({ signals }) {
  return <div>{renderSignalWidgets(signals)}</div>;
}
