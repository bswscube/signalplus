import React, { Component } from 'react';
import { connect } from 'react-redux';
import { reduxForm } from 'redux-form';
import SignalIcon from '../../../../../links/signal_icon.jsx';
import ImageUpload from './image_upload.jsx';
import { addPromotionalTweetData } from '../../../../../../redux/modules/models/listenSignals.js';
import _ from 'lodash';
import {
  Button,
  FormControl,
} from 'react-bootstrap';

export default class Promote extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.showPromoImage = this.showPromoImage.bind(this);

    this.state = {
      promoTweetId: '',
      message: '',
      imageUrl: ''
    };
  }

  handleChange(e) {
    this.setState({ message: e.currentTarget.value });
  }

  handleSubmit() {
    addPromotionalTweetData(this.state);
  }

  showPromoImage() {
    const { signal } = this.props;

    if (this.state.url && signal.id) {
      return (<img src={ this.state.url } className='promo-image-preview'/>);
    }
    return (<ImageUpload signal={ signal }/>);
  }

  render() {
    const { signal } = this.props;

    if (signal.id) {
      return (
        <div className='col-md-9 content-box'>
          <div className='content-header'>
            <p className='signal-type-label'> SEND TWEET </p>
          </div>

          <div className='response-info'>
            <h4>Promote:</h4>
            <SignalIcon type='twitter'/>
            <h4 className='subheading'>@Brand #Offers</h4>
          </div>

          <div className='tip-box'>
            <SignalIcon type='tip'/>
            <h5>Tip</h5>
            <p> Increase the awareness of your signal, promote it to your audience </p>
          </div>

          <div className='promote-box'>
            <div className='subheader'>
              <h5>Promotional Tweet</h5>
              <p>140 Character Limit</p>
            </div>

            <div className='promote-input-box'>
              <FormControl onChange={this.handleChange} componentClass="textarea" placeholder={'Searching for deals any time? Tweet or message #Deals to @Brand'}/>
            </div>

            <div className='subheader'>
              <h5>Promotional Image</h5>
              <p>Select an image to include or upload your own</p>
            </div>

            <div className='row'>
              <div className='col-xs-12 col-sm-12 col-md-12 col-lg-12 center promote-image'>
                { this.showPromoImage() }
              </div>
            </div>

            <Button onClick={this.handleSubmit} type='submit' className='save-btn post-to-timeline-btn'>POST TO YOUR TIMELINE</Button>
          </div>
        </div>
      );
    } else {
      return (
        <div className='create-signal-warning'> Please create signal first to create a promotional tweet </div>
      );
    }
  }
}
