import React, { Component } from 'react';
import { connect } from 'react-redux';
import _ from 'lodash';
import WelcomeWidget from 'components/signalsPanel/welcomeWidget';
import SignalWidgets from 'components/signalsPanel/signalWidgets';
import CreateNewWidget from 'components/signalsPanel/createNewWidget';

class SignalsPanel extends Component {
  renderPanelTitle() {
    const signalCounts = _.countBy(this.props.signals, (signal) => (signal.active));
    const activeCount = signalCounts.true || 0;
    const inactiveCount = signalCounts.false || 0;
    const allCount = activeCount+inactiveCount || 0;

    if (activeCount > 0 || inactiveCount > 0) {
      const signalCounts = [];
      if (activeCount > 0) signalCounts.push(`${activeCount} Active`);
      if (inactiveCount > 0) signalCounts.push(`${inactiveCount} Inactive`);
      return 'Signals - '.concat(signalCounts.join(', '));
    } else {
      return 'All Signals';
    }
  }

  renderPanelContent() {
    if (_.isEmpty(this.props.signals)) {
      return <WelcomeWidget />;
    } else {
      return <SignalWidgets signals={this.props.signals} />;
    }
  }

  render() {
    return (
      <div>
        <h4 className='signal-header'>{this.renderPanelTitle()}</h4>
        {this.renderPanelContent()}
        <CreateNewWidget />
      </div>
    );
  }
}

export default connect(state => ({
  signals: _.get(state, 'models.listenSignals.data'),
}))(SignalsPanel);
