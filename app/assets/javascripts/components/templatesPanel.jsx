import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _ from 'lodash';
import { provideHooks } from 'redial';
import { getListenSignalTemplatesData } from 'redux/modules/models/listenSignalTemplates.js'
import SignalIcon from 'components/links/signal_icon';

const hooks = {
  fetch: ({ dispatch }) => {
    dispatch(getListenSignalTemplatesData());
  },
};

function renderTemplates(templates) {
  return _.map(templates, (text, type) => {

    // Disable all signals except for offers and custom
    if (type == 'offers' || type == 'today' || type == 'contest' || type == 'reminder' || type == 'support') {
      return (
        <Link to={`/dashboard/signals/new/${type}`} key={type} className='panel signal-panel panel-new'>
          <div className={`panel-header signal-all`}>
            <div className='header-text uctext'>{type}</div>
            <div className='subheader'>SIGNAL</div>
          </div>
          <div className='panel-text'>{text}</div>
          <SignalIcon type={type} className='panel-icon panel-icon-new'/>
        </Link>
      );
    }
  });
}

function TemplatesPane({ templates }) {
  return (
    <div>
      <h3 className='panel-label-text'>Create New Signal</h3>
      <p>Select a template to start </p>
      <div className='create-new'>
        {renderTemplates(templates)}
        <div className='panel signal-panel coming-soon'>
          <div className='panel-header'>
            <div className='header-text uctext coming-soon-padding'>Coming Soon</div>
          </div>
          <div className='panel-text coming-soon-padding'>We’re adding new signal templates all the time. Stay tuned for more!</div>
            <SignalIcon type='welcome' className='panel-icon panel-icon-new'/>
        </div>
      </div>
    </div>
  );
}

const connectedTemplatesPane = connect(state => ({
  templates: _.get(state, 'models.listenSignalTemplates.data', {}),
}))(TemplatesPane);

export default provideHooks(hooks)(connectedTemplatesPane);
