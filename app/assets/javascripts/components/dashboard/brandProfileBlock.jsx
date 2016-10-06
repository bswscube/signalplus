import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash';
import Loader from 'components/loader.jsx';

function BrandProfileBlock({ brand }) {

  if (!brand.loaded) return <Loader />;
  const brandInfo = _.get(brand, 'data', {});

  return (
    <div className="brand-profile-block">
      <img className="brand-profile-img" src={brandInfo.profile_image_url} alt="Brand profile image"/>
      <div className="brand-profile-name">
        <h3>{brandInfo.name}</h3>
        <p>{`@${brandInfo.user_name}`}</p>
      </div>
    </div>
  );
}

export default connect(state => ({
  brand: state.models.brand,
}))(BrandProfileBlock);