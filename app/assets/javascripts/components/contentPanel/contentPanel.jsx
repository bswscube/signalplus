import React, { Component } from 'react';
import { connect } from 'react-redux';
import { provideHooks } from 'redial';
import _ from 'lodash';
import { actions as appActions } from 'redux/modules/app/index';
import { getListenSignalData } from 'redux/modules/models/listenSignals';
import { getFormNameFromSignal } from 'components/forms/util';

// Components
import Sidebar from 'components/contentPanel/sidebar';
import SignalForm from 'components/forms/signalForm';

const EXISTING_SIGNAL_PATHNAME_REGEX = /^\/dashboard\/signals\/\d+/;
const MATCHING_LOCATION_BASE_PATHNAME_REGEX = /\/dashboard\/signals\/(\d+|new\/[^\/]+)/

const genericSignalFormName = 'listenSignalForm';

function isExistingSignal(pathname) {
  return EXISTING_SIGNAL_PATHNAME_REGEX.test(pathname);
}

function tabId(signal) {
  const { signal_type: type, id } = signal;
  return !id ? `new_${type}` : `existing_${id}`;
}

export function createTab(signal, formName) {
  const { signal_type: type, id, name } = signal;
  const isNew = !id

  return {
    id: tabId(signal),
    label: isNew ? `New ${_.upperFirst(type)} Signal` : `#${_.upperFirst(name)}`,
    link: isNew ? `/dashboard/signals/new/${type}` : `/dashboard/signals/${id}`,
    closeable: true,
    formName,
  };
}

class ContentPanel extends Component {
  constructor(props) {
    super(props);
    this.updateSignal = this.updateSignal.bind(this);
    this.state = { tabCreated: false };
  }

  updateSignal(form) {
    console.log(form);
  }

  tabAlreadyCreated(signal, tabs) {
    const newTab = createTab(signal, getFormNameFromSignal(signal));
    return _.some(tabs, (tab) => (_.isEqual(tab, newTab)));
  }

  shouldCreateTab(signal, tabs) {
    if (!this._mounted) return false;
    if (this.state.tabCreated) return false;
    if (this.tabAlreadyCreated(signal, tabs)) return false;

    const { location } = this.props;
    if (!isExistingSignal(location.pathname)) return true;

    return !!signal.id
  }

  createTabIfNotCreated(signal, tabs) {
    if (this.shouldCreateTab(signal, tabs)) {
      this.props.dispatch(appActions.addTab(createTab(signal, getFormNameFromSignal(signal))));
      this.setState({ tabCreated: true });
    }
  }

  componentDidMount() {
    this._mounted = true;
    const { signal, tabs } = this.props;
    this.createTabIfNotCreated(signal, tabs);
  }

  componentWillReceiveProps({ signal, tabs }) {
    this.createTabIfNotCreated(signal, tabs);
  }

  componentWillUnmount() {
    this._mounted = false;
  }

  menuItems() {
    const { location } = this.props;
    const basePath = _.first(location.pathname.match(MATCHING_LOCATION_BASE_PATHNAME_REGEX));

    return [
      {
        label: 'Edit',
        linkProps: {
          to: basePath,
          onlyActiveOnIndex: true,
        },
      },
      {
        label: 'Promote',
        linkProps: {
          to: `${basePath}/promote`,
          onlyActiveOnIndex: false,
        },
      },
      {
        label: 'Preview',
        linkProps: {
          to: `${basePath}/preview`,
          onlyActiveOnIndex: false,
        },
      },
    ]
  }

  cloneChildren() {
    const { signal, brand } = this.props;
    return React.Children.map(this.props.children, (child) => {
      return React.cloneElement(child, { signal, brand });
    });
  }

  formName(signal) {
    return `${genericSignalFormName}_${signal.id || signal.signal_type}`;
  }

  render() {
    const { signal, children } = this.props;
    const childrenToRender = children ? this.cloneChildren() : children;

    return (
      <SignalForm signal={signal} tabId={tabId(signal)} formName={getFormNameFromSignal(signal)}>
        <Sidebar menuItems={this.menuItems()} signal={signal} tabId={tabId(signal)}/>
        <div className="content-pane">
          {childrenToRender}
        </div>
      </SignalForm>
    );
  }
}

function getResponses(signal, responses) {
  return _.map(signal.responses, (responseId) => (responses[responseId]));
};

function newSignal(signal, responses) {
  return _.reduce(signal, (currentSignal, value, key) => ({
    ...currentSignal,
    [key]: key === 'responses' ? getResponses(signal, responses) : value,
  }), {});
};

function getSignal(state, ownProps) {
  const { location, params } = ownProps;

  if (isExistingSignal(location.pathname)) {
    const signal = _.get(state, `models.listenSignals.data['${parseInt(params.id)}']`);
    const responses = state.models.responses.data;

    return newSignal(signal, responses);
  }

  return {
    signal_type: params.type,
    responses: [{},{}],
  };
}

const ConnectedContentPanel = connect((state, ownProps) => ({
  signal: getSignal(state, ownProps),
  tabs: state.app.dashboard.tabs,
  brand: state.models.brand.data,
}))(ContentPanel);

const hooks = {
  fetch: ({ dispatch, location, params }) => {
    if (isExistingSignal(location.pathname)) {
      const id = parseInt(params.id);
      dispatch(getListenSignalData(id));
    }
  },
};

export default provideHooks(hooks)(ConnectedContentPanel);
