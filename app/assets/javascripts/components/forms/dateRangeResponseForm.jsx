import React, { Component } from 'react';
import InputBox from 'components/forms/inputBox.jsx';
import Calendar from 'components/forms/calendar.jsx';
import _ from 'lodash';

function renderFields({ fields, meta: { touched, error } }) {
  return fields.map((responses_date_range, index) => {
    return (
      <div className='response-edit-box' key={index}>
        <div className='response-text'>
          <h5>Date Range Response</h5>
          <span className='timed-response-box-label'>
            <Calendar
              name={`${responses_date_range}.res_start_date`}
            />
            <span className="glyphicon glyphicon-chevron-right"></span>
            <Calendar
              name={`${responses_date_range}.res_end_date`}
            />
          </span>
        </div>
        <InputBox
          name={`${responses_date_range}.message`}
          placeholder="Type in a response here, add website links too"
          componentClass="textarea"
        />
        { touched && error && <span className='input-form-error'>{error}</span> }
        <a onClick={()=> fields.remove(index)} className='delete-timed-response-btn'>
          delete
        </a>
      </div>
    );
  });
}

export default function DateRangeResponseForm({ ...props }) {
  return <div>{renderFields(props)}</div>;
}
