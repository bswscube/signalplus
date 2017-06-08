import React from 'react';
import { Link } from 'react-router';
import SignalIcon from 'components/links/signal_icon';

export default function CreateNewWidget() {
  return (
    <Link to="/dashboard/templates">
      <div className='panel signal-panel panel-new'>
        <SignalIcon type='create' className='panel-icon padding-icon'/>
        <div className='panel-header header-new'>
          Create New
        </div>
        <div className='panel-text body-new'>
          Click here to create a new signal for your audience based on your campaign objective
        </div>
      </div>
    </Link>
  );
}
