require('babel-polyfill');

window.App = global.App = require('./components/app.jsx').default;
window.LogOutLink = global.LogOutLink = require('./components/logOutLink.jsx').default;
