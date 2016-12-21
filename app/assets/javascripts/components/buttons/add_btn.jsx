import React, { Component } from 'react';
import { DropdownButton, MenuItem } from 'react-bootstrap';
import Calendar from 'components/forms/calendar';

export default class AddBtn extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className='edit-btns'>
        <DropdownButton title='ADD' id='addBtn' className='btn add-btn'>
          <p>Expiration Date</p>
          <Calendar
            date={this.props.expirationDate}
          />
        </DropdownButton>
      </div>
    );
  }
}

