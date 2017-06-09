import React from 'react';
import { Link } from 'react-router';
import InputBox from 'components/forms/inputBox';
import Checkbox from 'components/forms/checkbox';
import SignalIcon from 'components/links/signal_icon';
import ActivateSignalRadioButton from 'components/forms/activateSignalRadioButton';
import _ from 'lodash';


function renderInputBox(signal) {
  return (
    <div>
      <p className="signal-instruction">E
        <span className='signal-instruction-text'>
          nter a signal name to listen for
        </span>
      </p>
      <InputBox
        name="name"
        placeholder="#Name"
        componentClass="input"
        className="signalNameInput uctext"
      />
    </div>
  );
}

function renderSignalName(signal) {
  return <div>{`#${signal.name}`}</div>;
}



export default function EditMenuItem({ menu, signal, brandInfo }) {
  return (
    <li className="uctext">
      <div className="editMenuItem editMenuItemOne">
        <Checkbox
          name="facebook"
          label='Facebook'
          labelDescription='@brandhandle'
          className="checkboxSide"
        />
        <Checkbox
          name="twitter"
          label='Twitter'
          labelDescription="@brandhandle"
          className="checkboxSide"
        />
      </div>

      <Link
        {...menu.linkProps}
        activeClassName="active"
        className="editMenuItem activeButton"
      >
        <ActivateSignalRadioButton signal={signal}/>
      </Link>

    </li>
  );
}
